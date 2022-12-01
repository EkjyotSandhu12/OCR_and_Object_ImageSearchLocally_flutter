import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';


import '../provider/image_provider.dart';

class AppBarSearch extends StatefulWidget {
  @override
  State<AppBarSearch> createState() => _AppBarSearchState();
}

class _AppBarSearchState extends State<AppBarSearch>
    with SingleTickerProviderStateMixin {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final imageProvider = Provider.of<ImagesProvider>(context, listen: false);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
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
              TextButton(
                  onPressed: () async {
                    imageProvider.localImageSearch(textEditingController.text);
                  },
                  child: Text("Locally")),
            ],
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Consumer<LocalImageScanning>(
          builder: (context, data, _) => LinearProgressIndicator(
            color: Colors.white,
            backgroundColor: Theme.of(context).colorScheme.primary,
            value: data.getScannedProgress,
          ),
        ),
      ],
    );
  }
}
