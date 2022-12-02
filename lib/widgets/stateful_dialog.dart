import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_downloader/image_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view.dart';
import 'package:device_info/device_info.dart';

import '../provider/image_provider.dart';

class StatefulDialog extends StatefulWidget {
  final image;

  StatefulDialog(this.image);

  @override
  State<StatefulDialog> createState() => _StatefulDialogState();
}

class _StatefulDialogState extends State<StatefulDialog> {

  bool downloading = false;
  Directory? selectedDirectory;

  getPermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (status.isRestricted) {
      status = await Permission.manageExternalStorage.request();
    }

    if (status.isDenied) {
      status = await Permission.manageExternalStorage.request();
    }
    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
            'Please add permission for app to manage external storage'),
      ));
    }
  }

  Future<void> _pickDirectory(BuildContext context) async {
    if (await Permission.manageExternalStorage.status.isDenied) {
      getPermission();
    }

    Directory? directory = selectedDirectory;
    directory ??= Directory(FolderPicker.rootPath);

    Directory? newDirectory = await FolderPicker.pick(
        allowFolderCreation: true,
        context: context,
        rootDirectory: directory,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))));
    selectedDirectory = newDirectory;
    print("Directory : $selectedDirectory");
  }

  @override
  Widget build(BuildContext context) {
    return widget.image.runtimeType.toString() != 'String'
        ? SimpleDialog(
      children: [
        Text((widget.image as File).path.toString(), textAlign: TextAlign.center),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () async {
                      await _pickDirectory(context);
                      File oldFile = await widget.image!;
                      var newFile = await oldFile.copy("${selectedDirectory?.path}/${path.basename(oldFile.path)}");
                      if(newFile.existsSync()) {
                        oldFile.delete();
                        Provider.of<ImagesProvider>(context, listen: false).deleteLocalImageFile(oldFile);
                      }
              },
              child: Text("Move"),
            ),
            ElevatedButton(
              onPressed: () async {

                    await _pickDirectory(context);
                    await widget.image!.copy("${selectedDirectory?.path}/${path.basename(widget.image!.path)}");
              },
              child: Text("Copy"),
            ),
          ],
        ),
        InkWell(
          onTap: (){
            OpenFile.open((widget.image as File).path);
          },
          child: Image.file(
            widget.image,
            fit: BoxFit.cover,
          ),
        ),
      ],
    )
        : SimpleDialog(
      children: [
        downloading
            ? LinearProgressIndicator()
            : ElevatedButton(
          onPressed: () async {
            setState(() {
              downloading = !downloading;
            });
            await ImageDownloader.downloadImage(widget.image);
            setState(() {
              downloading = !downloading;
            });
          },
          child: Text("Download"),
        ),
        Image.network(
          widget.image,
          fit: BoxFit.cover,
        ),
      ],
    );
  }
}
