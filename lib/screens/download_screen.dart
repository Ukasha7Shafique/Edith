import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:practice_app/Widget/voice_button.dart';
import '../api/firebase_api.dart';
import '../models/firebase_file.dart';
import '../Widget/app_drawer.dart';
import 'package:open_file/open_file.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);
  static const routeName = '/downloadScreen';
  static void startVOiceInput(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: VoiceButton(),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  late Future<List<FirebaseFile>> futureFiles;

  @override
  void initState() {
    super.initState();
    futureFiles = FirebaseApi.listAll();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Download Page'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.mic),
              onPressed: () => DownloadScreen.startVOiceInput(context),
            ),
          ],
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
                  final files = snapshot.data;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildHeader(files!.length),
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
        onTap: () => {
          openFile(file.ref),
        },
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

  Future<void> openFile(Reference ref) async {
    var result = ref.fullPath;
    String downloadURL =
        await FirebaseStorage.instance.ref(ref.fullPath).getDownloadURL();
    final _result = await OpenFile.open(result);
    print(_result.message);
  }
}
