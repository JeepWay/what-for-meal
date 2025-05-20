import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../firebase/constants.dart';
import '../firebase/model.dart';
import '../logging/logging.dart';

class AppState extends ChangeNotifier {
  User? _user;
  User? get user => _user;
  bool get loggedIn => (_user != null);

  StreamSubscription<QuerySnapshot>? _personalListsSubscription;
  List<PersonalList> _personalLists = [];
  List<PersonalList> get personalLists => _personalLists;

  StreamSubscription<QuerySnapshot>? _publicListsSubscription;
  List<PersonalList> _publicLists = [];
  List<PersonalList> get publicLists => _publicLists;

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
        _updatePersonalListsSubscription();
        _updatePublicListsSubscription();
      });
    } catch (e) {
      logger.w('Add authStateChanges subscription failed: $e');
    }
  }

  void _updatePersonalListsSubscription() {
    if (_user != null) {
      logger.i('Starting personal lists subscription for user: ${_user!.uid}');
      _personalListsSubscription = FirebaseFirestore.instance
          .collection(CollectionNames.personalLists)
          .where(PersonalListFields.userID, isEqualTo: _user!.uid)
          .snapshots()
          .listen((snapshot) {
        _personalLists = snapshot.docs.map((doc) => PersonalList(
          listID: doc.id ,
          title: doc.data()[PersonalListFields.title] as String? ?? '無標題',
          userID: doc.data()[PersonalListFields.userID] as String? ?? '用戶ID未知',
          userName: doc.data()[PersonalListFields.userName] as String? ?? '未知用戶',
          isPublic: doc.data()[PersonalListFields.isPublic] as bool? ?? false,
          creatTime: doc.data()[PersonalListFields.creatTime] as Timestamp?,
          updateTime: doc.data()[PersonalListFields.updateTime] as Timestamp?,
        )).toList();
        logger.i('personalLists: ${_personalLists.map((list) => list.toString()).toList()}');
        notifyListeners(); 
      }, onError: (error) {
        logger.w('監聽個人清單錯誤: $error');
      });
    } else {
      _personalListsSubscription?.cancel();
      _personalLists = [];
      logger.i('Cancel personalLists subscription');
      notifyListeners();
    }
  }

  void _updatePublicListsSubscription() {
    if (_user != null) {
      logger.i('Starting public lists subscription for user: ${_user!.uid}');
      _publicListsSubscription = FirebaseFirestore.instance
          .collection(CollectionNames.personalLists)
          .where(PersonalListFields.isPublic, isEqualTo: true)
          .snapshots()
          .listen((snapshot) {
        _publicLists = snapshot.docs.map((doc) => PersonalList(
          listID: doc.id ,
          title: doc.data()[PersonalListFields.title] as String? ?? '無標題',
          userID: doc.data()[PersonalListFields.userID] as String? ?? '用戶ID未知',
          userName: doc.data()[PersonalListFields.userName] as String? ?? '未知用戶',
          isPublic: doc.data()[PersonalListFields.isPublic] as bool? ?? false,
          creatTime: doc.data()[PersonalListFields.creatTime] as Timestamp?,
          updateTime: doc.data()[PersonalListFields.updateTime] as Timestamp?,
        )).toList();
        logger.i('publicLists: ${_publicLists.map((list) => list.toString()).toList()}');
        notifyListeners();
      }, onError: (error) {
        logger.w('監聽公開清單錯誤: $error');
      });
    } else {
      _publicListsSubscription?.cancel();
      _publicLists = [];
      logger.i('Cancel personalLists subscription');
      notifyListeners();
    }
  }
}