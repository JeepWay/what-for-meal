import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';

import '../logging/logging.dart';
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
}

