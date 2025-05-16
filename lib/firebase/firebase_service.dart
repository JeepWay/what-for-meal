/*
一些和後端溝通的函式
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class FirebaseService {
  final String userID;
  FirebaseService({required this.userID});

  // 主頁新增清單
  Future<void> addNewList(String title, List<String> filter) async {
    await FirebaseFirestore.instance
    .collection('personal_lists')
    .add({
      'createdAt': FieldValue.serverTimestamp(),
      'isPublic': false,
      'title': title,
      'userID': userID,
      'filter': filter,
    });
  }
  
  // 在主頁立即顯示清單
  Stream<QuerySnapshot> watchMyLists() {
    return FirebaseFirestore.instance
            .collection('personal_lists')
            .where('userID', isEqualTo:  userID)
            .orderBy('createdAt', descending: true)
            .snapshots();
  }

  // 刪除清單
  Future<void> deleteList(String docID) async {
    /* only delte the doc of the list (i.e the restaurants won't be deleted)
    await FirebaseFirestore.instance
            .collection('personal_lists')
            .doc(docID)
            .delete();
     */
    final firestore = FirebaseFirestore.instance;
    final listRef = firestore.collection('personal_lists').doc(docID);
    final restaurantsRef = listRef.collection('restaurants');
    
    final batch = firestore.batch();
    final restaurantSnapshot = await restaurantsRef.get();
    // Delete the restaurants of the list
    for (final doc in restaurantSnapshot.docs) {
      batch.delete(restaurantsRef.doc(doc.id));
    }
    // Delete the list
    batch.delete(listRef);
    await batch.commit();
  }

  // 修改清單（eg: isPublic）
  Future<void> updateList(String docID, Map<String, dynamic> updates) async {
    await FirebaseFirestore.instance
            .collection('personal_lists')
            .doc(docID)
            .update(updates);
  }
  
  // 立即顯示清單中的餐廳
  Stream<QuerySnapshot> watchRestaurantsInList(String listID) {
    return FirebaseFirestore.instance
      .collection('personal_lists')
      .doc(listID)
      .collection('restaurants')
      .snapshots();
  }

  // 修改餐廳資料
  Future<void> updateRestaurant(String listID, String restDocID, Map<String, dynamic> update) async{
    await FirebaseFirestore.instance
      .collection('personal_lists')
      .doc(listID)
      .collection('restaurants')
      .doc(restDocID)
      .update(update);
  }

  // 刪除餐廳
  Future<void> deleteRestaurant(String listID, String restDocID) async{
    await FirebaseFirestore.instance
      .collection('personal_lists')
      .doc(listID)
      .collection('restaurants')
      .doc(restDocID)
      .delete();
  }

  // 新增餐廳
  Future<void> addRestaurant(String listID, Map<String, dynamic> data) async {
  await FirebaseFirestore.instance
        .collection('personal_lists')
        .doc(listID)
        .collection('restaurants')
        .add(data);
  }

  // 在公開清單中選 100 筆
  Future<List<QueryDocumentSnapshot>> getSharedLists() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('personal_lists')
        .where('isPublic', isEqualTo: true)
        .get();

    final docs = snapshot.docs;
    if (docs.length <= 100) {
      return docs;
    }

    docs.shuffle(Random());
    return docs.take(100).toList();
  }
}
