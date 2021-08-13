import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_app/Widget/app_drawer.dart';
import 'package:practice_app/screens/connect_file_screen.dart';
import 'package:practice_app/screens/download_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectOtherScreen extends StatefulWidget {
  const ConnectOtherScreen({Key? key}) : super(key: key);
  static const routName = '/connect';

  @override
  _ConnectOtherScreenState createState() => _ConnectOtherScreenState();
}

class _ConnectOtherScreenState extends State<ConnectOtherScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  static Map<String, String> _data = {'email': ''};
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Connect to Other page'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.mic),
              onPressed: () => DownloadScreen.startVOiceInput(context),
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'E-Mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Invalid email!';
                  }
                },
                onSaved: (value) {
                  _data['email'] = value.toString();
                  store(_data['email'].toString());
                },
              ),
              FlatButton(
                child: Text('View'),
                onPressed: submit,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                color: Theme.of(context).primaryColor,
                textColor: Theme.of(context).primaryTextTheme.button!.color,
              ),
            ],
          ),
        ),
      );

  void submit() async {
    _formKey.currentState!.save();
    Navigator.of(context).pushReplacementNamed(ConnectedFileScreen.routeName);
  }

  void store(String email) async {
    SharedPreferences pref2 = await SharedPreferences.getInstance();
    final id = pref2.getString('email');
    id != null ? pref2.remove('email') : pref2.setString('email', email);
  }
}
