import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:what_for_meal/firebase/constants.dart';

import '../firebase/firebase_service.dart';
import '../firebase/model.dart';
import '../widgets/dialog.dart';
import '../widgets/card.dart';

class RestaurantsListScreen extends StatefulWidget {

  const RestaurantsListScreen({
    super.key, 
    required this.list, 
    required this.editable
  });

  final PersonalList list;
  final bool editable;

  @override
  State<RestaurantsListScreen> createState() => _RestaurantsListScreenState();
}

class _RestaurantsListScreenState extends State<RestaurantsListScreen> {
  List<Widget> _getAppBarActions() {
    if (widget.editable) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.info),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '點擊餐聽可查看餐廳的詳細資訊\n左滑餐聽可刪除該清單',
                  textAlign: TextAlign.center,
                ),
                duration: Duration(seconds: 3),
                showCloseIcon: true,
              ),
            );
          },
        ),
        IconButton(   // 新增餐廳
          icon: Icon(Icons.add_box),
          tooltip: "新增餐廳",
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AddRestaurantDialog(listID: widget.list.listID);
              }
            );
          },
        ),
        IconButton( // 公開清單
          icon: Icon(Icons.public),
          tooltip: "公開清單",
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return PublicizePersonalListDialog(list: widget.list);
              }
            );
          },
        ),
        IconButton( // 隨機選擇
          icon: Icon(Icons.shuffle),
          tooltip: "隨機選擇餐廳",
          onPressed: () {
          },
        ),
        IconButton( // 篩選器
          icon: Icon(Icons.filter_list_alt),
          tooltip: "設置篩選條件",
          onPressed: () {
          },
        ),
      ];
    } else {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.info),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '點擊餐聽可查看餐廳的詳細資訊',
                  textAlign: TextAlign.center,
                ),
                duration: Duration(seconds: 3),
                showCloseIcon: true,
              ),
            );
          },
        ),
        IconButton( // 隨機選擇
          icon: Icon(Icons.shuffle),
          tooltip: "隨機選擇餐廳",
          onPressed: () {
          },
        ),
        IconButton( // 篩選器
          icon: Icon(Icons.filter_list_alt),
          tooltip: "設置篩選條件",
          onPressed: () {
          },
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list.title),
        centerTitle: false,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: _getAppBarActions(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(CollectionNames.personalLists)
            .doc(widget.list.listID)
            .collection(CollectionNames.restaurants)
            .snapshots(),
        builder: (context, snapshot) {
          final theme = Theme.of(context);
          if (snapshot.hasError) {
            return Center(child: Text('發生錯誤：${snapshot.error}', style: theme.textTheme.titleLarge));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final restaurants = snapshot.data!.docs;
          if (restaurants.isEmpty) {
            return Center(child: Text('此清單中沒有餐廳', style: theme.textTheme.titleLarge,));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurantDoc = restaurants[index];
              final data = restaurantDoc.data() as Map<String, dynamic>;
              final restaurant = Restaurant(
                listID: widget.list.listID, 
                restaurantID: restaurantDoc.id,
                name: data[RestaurantFields.name] as String? ?? '無標題', 
                description: data[RestaurantFields.description] as String? ?? '沒有描述', 
                address: data[RestaurantFields.address] as String? ?? '地址未知',
                geoHash: data[RestaurantFields.geoHash] as String? ?? '無標題',
                location: data[RestaurantFields.location] as GeoPoint? ?? GeoPoint(0,0),
                type: data[RestaurantFields.type] as String? ?? '沒有提供價類型', 
                price: data[RestaurantFields.price] as String? ?? '沒有提供價格', 
                hasAC: data[RestaurantFields.hasAC] as bool? ?? false, 
                creatTime: data[RestaurantFields.creatTime] as Timestamp?,
                updateTime: data[RestaurantFields.updateTime] as Timestamp?,
              );
              return RestaurantDismissibleCard(
                restaurant: restaurant,
                dismissible: widget.editable,
                onDismissed: () async {
                  final response = await FirebaseService.deleteRestaurant(
                    listID: restaurant.listID, 
                    restaurantID: restaurant.restaurantID,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: response.success 
                          ? Text('已從清單中刪除該餐廳： ${restaurant.name}', textAlign: TextAlign.center,)
                          : Text(response.message, textAlign: TextAlign.center,),
                        duration: Duration (seconds: 3),
                        showCloseIcon: true,
                      ),
                    );
                  }
                },
                fromPersonal: widget.editable,
              );
            },
          );
        },
      ),
    );
  }
}