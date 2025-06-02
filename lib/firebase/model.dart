import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class PersonalList {
  PersonalList({
    required this.listID,
    required this.title, 
    required this.userID,
    required this.userName,
    required this.isPublic,
    this.creatTime,
    this.updateTime,
  });

  final String listID;
  final String title;
  final String userID;
  final String userName;
  final bool isPublic;
  final Timestamp? creatTime;
  final Timestamp? updateTime;

  DateTime? get creatTimeAsDate => creatTime?.toDate();
  DateTime? get updateTimeAsDate => updateTime?.toDate();

  @override
  String toString() {
    return 'PersonalList(listID: $listID, title: $title, userID: $userID, '
          'userName: $userName, isPublic: $isPublic, creatTime: ${creatTimeAsDate ?? '未知'}, '
          'updateTime: ${updateTimeAsDate ?? '未知'})';
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

class Event {
  final String id;
  final String title;
  final String goal;
  final String description;
  final Timestamp dateTime;
  final int numberOfPeople;
  final String restoName;
  final String address;
  final List<String> participants;
  final List<String> participantNames;

  Event({
    required this.id,
    required this.title,
    required this.goal,
    required this.description,
    required this.dateTime,
    required this.numberOfPeople,
    required this.restoName,
    required this.address,
    required this.participants,
    required this.participantNames,
  });

  String get formattedDate => DateFormat('yyyy-MM-dd').format(dateTime.toDate());
  String get formattedTime => DateFormat('HH:mm').format(dateTime.toDate());
  
  Map<String, dynamic> toMap() {
    return {
      EventFields.title: title,
      EventFields.goal: goal,
      EventFields.description: description,
      EventFields.dateTime: dateTime,
      EventFields.numberOfPeople: numberOfPeople,
      EventFields.restoName: restoName,
      EventFields.address: address,
      EventFields.participants: participants,
    };
  }
}