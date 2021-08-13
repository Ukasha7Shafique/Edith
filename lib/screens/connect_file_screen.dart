import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:practice_app/Widget/app_drawer.dart';
import 'package:practice_app/api/firebase_api.dart';
import 'package:practice_app/models/firebase_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectedFileScreen extends StatefulWidget {
  const ConnectedFileScreen({Key? key}) : super(key: key);
  static const routeName = '/connectedFileScreen';

  @override
  _ConnectedFileScreenState createState() => _ConnectedFileScreenState();
}

class _ConnectedFileScreenState extends State<ConnectedFileScreen> {
  late Future<List<FirebaseFile>> futureFiles;

  void initState() {
    super.initState();
    futureFiles = listConnected();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Connected page files'),
          centerTitle: true,
          actions: [],
        ),
        drawer: AppDrawer(),
        body: FutureBuilder<List<FirebaseFile>>(
          future: futureFiles,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError) {
                  return Center(child: Text('Some error occurred!'));
                } else {
                  final files = snapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildHeader(files.length),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: files.length,
                          itemBuilder: (context, index) {
                            final file = files[index];

                            return buildFile(context, file);
                          },
                        ),
                      ),
                    ],
                  );
                }
            }
          },
        ),
      );

  Widget buildFile(BuildContext context, FirebaseFile file) => ListTile(
        leading: Icon(Icons.folder_rounded),
        title: Text(
          file.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            color: Colors.blue,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.file_download),
          onPressed: () async {
            await FirebaseApi.downloadFile(file.ref);

            final snackBar = SnackBar(
              content: Text('Downloaded ${file.name}'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
        ),
      );

  Widget buildHeader(int length) => ListTile(
        tileColor: Colors.blue,
        leading: Container(
          width: 52,
          height: 52,
          child: Icon(
            Icons.file_copy,
            color: Colors.white,
          ),
        ),
        title: Text(
          '$length Files',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      );

  static Future<List<FirebaseFile>> listConnected() async {
    SharedPreferences reference = await SharedPreferences.getInstance();
    String? path1 = reference.getString('email');
    String path = 'files/$path1/';
    final ref = FirebaseStorage.instance.ref(path);
    final result = await ref.listAll();

    final urls = await FirebaseApi.getDownloadLinks(result.items);

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
}
