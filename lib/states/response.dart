import 'package:firebase_auth/firebase_auth.dart';

class SignInWithEmailResponse {
  SignInWithEmailResponse({required this.success, required this.message});

  bool success;
  String message;
  User? user;
}

class SignUpWithEmailResponse {
  SignUpWithEmailResponse({required this.success, required this.message});

  bool success;
  String message;
  User? user;
}

class SignInWithGoogleResponse {
  SignInWithGoogleResponse({required this.success, required this.message});

  bool success;
  String message;
  User? user;
}

class ResetPasswordWithEmailResponse {
  ResetPasswordWithEmailResponse({required this.success, required this.message});

  bool success;
  String message;
}