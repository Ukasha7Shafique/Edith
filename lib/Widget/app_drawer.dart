import 'package:flutter/material.dart';
import 'package:practice_app/screens/connect_to_other.dart';
import 'package:practice_app/screens/trusted_user_screen.dart';
import 'package:provider/provider.dart';
import '../screens/download_screen.dart';
import '../screens/files_screen.dart';
import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello Friend!'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Main Files Page'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Upload a File'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(FilePage.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Connect to Other Device'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(ConnectOtherScreen.routName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Add Trusted Device'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(TrustedUserScreen.routName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');

              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
