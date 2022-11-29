import 'package:flutter/material.dart';
import 'package:global_image_search_v2/provider/image_provider.dart';

import 'package:provider/provider.dart';

import '../widgets/app_bar_search.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

PreferredSize appBarBottom() {
  return PreferredSize(
    preferredSize: Size.fromHeight(35),
    child: AppBarSearch(),
  );
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    final imagesList = Provider.of<ImagesProvider>(context).getImages();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Search"),
        bottom: appBarBottom(),
      ),
      body: GridView.builder(
          itemCount: imagesList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (_, i) {
            if (imagesList.runtimeType.toString() == "List<String>") {
              return Card(
                child: Image.network(
                  imagesList[i],
                  fit: BoxFit.cover,
                ),
              );
            } else {
              return Card(
                child: Image.memory(
                  imagesList[i],
                  fit: BoxFit.cover,
                ),
              );
            }
          }),
    );
  }
}
