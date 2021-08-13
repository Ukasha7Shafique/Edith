import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:practice_app/Widget/voice_button.dart';
import 'package:practice_app/providers/auth.dart';
import 'package:practice_app/screens/connect_file_screen.dart';
import 'package:practice_app/screens/connect_to_other.dart';
import 'package:practice_app/screens/download_screen.dart';
import 'package:practice_app/screens/files_screen.dart';
import 'package:practice_app/screens/trusted_user_screen.dart';
import 'package:provider/provider.dart';
import './screens/auth_screen.dart';
import './api/firebase_api.dart';
import './screens/splash_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: FirebaseApi(),
        )
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: auth.isAuth
              ? DownloadScreen()
              : FutureBuilder(
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            DownloadScreen.routeName: (ctx) => DownloadScreen(),
            FilePage.routeName: (ctx) => FilePage(),
            ConnectOtherScreen.routName: (ctx) => ConnectOtherScreen(),
            ConnectedFileScreen.routeName: (ctx) => ConnectedFileScreen(),
            VoiceButton.routeName: (ctx) => VoiceButton(),
            TrustedUserScreen.routName: (ctx) => TrustedUserScreen(),
          },
        ),
      ),
    );
  }
}
