import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';

import '../logging/logging.dart';
import '../utils/geolocation_utils.dart';
import 'firebase_options.dart';
import 'response.dart';
import 'constants.dart';

class FirebaseService {
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
  
}

