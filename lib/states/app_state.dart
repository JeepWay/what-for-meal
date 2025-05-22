import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:what_for_meal/firebase/firebase_service.dart';

import '../firebase/constants.dart';
import '../firebase/model.dart';
import '../logging/logging.dart';

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  User? _user;
  User? get user => _user;
  bool get loggedIn => (_user != null);

  StreamSubscription<QuerySnapshot>? _personalListsSubscription;
  List<PersonalList> _personalLists = [];
  List<PersonalList> get personalLists => _personalLists;

  StreamSubscription<QuerySnapshot>? _publicListsSubscription;
  List<PersonalList> _publicLists = [];
  List<PersonalList> get publicLists => _publicLists;

  String? _selectedPersonalListID;
  String? get selectedPersonalListID => _selectedPersonalListID;

  StreamSubscription<QuerySnapshot>? _personalRestaurantsSubscription;
  List<Restaurant> _personalRestaurants = [];
  List<Restaurant> get personalRestaurants => _personalRestaurants;

  AppState() {
    logger.i('Creating AppState object, call _initAsync() after create it !!');
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void dispose() {
    _personalListsSubscription?.cancel();
    _publicListsSubscription?.cancel();
    _personalRestaurantsSubscription?.cancel();
    super.dispose();
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      logger.i('使用者離開 App, 儲存最新定位');
      FirebaseService.saveLocation();
      
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

  void setSelectedListID(String? listId) {
    if (_selectedPersonalListID != listId) {
      _selectedPersonalListID = listId;
      _updatePersonalRestaurantsSubscription();
    }
  }
  
  void _updatePersonalRestaurantsSubscription() {
    _cancelPersonalRestaurantsSubscription(); // cancel old subscription
    if (_selectedPersonalListID != null && _user != null) {
      logger.i('Starting restaurants subscription for listID: $_selectedPersonalListID');
      _personalRestaurantsSubscription = FirebaseFirestore.instance
          .collection(CollectionNames.personalLists)
          .doc(_selectedPersonalListID)
          .collection(CollectionNames.restaurants)
          .snapshots()
          .listen((snapshot) {
        _personalRestaurants = snapshot.docs.map((doc) {
          final data = doc.data();
          return Restaurant(
            listID: _selectedPersonalListID!,
            restaurantID: doc.id,
            name: data[RestaurantFields.name] as String? ?? '無標題',
            description: data[RestaurantFields.description] as String? ?? '沒有描述',
            address: data[RestaurantFields.address] as String? ?? '地址未知',
            geoHash: data[RestaurantFields.geoHash] as String? ?? '無標題',
            location: data[RestaurantFields.location] as GeoPoint? ?? GeoPoint(0, 0),
            type: data[RestaurantFields.type] as String? ?? '沒有提供價類型',
            price: data[RestaurantFields.price] as String? ?? '沒有提供價格',
            hasAC: data[RestaurantFields.hasAC] as bool? ?? false,
            creatTime: data[RestaurantFields.creatTime] as Timestamp?,
            updateTime: data[RestaurantFields.updateTime] as Timestamp?,
          );
        }).toList();
        logger.i('餐廳數量: ${_personalRestaurants.length}');
        notifyListeners();
      }, onError: (error) {
        logger.w('監聽個人清單裡的餐廳發生錯誤: $error');
      });
    } else {
      logger.w('沒有選擇清單或者尚未登入');
    }
  }

  void _cancelPersonalRestaurantsSubscription() {
    logger.i('Cancel restaurants subscription');
    _personalRestaurantsSubscription?.cancel();
    _personalRestaurants = [];
    notifyListeners();
  }
}