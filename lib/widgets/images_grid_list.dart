import 'package:flutter/material.dart';
import 'package:global_image_search_v2/widgets/stateful_dialog.dart';

import 'package:provider/provider.dart';
import 'package:image_downloader/image_downloader.dart';

import '../provider/image_provider.dart';

class ImagesGridList extends StatefulWidget {
  const ImagesGridList({Key? key}) : super(key: key);

  @override
  State<ImagesGridList> createState() => _ImagesGridListState();
}

class _ImagesGridListState extends State<ImagesGridList> {


  @override
  Widget build(BuildContext context) {
    final imagesList = Provider.of<ImagesProvider>(context).getImages();
    return GridView.builder(
      itemCount: imagesList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: (_, i) {
        if (imagesList.runtimeType.toString() == "List<String>") {
          return InkWell(
            onTap: () => showDialog(
              context: context,
              builder: (_) => StatefulDialog(imagesList[i])
            ),
            child: Card(
              child: Image.network(
                imagesList[i],
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          return InkWell(
            onTap: () => showDialog(
              context: context,
              builder: (_) => StatefulDialog(imagesList[i])
          ),
            child: Card(
              child: Image.file(
                imagesList[i],
                fit: BoxFit.cover,
              ),
            ),
          );
        }
      },
    );
  }
}
