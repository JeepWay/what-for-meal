import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'response.dart';
import '../logging/logging.dart';

class AppState extends ChangeNotifier {
  User? _user;
  User? get user => _user;
  bool get loggedIn => (_user != null);

  AppState() {
    init();
  }
  
  Future<void> init() async {
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  /// Email sign in
  Future<SignInWithEmailResponse> signInWithEmail({
    required String email,
    required String password
  }) async {
    final response = SignInWithEmailResponse(success: false, message: '');

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      response.success = true;
      response.message = '登入成功';
      response.user = credential.user;
      _user = credential.user;

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
  Future<SignInWithGoogleResponse> signInWithGoogle() async {
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
        .collection('users')
        .doc(credential.user!.uid)
        .set({
          'username': credential.user!.displayName,
          'email': credential.user!.email,
          'lastLogin': FieldValue.serverTimestamp(),
        });

      response.success = true;
      response.message = '登入成功';
      response.user = credential.user;
      _user = credential.user;

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
  Future<SignUpWithEmailResponse> signUpWithEmail({
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
        .collection('users')
        .doc(credential.user!.uid)
        .set({
          'username': username,
          'email': email,
          'createdAt': Timestamp.now(),
          'lastLogin': FieldValue.serverTimestamp(),
        });

      response.success = true;
      response.message = '註冊成功，將轉移到主頁面';
      response.user = credential.user;
      _user = credential.user;

    } on FirebaseAuthException catch (e) {
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

  /// Email reset password
  Future<ResetPasswordWithEmailResponse> resetPasswordWithEmail({
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

  /// sign out the current user
  Future<void> signOut() async {
    try {
      if (_user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .set({
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      await FirebaseAuth.instance.signOut();
      _user = null;   // manually set to null due to authStateChanges delay
      notifyListeners();
    } catch (e) {
      logger.w('Sign out error: $e');
    }
  }
}