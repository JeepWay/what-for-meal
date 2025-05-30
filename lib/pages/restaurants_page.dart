import "dart:math";
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';
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

  void randomChooseRestaurant() {
    final restaurants = Provider.of<AppState>(context, listen: false).restaurantsInMain;
    if (restaurants.isNotEmpty) {
      final random = Random();
      final choice = restaurants[random.nextInt(restaurants.length)];
      showDialog(
        context: context, 
        builder: (context) => ShowRestaurantDialog(restaurant: choice)
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '餐廳列表為空，沒有可選擇的餐廳，試試看更改篩選條件',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 3),
          showCloseIcon: true,
        ),
      );
    }
  }

  List<Widget> _getAppBarActions() {
    if (widget.editable) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.info),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '點擊餐廳可查看餐廳的詳細資訊\n左滑餐廳可刪除該清單\n長按餐廳可編輯該清單',
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
          onPressed: randomChooseRestaurant,
        ),
        IconButton( // 篩選器
          icon: Icon(Icons.filter_list_alt),
          tooltip: "設置篩選條件",
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return EditFilterInMainDialog();
              }
            );
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
          onPressed: randomChooseRestaurant,
        ),
        IconButton( // 篩選器
          icon: Icon(Icons.filter_list_alt),
          tooltip: "設置篩選條件",
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return EditFilterInMainDialog();
              }
            );
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
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final personalRestaurants = appState.restaurantsInMain;
          if (personalRestaurants.isEmpty) {
            return Center(
              child: Text('此清單中沒有餐廳', style: theme.textTheme.titleLarge,)
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: personalRestaurants.length,
            itemBuilder: (context, index) {
              final restaurant = personalRestaurants[index];
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
                          ? Text('已從清單中刪除該餐廳： ${restaurant.name}', textAlign: TextAlign.center)
                          : Text(response.message, textAlign: TextAlign.center),
                        duration: Duration(seconds: 3),
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