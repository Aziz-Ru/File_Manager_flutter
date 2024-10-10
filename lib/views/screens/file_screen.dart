import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class OpenFilesScreen extends StatefulWidget {
  const OpenFilesScreen({super.key});

  @override
  State<OpenFilesScreen> createState() => _OpenFilesScreenState();
}

class _OpenFilesScreenState extends State<OpenFilesScreen> {
  bool loading = false;
  Directory directory = Directory('/storage/emulated/0');
  List<FileSystemEntity> files = [];
  int selectedFileIndex = -1;
  Map<String, int> folderItems = {};

  void sortFileSystem() {
    files.sort((a, b) {
      return a.path.compareTo(b.path);
    });
    setState(() {});
  }

  Future<void> getFiles() async {
    setState(() {
      loading = true;
    });

    PermissionStatus status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      if (await directory.exists()) {
        files = directory.listSync();
        folderItems.clear();
        for (var entity in files) {
          if (entity is Directory) {
            List<FileSystemEntity> innerFiles = entity.listSync();
            folderItems[entity.path] = innerFiles.length;
          }
        }
      } else {
        print('Directory does not exist');
      }
    }
    if (status.isDenied) {
      print('Permission denied');
    } else if (status.isPermanentlyDenied) {
      print('Permission permanently denied');
    }

    setState(() {
      loading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getFiles();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(selectedFileIndex == -1
                  ? 'File Manager'
                  : files[selectedFileIndex].path),
              leading: directory.path == '/storage/emulated/0'
                  ? const Icon(Icons.folder)
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        directory = directory.parent;
                        getFiles();
                      },
                    ),
            ),
            bottomSheet: Visibility(
                visible: selectedFileIndex != -1,
                child: BottomAppBar(
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.delete),
                      )
                    ],
                  ),
                )),
            body: Visibility(
                visible: files.isNotEmpty,
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [Text(directory.path)],
                        )),
                    Visibility(
                        child: Expanded(
                            child: ListView.builder(
                                itemCount: files.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    selected: selectedFileIndex == index,
                                    selectedColor: Colors.pink.shade100,
                                    title:
                                        Text(files[index].path.split('/').last),
                                    subtitle: Text(
                                        '${folderItems[files[index].path] ?? 0} items'),
                                    leading: Icon(files[index] is File
                                        ? Icons.file_open
                                        : Icons.folder),
                                    onTap: () {
                                      if (files[index] is Directory) {
                                        directory = files[index] as Directory;
                                        getFiles();
                                      } else if (files[index] is File) {
                                        OpenFilex.open(files[index].path);
                                      }
                                    },
                                    onLongPress: () {
                                      setState(() {
                                        selectedFileIndex = index;
                                      });
                                    },
                                  );
                                })))
                  ],
                ))));
  }
}
