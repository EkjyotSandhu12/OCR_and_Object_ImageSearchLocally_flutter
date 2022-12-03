import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'package:photo_manager/photo_manager.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as ml;
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:path/path.dart' as path;

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
    RegExp reg = RegExp(searchString, caseSensitive: false);
    localImagesData.forEach((image) {
      if (reg.hasMatch(image['text'] as String)) {
        File imageFile = File(image['file'] as String);
        localImagesFiles.add(imageFile);
      }
    });

    notifyListeners();
  }
}

class LocalImageScanning with ChangeNotifier {
  localImageScanning() async {

    var textRecognizer = ml.GoogleMlKit.vision.textRecognizer();
    final ImageLabelerOptions options =
        ImageLabelerOptions(confidenceThreshold: 0.6);
    final imageLabeler = ImageLabeler(options: options);
    Directory dir = await syspath.getApplicationDocumentsDirectory();
    File fileImage = File("${dir.path}/savedScannedFiles.json");
    List<AssetEntity> images = [];  // images to be scanned right now
    List<String> storedFilesPaths = []; //paths for files already scanned in device

    if (fileImage.existsSync()) {  //adding already scanned files to the app data
      final data = fileImage.readAsStringSync();
      final photos = json.decode(data) as List;
      photos.forEach((photo) {
        localImagesData.add(photo);
      });
    }

    //extracting path data from already scanned files
    localImagesData.forEach((photo) {
      storedFilesPaths.add(path.basename(photo['file'] as String));
    });

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.image, hasAll: false);

    //comparing paths and only adding those files to images variable which were not scanned
    await Future.forEach(paths, (folder) async {
      var photos = await folder.getAssetListRange(start: 0, end: 100);

      await Future.forEach(photos, (photo) {
        if (!storedFilesPaths.contains(photo.title)) {
          images.add(photo);
        }
      });
    });

    int count = 0;
    totalFiles = images.length;
    print(totalFiles);
    await Future.forEach(images, (photo) async {
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

      localImagesData.add({'file': photoFile.path, 'text': imageText});

      if (count > 10) {
        fileImage.writeAsStringSync(json.encode(localImagesData));
        count = 0;
      }
      count++;
      scannedFiles++;
      print(scannedFiles);
      notifyListeners();
    });

    textRecognizer.close();
    imageLabeler.close();
  }

  double get getScannedProgress {
    return totalFiles == 0 ? 0 : (scannedFiles / totalFiles) * 1;
  }
}
