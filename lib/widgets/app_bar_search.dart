import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../provider/image_provider.dart';


class AppBarSearch extends StatefulWidget {

  @override
  State<AppBarSearch> createState() => _AppBarSearchState();
}

class _AppBarSearchState extends State<AppBarSearch> {

  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<ImagesProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textEditingController,
            ),
          ),
          TextButton(
              onPressed: () {
                imageProvider.onlineImageSearch(textEditingController.text);
              },
              child: const Text("Online")),
          const SizedBox(
            width: 10,
          ),
          TextButton(onPressed: () {
            imageProvider.localImageSearch(textEditingController.text);
          }, child: Text("Locally")),
        ],
      ),
    );
  }
}
