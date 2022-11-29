import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'package:http/http.dart' as http;
import 'package:photo_manager/photo_manager.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as ml;

class ImagesProvider with ChangeNotifier {
  List<Map<String, dynamic>> localImagesData = [];

  List<Uint8List> localImagesBytes = [];
  List<String> onlineImagesUrls = [];

  List getImages() {
    if (localImagesBytes.isEmpty) {
      return onlineImagesUrls;
    } else {
      return localImagesBytes;
    }
  }

  onlineImageSearch(String searchString) async {
    onlineImagesUrls.clear();
    localImagesBytes.clear();

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

  localImageSearch(String searchString) {
    onlineImagesUrls.clear();
    localImagesBytes.clear();

    localImagesData.forEach((image) {
      if ((image['text'] as String).contains(searchString)) {
        File imageFile = image['file'] as File;
          localImagesBytes.add(imageFile.readAsBytesSync());
      }
    });

    notifyListeners();
  }

  localImageScanning() async {
    final List<AssetPathEntity> paths =
        await PhotoManager.getAssetPathList(type: RequestType.image, hasAll: false);

    Future.forEach(paths, (folder) async {
      var photos = await folder.getAssetListRange(start: 0, end: 100);
      photos.forEach((photo) async {
        File? photoFile = await photo.file;
        final InputImage inputImage = InputImage.fromFilePath(photoFile!.path);

        var textRecognizer = ml.GoogleMlKit.vision.textRecognizer();
        var imageRecognizer = ml.GoogleMlKit.vision.imageLabeler();

        var recognizedText = await textRecognizer.processImage(inputImage);
        String imageText = recognizedText.text;

        final ImageLabelerOptions options =
            ImageLabelerOptions(confidenceThreshold: 0.6);
        final imageLabeler = ImageLabeler(options: options);

        final List<ImageLabel> labels =
            await imageLabeler.processImage(inputImage);

        for (ImageLabel label in labels) {
          final String text = label.label;
          imageText = imageText + " $text";
        }

        textRecognizer.close();
        imageRecognizer.close();

        localImagesData.add({'file': photoFile, 'text': imageText});
      });
    });
  }
}
