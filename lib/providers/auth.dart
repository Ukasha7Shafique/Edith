import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:practice_app/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return _token != null;
  }

  String? get tokenData {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(String email, String pass, String segment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$segment?key=AIzaSyCYBYEkyJ2DYctrR1mlcPc8dHWRE2lldnU';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'email': email,
            'password': pass,
            'returnSecureToken': true,
          },
        ),
      );
      final expData = json.decode(response.body);
      if (expData['error'] != null) {
        throw HttpException(expData['error']['message']);
      }
      _token = expData['idToken'];
      _userId = expData['localId'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('localId');
      if (id != null) prefs.remove('localId');
      prefs.setString('localId', email);
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(expData['expiresIn']),
        ),
      );
      notifyListeners();
    } on Exception catch (e) {
      throw e;
    }
  }

  Future signin(String email, String pass) async {
    return _authenticate(
      email,
      pass,
      'signInWithPassword',
    );
    // try {
    //   UserCredential userCredential = await FirebaseAuth.instance
    //       .signInWithEmailAndPassword(email: email, password: pass);
    //   notifyListeners();
    // } on FirebaseAuthException catch (e) {
    //   if (e.code == 'user-not-found') {
    //     print('No user found for that email.');
    //   } else if (e.code == 'wrong-password') {
    //     print('Wrong password provided for that user.');
    //   }
    // }
  }

  Future signup(String email, String pass) async {
    return _authenticate(email, pass, 'signUp');
    //   try {
    //     UserCredential userCredential = await FirebaseAuth.instance
    //         .createUserWithEmailAndPassword(email: email, password: pass);
    //   } on FirebaseAuthException catch (e) {
    //     if (e.code == 'weak-password') {
    //       print('The password provided is too weak.');
    //     } else if (e.code == 'email-already-in-use') {
    //       print('The account already exists for that email.');
    //     }
    //     notifyListeners();
    //   } catch (e) {
    //     print(e);
    //   }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }
}
