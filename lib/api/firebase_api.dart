import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/firebase_file.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class FirebaseApi with ChangeNotifier {
//Upload Files section
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (e) {
      return null;
    }
  }

  static UploadTask? uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putData(data);
    } on FirebaseException catch (e) {
      return null;
    }
  }

  // Download files sections
  static Future<List<String>> getDownloadLinks(List<Reference> refs) =>
      Future.wait(refs.map((ref) => ref.getDownloadURL()).toList());

  static Future<List<FirebaseFile>> listAll() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? path1 = pref.getString('localId');
    String path = 'files/$path1/';
    final ref = FirebaseStorage.instance.ref(path);
    final result = await ref.listAll();

    final urls = await getDownloadLinks(result.items);

    return urls
        .asMap()
        .map((index, url) {
          final ref = result.items[index];
          final name = ref.name;
          final file = FirebaseFile(ref: ref, name: name, url: url);

          return MapEntry(index, file);
        })
        .values
        .toList();
  }

  static Future downloadFile(Reference ref) async {
    final String url = await ref.getDownloadURL();
    final http.Response downloadData = await http.get(Uri.parse(url));
    final Directory? systemTempDir = await getExternalStorageDirectory();
    print(systemTempDir.toString());
    final File tempFile = File('${systemTempDir!.path}/tmp.jpg');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create();
    final task = ref.writeToFile(tempFile);
    final String name = await ref.name;
    final String path = await ref.fullPath;
    print(
      'Success!\nDownloaded $name \nUrl: $url'
      '\npath: $path',
    );

    // Directory? appDocDir = await getExternalStorageDirectory();
    // // print('Directory for phone is :    ' + dir);
    // File downloadToFile = File('${appDocDir!.path}/${ref.name}');
    // print(downloadToFile);
    // // final file = File('$dir/${ref.name}');
    // // print(file.path);
    // // await ref.writeToFile(file);
    // try {
    //   await FirebaseStorage.instance
    //       .ref(ref.fullPath)
    //       .writeToFile(downloadToFile);
    // } on FirebaseException catch (e) {
    //   // e.g, e.code == 'canceled'
    // }
  }
}
