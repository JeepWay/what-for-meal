import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class SignOutResponse {
  SignOutResponse({required this.success, required this.message});

  bool success;
  String message;
}


class ResetPasswordWithEmailResponse {
  ResetPasswordWithEmailResponse({required this.success, required this.message});

  bool success;
  String message;
}

class AddPersonalListResponse {
  AddPersonalListResponse({required this.success, required this.message});

  bool success;
  String message;
  DocumentReference? doc;
}

class AddRestaurantResponse {
  AddRestaurantResponse({required this.success, required this.message});

  bool success;
  String message;
  DocumentReference? doc;
}