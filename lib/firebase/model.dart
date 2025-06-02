import 'package:cloud_firestore/cloud_firestore.dart';


class PersonalList {
  PersonalList({
    required this.listID,
    required this.title, 
    required this.userID,
    required this.userName,
    required this.isPublic,
    this.creatTime,
    this.updateTime,
    this.shareWith,
  });

  final String listID;
  final String title;
  final String userID;
  final String userName;
  final bool isPublic;
  final Timestamp? creatTime;
  final Timestamp? updateTime;
  final List<String>? shareWith;

  DateTime? get creatTimeAsDate => creatTime?.toDate();
  DateTime? get updateTimeAsDate => updateTime?.toDate();

  @override
  String toString() {
    return 'PersonalList(listID: $listID, title: $title, userID: $userID, '
          'userName: $userName, isPublic: $isPublic, creatTime: ${creatTimeAsDate ?? '未知'}, '
          'updateTime: ${updateTimeAsDate ?? '未知'}, shareWith: $shareWith))';
  }
}

class Restaurant {
  Restaurant({
    required this.listID,
    required this.restaurantID, 
    required this.name,
    required this.description,
    required this.address,
    required this.geoHash,
    required this.location,
    required this.type,
    required this.price,
    required this.hasAC,
    this.creatTime,
    this.updateTime,
  });

  final String listID;
  final String restaurantID;
  final String name;
  final String description;
  final String address;
  final String geoHash;
  final GeoPoint location;
  final String type;
  final String price;
  final bool hasAC;
  final Timestamp? creatTime;
  final Timestamp? updateTime;

  DateTime? get creatTimeAsDate => creatTime?.toDate();
  DateTime? get updateTimeAsDate => updateTime?.toDate();

  @override
  String toString() {
    return 'Restaurant(listID: $listID, restaurantID: $restaurantID, name: $name, description: $description, '
          'address: $address, geoHash: $geoHash, latitude: ${location.latitude}, longitude: ${location.longitude}, '
          'type: $type, price: $price, hasAC: $hasAC, '
          'creatTime: ${creatTimeAsDate ?? '未知'}, updateTime: ${updateTimeAsDate ?? '未知'})';
  }
}
