import 'package:flutter/material.dart';
import '../provider/image_provider.dart';

import 'package:global_image_search_v2/provider/image_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/app_bar_search.dart';
import '../widgets/images_grid_list.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> sizeAnimation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300))
          ..addListener(() {
            setState(() {});
          });
    sizeAnimation = Tween<double>(begin: 10, end: 60).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));
  }

  PreferredSize appBarBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(sizeAnimation.value),
      child: sizeAnimation.value < 58 ? Text("") : AppBarSearch(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImagesProvider()),
        ChangeNotifierProvider(create: (_) {
          final object = LocalImageScanning();
          object.localImageScanning();
          return object;
        }),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Image Search"),
          bottom: appBarBottom(),
          actions: [
            Consumer<LocalImageScanning>(
              builder: (context, data, _) => Text(
                  "${(data.getScannedProgress * 100).toStringAsFixed(0)}%"),
            ),
            IconButton(
                onPressed: () {
                  sizeAnimation.value == 10
                      ? _animationController.forward()
                      : _animationController.reverse();
                },
                icon: Icon(Icons.search)),
          ],
        ),
        body: ImagesGridList(),
      ),
    );
  }
}
