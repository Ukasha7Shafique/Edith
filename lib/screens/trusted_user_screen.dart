import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:practice_app/Widget/app_drawer.dart';
import 'package:practice_app/screens/download_screen.dart';

class TrustedUserScreen extends StatefulWidget {
  static const routName = '/trustedUser';

  @override
  _TrustedUserScreenState createState() => _TrustedUserScreenState();
}

class _TrustedUserScreenState extends State<TrustedUserScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final fb = FirebaseDatabase.instance;

  static Map<String, String> _data = {'email': ''};
  @override
  Widget build(BuildContext context) {
    final ref = fb.reference().child('TrustedUser');
    return Scaffold(
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
              },
            ),
            FlatButton(
              child: Text('Submit'),
              onPressed: () => submit(ref),
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
  }

  void submit(DatabaseReference ref) async {
    _formKey.currentState!.save();
    print('data saved');

    try {
      ref.child('email').set(_data['email']);
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }
  }
}
