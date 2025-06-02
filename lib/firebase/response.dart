import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:what_for_meal/firebase/model.dart';

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

class DeletePersonalListResponse {
  DeletePersonalListResponse({required this.success, required this.message});

  bool success;
  String message;
}

class PpdateIsPublicOfListResponse {
  PpdateIsPublicOfListResponse({required this.success, required this.message});

  bool success;
  String message;
}


class AddRestaurantResponse {
  AddRestaurantResponse({required this.success, required this.message});

  bool success;
  String message;
  DocumentReference? doc;
}

class DeleteRestaurantResponse {
  DeleteRestaurantResponse({required this.success, required this.message});

  bool success;
  String message;
}

class ExploreResponse {
  ExploreResponse({required this.success, required this.message, required this.restaurants,});

  bool success;
  String message;
  List<Restaurant> restaurants;
}

class UpdateRestaurantResponse {
  UpdateRestaurantResponse({required this.success, required this.message});

  bool success;
  String message;
  DocumentReference? doc;
}

class GetSharedUsersResponse {
  GetSharedUsersResponse({required this.success, required this.message});

  bool success;
  String message;
  List<Map<String, dynamic>>? usersList;
}

class AddSharedUserByEmailResponse {
  AddSharedUserByEmailResponse({required this.success, required this.message});

  bool success;
  String message;
}

class RemoveSharedUserByEmailResponse {
  RemoveSharedUserByEmailResponse({required this.success, required this.message});

  bool success;
  String message;
}