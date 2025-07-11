import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:what_for_meal/firebase/model.dart';
import 'package:what_for_meal/utils/location_helper.dart';

import '../logging/logging.dart';
import '../utils/geolocation_utils.dart';
import 'firebase_options.dart';
import 'response.dart';
import 'constants.dart';

class FirebaseService {
  static final GeoHasher geoHasher = GeoHasher();

  /// Firebase setup
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  /// Email sign in
  static Future<SignInWithEmailResponse> signInWithEmail({
    required String email,
    required String password
  }) async {
    final response = SignInWithEmailResponse(success: false, message: '');

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      logger.i('Sign in with email successfully: ${credential.user}');
      response.success = true;
      response.message = '以電子郵件登入成功';
      response.user = credential.user;

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          response.message = '不存在的電子郵件或者密碼錯誤';
          break;
        default:
          response.message = '錯誤: ${e.message}';
      }
    } catch (e) {
      response.message = '未知錯誤: $e';
    }
    return response;
  }

  /// Google sign in
  static Future<SignInWithGoogleResponse> signInWithGoogle() async {
    final response = SignInWithGoogleResponse(success: false, message: '');

    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      final authCredential = GoogleAuthProvider.credential(
        idToken: gAuth.idToken,
        accessToken: gAuth.accessToken,
      );

      final credential = await FirebaseAuth.instance.signInWithCredential(authCredential);

      await FirebaseFirestore.instance
        .collection(CollectionNames.users)
        .doc(credential.user!.uid)
        .set({
          UserFileds.userName: credential.user!.displayName,
          UserFileds.email: credential.user!.email,
          UserFileds.lastSignIn: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      logger.i('Sign in with Google successfully: ${credential.user}');
      response.success = true;
      response.message = '以 Google 帳號登入成功';
      response.user = credential.user;

    } on FirebaseAuthException catch (e) {
      logger.w('FirebaseAuthException error: $e');
      switch (e.code) {
        case 'invalid-credential':
          response.message = 'Invalid email or password.';
          break;
        default:
          response.message = 'Error: ${e.message}';
      }
    } catch (e) {
      logger.w('Google sign in error: $e');
      response.message = 'Google 帳號登入錯誤: $e';
    }
    return response;
  }

  /// Email sign up
  static Future<SignUpWithEmailResponse> signUpWithEmail({
    required String username,
    required String email, 
    required String password
  }) async {
    final response = SignUpWithEmailResponse(success: false, message: '');

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
        .collection(CollectionNames.users)
        .doc(credential.user!.uid)
        .set({
          UserFileds.userName: username,
          UserFileds.email: email,
          UserFileds.signUpTime: FieldValue.serverTimestamp(),
          UserFileds.lastSignIn: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      saveLocation();
      logger.i('Sign up successfully: ${credential.user}');
      response.success = true;
      response.message = '註冊成功，將轉移到主頁面';
      response.user = credential.user;

    } on FirebaseAuthException catch (e) {
      logger.i('Sign out failed');
      switch (e.code) {
        case 'weak-password':
          response.message = '密碼太弱，請設置更強的密碼';
          break;
        case 'email-already-in-use':
          response.message = '此電子郵件已被註冊';
          break;
        default:
          response.message = '資料庫錯誤: ${e.message}';
      } 
    } catch (e) {
      response.message = '未知錯誤: $e';
    }
    return response;
  }
  
  /// 使用者登出
  static Future<SignOutResponse> signOut() async {
    final response = SignOutResponse(success: false, message: '');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      response.message = '尚未登入，無法進行登出';
      return response;
    }

    try {
      await FirebaseFirestore.instance
        .collection(CollectionNames.users)
        .doc(user.uid)
        .set({
          UserFileds.lastSignOut: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

      await saveLocation();
      await FirebaseAuth.instance.signOut();
      logger.i('Sign out successfully');
      response.success = true;
      response.message = '成功登出';
    } catch (e) {
      logger.w('Sign out failed: $e');
      response.message = '未知錯誤: $e';
    }
    return response;
  }

  /// 寄送密碼重設郵件
  static Future<ResetPasswordWithEmailResponse> resetPasswordWithEmail({
    required String email
  }) async {
    final response = ResetPasswordWithEmailResponse(success: false, message: '');

    try {
      QuerySnapshot userDoc = await FirebaseFirestore.instance
        .collection(CollectionNames.users)
        .where(UserFileds.email, isEqualTo: email)
        .get();

      if (userDoc.docs.isEmpty) {
        response.message = '此電子郵件尚未註冊';
        logger.w(response.message);
        return response;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      response.success = true;
      response.message = '已發送密碼重置郵件，請檢查您的電子郵件';

    } on FirebaseAuthException catch (e) {
      logger.w('FirebaseAuthException error: $e');
      switch (e.code) {
        case 'invalid-email':
          response.message = '無效的電子郵件格式';
          break;
        case 'user-not-found':
          response.message = '找不到此電子郵件對應的用戶';
          break;
        default:
          response.message = '資料庫錯誤: ${e.message}';
      }
    } catch (e) {
      logger.w('Unknown Exception error: $e');
      response.message = '未知錯誤: $e';
    }
    return response;
  }

  /// 主頁新增個人清單
  static Future<AddPersonalListResponse> addNewList({
    required String title
  }) async {
    final response = AddPersonalListResponse(success: false, message: '');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      response.message = '尚未登入，無法新增清單';
      return response;
    }

    try {
      DocumentReference doc = await FirebaseFirestore.instance
        .collection(CollectionNames.personalLists)
        .add({
          PersonalListFields.title: title,
          PersonalListFields.userID: user.uid,
          PersonalListFields.userName: user.displayName,
          PersonalListFields.isPublic: false,
          PersonalListFields.creatTime: FieldValue.serverTimestamp(),
          PersonalListFields.updateTime: FieldValue.serverTimestamp(),
        });
      logger.i('Add personal list successfully: $doc');
      response.success = true;
      response.message = '成功新增新的清單: $title';
      response.doc = doc;
    } on FirebaseException catch (e) {
      logger.w('Add personal list failed.\nFirestore error: $e');
      response.message = '無法新增個人清單';
    }
    catch (e) {
      logger.w('Add personal list failed.\nUnknown error: $e');
      response.message = '未知錯誤: $e';
    }
    return response;
  }

  /// 主頁刪除個人清單
  static Future<DeletePersonalListResponse> deleteList({
    required String listID
  }) async {
    final response = DeletePersonalListResponse(success: false, message: '');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      response.message = '尚未登入，無法刪除清單';
      return response;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      WriteBatch batch = firestore.batch();
      final listRef = firestore.collection(CollectionNames.personalLists).doc(listID);

      final listSnapshot = await listRef.get();
      if (!listSnapshot.exists) {
        logger.w('Personal list does not exist: $listID');
        response.message = '無法刪除個人清單，該清單並未存在: $listID';
        return response;
      }

      final restaurantSnapshot = await listRef.collection(CollectionNames.restaurants).get();
      for (final doc in restaurantSnapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(listRef);
      await batch.commit();

      logger.i('Remove personal list successfully: $listID');
      response.success = true;
      response.message = '成功刪除個人清單';
    } on FirebaseException catch (e) {
      logger.w('Remove personal list failed.\nFirestore error: $e');
      response.message = '無法刪除個人清單: ${e.message}';
    } catch (e) {
      logger.w('Remove personal list failed.\nUnknown error: $e');
      response.message = '未知錯誤: $e';
    }
    return response;
  }

  /// 更新清單的屬性
  static Future<PpdateIsPublicOfListResponse> updateList({
    required String listID,
    required Map<String, dynamic> updates,
  }) async {
    final response = PpdateIsPublicOfListResponse(success: false, message: '');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      response.message = '尚未登入，無法更新清單';
      return response;
    }

    try {
      final listRef = FirebaseFirestore.instance
          .collection(CollectionNames.personalLists)
          .doc(listID);

      final listSnapshot = await listRef.get();
      if (!listSnapshot.exists) {
        logger.w('Personal list does not exist: $listID');
        response.message = '更新清單失敗，該清單並未存在: $listID';
        return response;
      }

      final updatedData = {
        ...updates,
        PersonalListFields.updateTime: FieldValue.serverTimestamp(),
      };
      await listRef.update(updatedData);

      logger.i('Update personal list: $listID with field: ${updatedData.toString()} successfully');
      response.success = true;
      response.message = '成功更新個人清單: $listID';
    } on FirebaseException catch (e) {
      logger.w('Update personal list failed.\nFirestore error: $e');
      response.message = '無法更新個人清單';
    }
    catch (e) {
      logger.w('Update personal list failed.\nUnknown error: $e');
      response.message = '未知錯誤: $e';
    }
    return response;
  }

  /// 個人清單裡新增餐廳
  static Future<AddRestaurantResponse> addNewRestaurant({
    required String listID,
    required String name,
    required String address,
    required String description,
    required String type,
    required String price,
    required bool hasAC,
  }) async {
    final response = AddRestaurantResponse(success: false, message: '');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      response.message = '尚未登入，無法新增餐廳';
      return response;
    }
  
    try {
      final geoResult = await convertAddressToGeohash(address.trim());

      DocumentReference doc = await FirebaseFirestore.instance
        .collection(CollectionNames.personalLists)
        .doc(listID)
        .collection(CollectionNames.restaurants)
        .add({
          RestaurantFields.name: name.trim(),
          RestaurantFields.description: description.trim(),
          RestaurantFields.address: address.trim(),
          RestaurantFields.geoHash: geoResult['geohash'],
          RestaurantFields.location: GeoPoint(geoResult['latitude'], geoResult['longitude']),
          RestaurantFields.type: type.trim(),
          RestaurantFields.price: price.trim(),
          RestaurantFields.hasAC: hasAC,
          RestaurantFields.creatTime: FieldValue.serverTimestamp(),
          RestaurantFields.updateTime: FieldValue.serverTimestamp(),
        });
      
      logger.i('Add restaurantt successfully: $doc');
      response.success = true;
      response.message = '成功新增新的餐廳: $name';
      response.doc = doc;
    } on Exception catch (e) {
      logger.w('Add restaurantt failed.\nLocation error $e');
      response.message = '地址查詢失敗：請輸入正確的地址';
    } catch (e) {
      logger.w('Add restaurantt failed.\nUnknown error $e');
      response.message = '無法新增餐廳，未知錯誤: $e';
    }
    return response;
  }

  /// 個人清單裡刪除餐廳
  static Future<DeleteRestaurantResponse> deleteRestaurant({
    required String listID,
    required String restaurantID,
  }) async {
    final response = DeleteRestaurantResponse(success: false, message: '');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      response.message = '尚未登入，無法刪除餐廳';
      return response;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      WriteBatch batch = firestore.batch();
      final listRef = firestore.collection(CollectionNames.personalLists).doc(listID);
      final restaurantRef = listRef.collection(CollectionNames.restaurants).doc(restaurantID);

      final listSnapshot = await listRef.get();
      if (!listSnapshot.exists) {
        logger.w('Personal list does not exist: $listID');
        response.message = '刪除餐廳失敗，該清單並未存在: $listID';
        return response;
      }

      final restaurantSnapshot = await restaurantRef.get();
      if (!restaurantSnapshot.exists) {
        logger.w('Restaurant does not exist: $restaurantID in list: $listID');
        response.message = '刪除餐廳失敗，該餐廳並未存在: $restaurantID';
        return response;
      }

      batch.delete(restaurantRef);
      await batch.commit();

      logger.i('Remove restaurant successfully: $restaurantID from list: $listID');
      response.success = true;
      response.message = '成功刪除餐廳';
    } on FirebaseException catch (e) {
      logger.w('Remove restaurant failed.\nFirestore error: $e');
      response.message = '無法刪除餐廳: ${e.message}';
    } catch (e) {
      logger.w('Remove restaurant failed.\nUnknown error: $e');
      response.message = '未知錯誤: $e';
    }
    return response;
  }

  /// 找出半徑內的使用者的餐廳
  static Future<ExploreResponse> fetchNearbyUserRestaurants(
    GeoPoint center, 
    int radius, 
    {int precision = 5}
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final response = ExploreResponse(success: false, message: '', restaurants: []);

    if (user == null) {
      response.message = '尚未登入，無法使用探索功能';
      return response;
    }

    final userId = user.uid;

    try {
      // 把使用者目前的位置轉成 geohash
      final myHash = geoHasher.encode(center.longitude, center.latitude, precision: precision);
      final hashes = geoHasher.neighbors(myHash).values.toList();

      // 根據 geohash 縮小尋找範圍
      final snap = await FirebaseFirestore.instance
          .collection(CollectionNames.users)
          .where(UserFileds.geoHash, whereIn: hashes)
          .get();

      final userIds = <String>[];

      for (var doc in snap.docs) {
        final data = doc.data();
        if (data[UserFileds.location] is! GeoPoint) continue;

        final GeoPoint geo = data[UserFileds.location];
        final dist = Geolocator.distanceBetween(center.latitude, center.longitude, geo.latitude, geo.longitude);
        // 有包含在 hashes 的使用者如果距離小於設定的 radius, 則放入 userIds
        if (dist <= radius && doc.id != userId) {
          userIds.add(doc.id);
        }
      }

      // 收集在範圍內使用者的前五個公開清單中的所有餐廳資料
      for (var uid in userIds) {
        try {
          final listsSnap = await FirebaseFirestore.instance
              .collection(CollectionNames.personalLists)
              .where(PersonalListFields.userID, isEqualTo: uid)
              .where(PersonalListFields.isPublic, isEqualTo: true)
              .limit(5)
              .get();
          /// 去遍歷該使用者的所有公開清單
          for (var list in listsSnap.docs) {
            try {
              final restaurantsSnap = await list.reference
                  .collection(CollectionNames.restaurants)
                  .get();

              for (var resDoc in restaurantsSnap.docs) {
                final data = resDoc.data();

                final restaurant = Restaurant(
                  listID: list.id,
                  restaurantID: resDoc.id,
                  name: data[RestaurantFields.name] as String,
                  description: data[RestaurantFields.description] as String,
                  address: data[RestaurantFields.address] as String,
                  geoHash: data[RestaurantFields.geoHash] as String,
                  location: data[RestaurantFields.location] as GeoPoint,
                  type: data[RestaurantFields.type] as String,
                  price: data[RestaurantFields.price] as String,
                  hasAC: data[RestaurantFields.hasAC] as bool,
                  creatTime: data[RestaurantFields.creatTime] as Timestamp?,
                  updateTime: data[RestaurantFields.updateTime] as Timestamp?,
                );
                response.restaurants.add(restaurant);
              }
            } on FirebaseException catch (e) {
              logger.w('讀取餐廳資料錯誤: $e');
              continue; // 忽略這個 list, 繼續處理其他清單
            } catch (e) {
              logger.w('未知錯誤讀取餐廳資料: $e');
              continue;
            }
          }
        } on FirebaseException catch (e) {
          logger.w('讀取使用者清單錯誤: $e');
          continue; // 忽略這個使用者
        } catch (e) {
          logger.w('未知錯誤讀取使用者清單: $e');
          continue;
        }
      }

      response.success = true;
      response.message = '成功取得附近使用者的餐廳資料';
    } on FirebaseException catch (e) {
      logger.w('Firestore 查詢失敗: $e');
      response.message = '資料庫錯誤：${e.message}';
    } catch (e) {
      logger.w('探索功能未知錯誤: $e');
      response.message = '探索功能錯誤：$e';
    }

    return response;
  }

  static Future<void> saveLocation() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      logger.i('使用者未登入');
      return;
    }

    final userId = user.uid;
    try{
      final pos = await determinePosition();
      final geoHash = geoHasher.encode(pos.longitude, pos.latitude, precision: 5);
      await FirebaseFirestore.instance
        .collection(CollectionNames.users)
        .doc(userId)
        .update({
          UserFileds.location: GeoPoint(pos.latitude, pos.longitude),
          UserFileds.geoHash: geoHash,
        });
      logger.i('成功記錄 $userId 的位置');
    } on FirebaseException catch (e) {
      logger.w('Can not save location, FireStore error $e');
    } catch (e) {
      logger.w('Can not save location, Unknown error $e');
    }
  }

  /// 更新個人餐廳資訊
  static Future<UpdateRestaurantResponse> updateRestaurant({
    required String restaurantID,
    required String listID,
    required Map<String, dynamic> updates,
  }) async {
    final response = UpdateRestaurantResponse(success: false, message: '');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      response.message = '尚未登入，無法更新餐廳資訊';
      return response;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final restaurantRef = firestore
          .collection(CollectionNames.personalLists)
          .doc(listID)
          .collection(CollectionNames.restaurants)
          .doc(restaurantID);

      // 檢查餐廳是否存在
      final restaurantSnapshot = await restaurantRef.get();
      if (!restaurantSnapshot.exists) {
        logger.w('Restaurant does not exist: $restaurantID in list: $listID');
        response.message = '更新餐廳失敗，該餐廳並未存在: $restaurantID';
        return response;
      }
      
      if (updates.containsKey('address')) {
        final address = updates['address'];
        try {
          final geoResult = await convertAddressToGeohash(address.trim());
          updates[RestaurantFields.geoHash] = geoResult['geohash'];
          updates[RestaurantFields.location] = GeoPoint(geoResult['latitude'], geoResult['longitude']);
        } catch (e) {
          logger.w('Add restaurantt failed.\nLocation error $e');
          response.message = '地址查詢失敗：請輸入正確的地址';
          return response;
        }
      }

      // 添加更新時間
      final updatedData = {
        ...updates,
        RestaurantFields.updateTime: FieldValue.serverTimestamp(),
      };

      // 更新餐廳資訊
      await restaurantRef.update(updatedData);
      DocumentReference doc = FirebaseFirestore.instance
        .collection(CollectionNames.personalLists)
        .doc(listID)
        .collection(CollectionNames.restaurants)
        .doc(restaurantID);
      response.doc = doc;

      logger.i('Update restaurant: $restaurantID in list: $listID with data: ${updatedData.toString()} successfully');
      response.success = true;
      response.message = '成功更新餐廳資訊';
    } on FirebaseException catch (e) {
      logger.w('Update restaurant failed.\nFirestore error: $e');
      response.message = '無法更新餐廳資訊: ${e.message}';
    } catch (e) {
      logger.w('Update restaurant failed.\nUnknown error: $e');
      response.message = '未知錯誤: $e';
    }
    return response;
  }

  /// 透過 listID，獲取該清單的共享使用者資訊
  static Future<GetSharedUsersResponse> getSharedUser({
    required String listID,
  }) async {
    final response = GetSharedUsersResponse(success: false, message: '');
    response.usersList = [];
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      response.message = '尚未登入，無法新增共享使用者';
      return response;
    }

    try {
      DocumentSnapshot listDoc = await FirebaseFirestore.instance
        .collection(CollectionNames.personalLists)
        .doc(listID)
        .get();

      if (!listDoc.exists) {
        response.message = '找不到指定的清單';
        return response;
      }

      final shareWithData = listDoc.data() as Map<String, dynamic>?;
      List<String> shareWithList = List<String>.from(shareWithData?[PersonalListFields.shareWith] ?? []);

      List<Map<String, dynamic>> usersList = [];
      for (String userId in shareWithList) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(CollectionNames.users)
          .doc(userId)
          .get();

        if (userDoc.exists) {
          usersList.add({
            PersonalListFields.userID: userId,
            UserFileds.email: userDoc[UserFileds.email] ?? '未知',
            UserFileds.userName: userDoc[UserFileds.userName] ?? '未知',
          });
        }
      }
      response.success = true;
      response.message = '成功獲取共享使用者資訊';
      response.usersList = usersList;

    } catch(e) {
      logger.w('Get shared user failed.\nUnknown error $e');
      response.message = '獲取共享使用者失敗：$e';
    }
    return response;
  }

  /// 透過 email，新增個人清單裡的共享使用者
  static Future<AddSharedUserByEmailResponse> addSharedUserByEmail({
    required String listID,
    required String email,
  }) async {
    final response = AddSharedUserByEmailResponse(success: false, message: '');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      response.message = '尚未登入，無法新增共享使用者';
      return response;
    }

    try {
      QuerySnapshot queryUser = await FirebaseFirestore.instance
        .collection(CollectionNames.users)
        .where(UserFileds.email, isEqualTo: email)
        .get();

      if (queryUser.docs.isEmpty) {
        response.message = '找不到使用此電子郵件的使用者';
        return response;
      }

      if (queryUser.docs.length > 1) {
        response.message = '找到多個使用該電子郵件的使用者，請聯繫開發團隊';
        return response;
      }

      DocumentSnapshot userDoc = queryUser.docs.first;
      String userId = userDoc.id;

      DocumentReference listRef = FirebaseFirestore.instance
        .collection(CollectionNames.personalLists)
        .doc(listID);

      DocumentSnapshot listDoc = await listRef.get();

      if (!listDoc.exists) {
        response.message = '找不到指定的清單';
        return response;
      }

      final shareWithData = listDoc.data() as Map<String, dynamic>?;
      List<String> shareWithList = List<String>.from(shareWithData?[PersonalListFields.shareWith] ?? []);

      if (shareWithList.contains(userId)) {
        response.message = '此使用者已在共享列表中';
        return response;
      }

      await listRef.update({
        PersonalListFields.shareWith: FieldValue.arrayUnion([userId]),
      });

      logger.i('Add shared user: $email successfully from list: $listID');
      response.success = true;
      response.message = '成功新增共享使用者';

    } catch (e) {
      logger.w('Add shared user failed.\nUnknown error $e');
      response.message = '新增共享使用者失敗：$e';
    }
    return response;
  }

  /// 從個人清單中移除共享使用者
  static Future<RemoveSharedUserByEmailResponse> removeSharedUser({
    required String listID,
    required String userID,
  }) async {
    final response = RemoveSharedUserByEmailResponse(success: false, message: '');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      response.message = '尚未登入，無法移除共享使用者';
      return response;
    }

    try {
      DocumentSnapshot listDoc = await FirebaseFirestore.instance
        .collection(CollectionNames.personalLists)
        .doc(listID)
        .get();

      if (!listDoc.exists) {
        response.message = '找不到指定的清單';
        return response;
      }

      final shareWithData = listDoc.data() as Map<String, dynamic>?;
      List<String> shareWithList = List<String>.from(shareWithData?[PersonalListFields.shareWith] ?? []);

      if (!shareWithList.contains(userID)) {
        response.message = '此使用者不在共享列表中';
        return response;
      }

      await FirebaseFirestore.instance
          .collection(CollectionNames.personalLists)
          .doc(listID)
          .update({
        PersonalListFields.shareWith: FieldValue.arrayRemove([userID]),
      });

      logger.i('Remove shared user: $userID successfully from list: $listID');
      response.success = true;
      response.message = '成功移除共享使用者';

    } catch (e) {
      logger.w('Remove shared user failed.\nUnknown error $e');
      response.message = '移除共享使用者失敗：$e';
    }
    return response;
  }

  /// 以食會友：創建活動功能
  static Future<EventResponse> addNewEvent(Event e) async {
    var response = EventResponse(success: false, message: '');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      response.message = '尚未登入，無法創建活動';
      return response;
    }

    try {
        
        final userName = await FirebaseService.getUserName();
        
        // 把餐廳依照地址轉成經緯度和 geoHash, 但結果不是很準 QQ
        final geoInfo = await convertAddressToGeohash(e.address);
        final data = {
          ...e.toMap(), // 把傳入的 evnet 資訊展開成 dict, 和欄位包在一起 add
          EventFields.geoHash:    geoInfo['geohash'],
          EventFields.location:   GeoPoint(geoInfo['latitude'], geoInfo['longitude']),
          EventFields.participants: [user.uid],
          EventFields.participantNames: [userName],
        };
        await FirebaseFirestore.instance
        .collection(CollectionNames.events)
        .add(data);
        
      logger.i('${user.displayName} 成功創建活動 ${e.title}');
      response.success = true;
      response.message = '成功創建活動: ${e.title}';
    } on FirebaseException catch (e) {
      logger.w('創建活動錯誤\nFirestore error: $e');
      response.message = '無法創建活動';
    }
    catch (e) {
      logger.w('創建活動錯誤\nUnknown error: $e');
      response.message = '未知錯誤: $e';
    }
    return response;
  }

  /// 以食會友：使用者參加活動
  static Future<EventResponse> joinEvent({
    required String eventId,
  }) async {
    var response = EventResponse(success: false, message: '');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      response.message = '尚未登入，無法參加活動';
      return response;
    }

    try {
        final userName = await FirebaseService.getUserName();

        final docSnap = await FirebaseFirestore.instance
          .collection(CollectionNames.events)
          .doc(eventId)
          .get();

        final data = docSnap.data();
        final participants = (data?[EventFields.participants] as List?) ?? [];
        final limit = data?[EventFields.numberOfPeople] as int?;

        // 如果使用者已參加該活動
        if(participants.contains(user.uid)){
          response.message = '您已經參加此活動, 勿重複參加';
        }
        // 如果目前活動參加人數 == 限制人數 （額滿）
        else if(limit != null && participants.length >= limit){
          response.message = '活動人數已滿, 無法參加';
        }
        else {
          await FirebaseFirestore.instance
          .collection(CollectionNames.events)
          .doc(eventId)
          .update({
            EventFields.participants: FieldValue.arrayUnion([user.uid]),
            EventFields.participantNames: FieldValue.arrayUnion([userName]),
          });
          response.message = '成功參加活動';
        }

      logger.i('${user.displayName} 已成功參加活動 $eventId');
      response.success = true;
    } on FirebaseException catch (e) {
      logger.w('參加活動錯誤\nFirestore error: $e');
      response.message = '無法參加活動';
    }
    catch (e) {
      logger.w('參加活動錯誤\nUnknown error: $e');
      response.message = '未知錯誤: $e';
    }
    return response;
  }

  /// 以食會友：參與者取消參加
  static Future<EventResponse> cancelEvent({
    required String eventId,
  }) async {
    var response = EventResponse(success: false, message: '');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      response.message = '尚未登入，無法取消活動';
      return response;
    }

    try {
        final userName = await FirebaseService.getUserName();

        await FirebaseFirestore.instance
          .collection(CollectionNames.events)
          .doc(eventId)
          .update({
            EventFields.participants: FieldValue.arrayRemove([user.uid]),
            EventFields.participantNames: FieldValue.arrayRemove([userName]),
          });

      logger.i('${user.displayName} 已取消參加活動 $eventId');
      response.success = true;
      response.message = '已取消參加活動';
    } on FirebaseException catch (e) {
      logger.w('取消參加活動錯誤\nFirestore error: $e');
      response.message = '無法取消參加活動';
    }
    catch (e) {
      logger.w('取消參加活動錯誤\nUnknown error: $e');
      response.message = '未知錯誤: $e';
    }
    return response;
  }

  /// 以食會友：創建者可刪除活動
  static Future<EventResponse> deleteEvent({
    required String eventId,
  }) async {
    var response = EventResponse(success: false, message: '');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      response.message = '尚未登入，無法刪除活動';
      return response;
    }

    try {
        await FirebaseFirestore.instance
          .collection(CollectionNames.events)
          .doc(eventId)
          .delete();

      logger.i('已刪除活動 $eventId');
      response.success = true;
      response.message = '已刪除活動';
    } on FirebaseException catch (e) {
      logger.w('刪除活動錯誤\nFirestore error: $e');
      response.message = '無法刪除活動';
    }
    catch (e) {
      logger.w('刪除活動錯誤\nUnknown error: $e');
      response.message = '未知錯誤: $e';
    }
    return response;
  }

  /// 以食會友：創建者可編輯活動內容
  static Future<EventResponse> editEvent(Event e,) async {
    var response = EventResponse(success: false, message: '');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      response.message = '尚未登入，無法編輯活動';
      return response;
    }

    try {
        final geoInfo = await convertAddressToGeohash(e.address);
        final data = {
          ...e.toMap(), // 把傳入的 evnet 資訊展開成 dict, 和欄位包在一起 add
          EventFields.geoHash:    geoInfo['geohash'],
          EventFields.location:   GeoPoint(geoInfo['latitude'], geoInfo['longitude']),
        };

        await FirebaseFirestore.instance
          .collection(CollectionNames.events)
          .doc(e.id)
          .update(data);

      logger.i('${user.displayName} 已更新活動 ${e.title}');
      response.success = true;
      response.message = '已更新活動 ${e.title}';
    } on FirebaseException catch (e) {
      logger.w('更新活動錯誤\nFirestore error: $e');
      response.message = '無法更新活動';
    }
    catch (e) {
      logger.w('更新活動錯誤\nUnknown error: $e');
      response.message = '未知錯誤: $e';
    }
    return response;
  }

  static Future<String?> getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    String? userName;

    if (user == null) {
      return null;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
                      .collection(CollectionNames.users)
                      .doc(user.uid)
                      .get();

      final userData = userDoc.data();
      userName = userData![UserFileds.userName];
      
    } on FirebaseException catch (e) {
      logger.w('更新活動錯誤\nFirestore error: $e');
    }
    catch (e) {
      logger.w('更新活動錯誤\nUnknown error: $e');
    }

    return userName;
  }

  static final _favoritesRef = FirebaseFirestore.instance.collection('favorites_events');

  static Future<void> addFavoriteEvent({required String userId, required String eventId}) async {
    final docId = '${userId}_$eventId';
    await _favoritesRef.doc(docId).set({
      'userId': userId,
      'eventId': eventId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> removeFavoriteEvent({required String userId, required String eventId}) async {
    final docId = '${userId}_$eventId';
    await _favoritesRef.doc(docId).delete();
  }

  static Stream<List<String>> favoriteEventIdsStream(String userId) {
    return _favoritesRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc['eventId'] as String).toList());
  }
}

  