import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:global_image_search_v2/pages/search_page.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  @override
  Widget build(BuildContext context) {
    String passCode = '1111';
    final controller = InputController();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Locked"),
            ElevatedButton(
              onPressed: () async {
                await screenLock(
                  onError: (tries) async {
                    if (tries > 3) {
                      Navigator.of(context).pop();
                      await screenLockCreate(
                        canCancel: true,
                        context: context,
                        inputController: controller,
                        onConfirmed: (matchedText) {

                            passCode = matchedText;
                            print(passCode);

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
                  onUnlocked: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SearchPage(),
                    ),
                  ),
                );
              },
              child: Text("Unlock"),
            ),
          ],
        ),
      ),
    );
  }
}
