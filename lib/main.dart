import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';

import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import './provider/image_provider.dart';
import './pages/search_page.dart';
import './pages/lock_screen.dart';

void main() {
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xffF2DEBA),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xffF2DEBA),
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xffF2DEBA),
            ),
          ),
        ),
        textTheme: const TextTheme(
          subtitle1: TextStyle(
            color: Color(0xffFFEFD6),
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xff3A8891),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xff0E5E6F),
            foregroundColor: const Color(0xffFFEFD6),
          ),
        ),
      ),
      home: LockScreen(),
    );
  }
}
