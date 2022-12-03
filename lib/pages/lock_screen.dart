import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:path_provider/path_provider.dart' as syspath;

import 'package:global_image_search_v2/pages/search_page.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String passCode = '1111';
  final controller = InputController();
  Directory? appDirectory;
  File? file = File("");

  @override
  void initState() {
    syspath.getApplicationDocumentsDirectory().then((value) {
      appDirectory = value;
      file = File("${appDirectory!.path}/password.txt");
      if (file!.existsSync()) {
        passCode = file!.readAsStringSync();
      }
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => lockScreen(),
      );
    });
  }

  Future lockScreen() {
    return screenLock(
      onError: (tries) async {
        if (tries > 3) {
          Navigator.of(context).pop();
          await screenLockCreate(
            canCancel: true,
            context: context,
            inputController: controller,
            onConfirmed: (matchedText) async {
              file = File("${appDirectory!.path}/password.txt");
              await file!.writeAsString(matchedText);
              passCode = matchedText;
              Navigator.of(context).pop();
            },
            footer: TextButton(
              onPressed: () {
                controller.unsetConfirmed();
              },
              child: const Text('Reset input'),
            ),
          );
        }
      },
      context: context,
      correctString: passCode,
      canCancel: true,
      onUnlocked: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => SearchPage(),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Locked"),
            ElevatedButton(
              onPressed: () async {
                await lockScreen();
              },
              child: Text("Unlock"),
            ),
          ],
        ),
      ),
    );
  }
}
