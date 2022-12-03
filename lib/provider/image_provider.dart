import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'package:photo_manager/photo_manager.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as ml;
import 'package:path_provider/path_provider.dart' as syspath;

int totalFiles = 0, scannedFiles = 0;

List<Map<String, dynamic>> localImagesData = [];

List<File> localImagesFiles = [];
List<String> onlineImagesUrls = [];

class ImagesProvider with ChangeNotifier {
  deleteLocalImageFile(File file) {
    if (localImagesFiles.contains(file)) {
      localImagesFiles.remove(file);
      notifyListeners();
    }
  }

  List getImages() {
    if (localImagesFiles.isEmpty) {
      return onlineImagesUrls;
    } else {
      return localImagesFiles;
    }
  }

  Future<void> onlineImageSearch(String searchString) async {
    onlineImagesUrls.clear();
    localImagesFiles.clear();

    String url =
        "https://api.unsplash.com/search/photos?page=1&query=$searchString"
        "&client_id=GlUpzb7r1-eZ4vbhFDszmeI81YSuJPMR9kkah2QTbZQ";

    final response = await http.get(Uri.parse(url));

    Map responseData = json.decode(response.body) as Map;
    for (var imageData in responseData['results']) {
      onlineImagesUrls.add(imageData['urls']['regular']);
    }

    notifyListeners();
  }

  Future<void> localImageSearch(String searchString) async {
    onlineImagesUrls.clear();
    localImagesFiles.clear();

    localImagesData.forEach((image) {
      if ((image['text'] as String).contains(searchString)) {
        File imageFile = image['file'] as File;
        localImagesFiles.add(imageFile);
      }
    });

    notifyListeners();
  }
}

class LocalImageScanning with ChangeNotifier {
  getFilesFromDirectory(File file) {}

  localImageScanning() async {
    Directory dir = await syspath.getApplicationDocumentsDirectory();
    File fileImage = File("${dir.path}/savedScannedFiles.json");
    File fileFolder = File("${dir.path}/savedScannedFolders.json");
    List<String> scannedFolders = [];

    if (fileFolder.existsSync()) {
      List<dynamic> data = json.decode(fileFolder.readAsStringSync());
      scannedFolders = data.map((e) {
        return e.toString();
      }).toList();
    }

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.image, hasAll: false);

    final tempPath = paths.toList();
    await Future.forEach(tempPath, (folder) async {
      /*if (scannedFolders.contains(folder.name)) {
        paths.remove(folder);
      } else {*/
        var photos = await folder.getAssetListRange(start: 0, end: 100);
        totalFiles += photos.length;
     // }
    });

    scannedFiles = 0;
    await Future.forEach(paths, (folder) async {
      var photos = await folder.getAssetListRange(start: 0, end: 100);
      var textRecognizer = ml.GoogleMlKit.vision.textRecognizer();
      final ImageLabelerOptions options =
          ImageLabelerOptions(confidenceThreshold: 0.6);
      final imageLabeler = ImageLabeler(options: options);

      await Future.forEach(photos, (photo) async {
        File? photoFile = await photo.file;

        final InputImage inputImage = InputImage.fromFilePath(photoFile!.path);

        var recognizedText = await textRecognizer.processImage(inputImage);
        String imageText = recognizedText.text;

        final List<ImageLabel> labels =
            await imageLabeler.processImage(inputImage);

        for (ImageLabel label in labels) {
          final String text = label.label;
          imageText = imageText + " $text";
        }

        localImagesData.add({'file': photoFile, 'text': imageText});
        scannedFiles++;
        notifyListeners();
      });

      scannedFolders.add(folder.name);
      // fileImage.writeAsStringSync(json.encode(localImagesData));
      fileFolder.writeAsStringSync(json.encode(scannedFolders));

      textRecognizer.close();
      imageLabeler.close();
    });
  }

  double get getScannedProgress {
    return totalFiles == 0 ? 0 : (scannedFiles / totalFiles) * 1;
  }
}
