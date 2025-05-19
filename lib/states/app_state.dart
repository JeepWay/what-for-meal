import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../logging/logging.dart';

class AppState extends ChangeNotifier {
  User? _user;
  User? get user => _user;
  bool get loggedIn => (_user != null);

  AppState() {
    logger.i('Creating AppState object, call _initAsync() after create it !!');
  }

  Future<void> initAsync() async {   
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();

    try {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          logger.i('User changed: ${user.uid}');
        } else {
          logger.i('User changed: No user');
        }
        _user = user;
        notifyListeners();
      });
    } catch (e) {
      logger.w('Add authStateChanges subscription failed: $e');
    }
  }
}