import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  Future<Directory?>? _tempDirectory;
  Future<Directory?>? _appDocumentDirectory;
  Future<Directory?>? _externalDocumentsDirectory;

  void _requestTempDirectory() {
    setState(() {
      _tempDirectory = getTemporaryDirectory();
    });
  }

  void _requestAppDocumentsDirectory() {
    setState(() {
      _appDocumentDirectory = getApplicationDocumentsDirectory();
    });
  }

  void _requestExternalDocumentsDirectory() {
    setState(() {
      _externalDocumentsDirectory = getExternalStorageDirectory();
    });
  }

  Widget _buildDirectory(
      BuildContext context, AsyncSnapshot<Directory?> snapshot) {
    Text text = const Text('');
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        text = Text('Error: ${snapshot.error}');
      } else if (snapshot.hasData) {
        text = Text('Path: ${snapshot.data!.path}');
      } else {
        text = const Text('Unavailable');
      }
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: text,
    );
  }

  Widget _buildDirectories(
      BuildContext context, AsyncSnapshot<List<Directory>?> snapshot) {
    Text text = const Text('');
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        text = Text('Error: ${snapshot.error}');
      } else if (snapshot.hasData) {
        final String combined =
            snapshot.data!.map((Directory dir) => dir.path).join(', ');
        text = Text('Paths: $combined');
      } else {
        text = const Text('Unavailable');
      }
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('File Manager'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                      onPressed: _requestTempDirectory,
                      child: const Text('Get Temprary Directory')),
                ),
                FutureBuilder(future: _tempDirectory, builder: _buildDirectory)
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                      onPressed: _requestExternalDocumentsDirectory,
                      child: const Text('Get Application External Directory')),
                ),
                FutureBuilder(
                    future: _externalDocumentsDirectory,
                    builder: _buildDirectory)
              ],
            ),

            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                      onPressed: _requestExternalDocumentsDirectory,
                      child: const Text('Get Application External Directory')),
                ),
                FutureBuilder(
                    future: _externalDocumentsDirectory,
                    builder: _buildDirectory)
              ],
            )
          
          ],
        ),
      ),
    ));
  }
}
