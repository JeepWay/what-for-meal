import "dart:math";
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
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
    if (restaurants.isEmpty) {
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
      return;
    }

    // 創建 StreamController 來控制轉盤選擇
    final StreamController<int> controller = StreamController<int>();
    final random = Random();
    final selectedIndex = random.nextInt(restaurants.length);
    controller.add(selectedIndex);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Center(
          child: const Text('隨機選擇餐廳')
        ),
        content: SizedBox(
          height: 300,
          width: 300,
          child: FortuneWheel(
            selected: controller.stream, // 綁定 Stream 控制選中項
            items: restaurants.asMap().entries
                .map((entry) => FortuneItem(
                      child: Text(entry.value.name,
                        style: theme.textTheme.labelLarge!.copyWith(
                          color: theme.colorScheme.onSecondary,
                        )
                      ),
                      style: FortuneItemStyle(
                        color: theme.colorScheme.secondaryContainer, // 切片背景色
                        borderColor: Colors.white, // 邊框色
                        borderWidth: 2, // 邊框寬度
                      ),
                    ))
                .toList(),
            rotationCount: 10, // 旋轉圈數，增加動畫效果
            duration: const Duration(seconds: 5), // 動畫持續時間
            onAnimationEnd: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => ShowRestaurantDialog(
                  restaurant: restaurants[selectedIndex],
                ),
              );
            },
          ),
        ),
      ),
    ).then((_) {
      controller.close();
    });
  }

  List<Widget> _getAppBarActions() {
    final theme = Theme.of(context);
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
        IconButton( // 隨機選擇
          icon: Icon(Icons.shuffle),
          tooltip: "隨機選擇餐廳",
          onPressed: randomChooseRestaurant,
        ),
        PopupMenuButton<String>(
          color: theme.colorScheme.secondary,
          position: PopupMenuPosition.under,
          onSelected: (String value) {
            if (value == 'add_restaurant') {
              showDialog(
                context: context,
                builder: (context) {
                  return AddRestaurantDialog(listID: widget.list.listID);
                }
              );
            } else if (value == 'publicize') {
              showDialog(
                context: context,
                builder: (context) {
                  return PublicizePersonalListDialog(list: widget.list);
                },
              );
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'add_restaurant',
              child: ListTile(
                leading: Icon(Icons.add_box),
                title: Text('新增餐廳'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'publicize',
              child: ListTile(
                leading: Icon(Icons.public),
                title: Text('公開清單'),
              ),
            ),
          ],
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
        IconButton( // 隨機選擇
          icon: Icon(Icons.shuffle),
          tooltip: "隨機選擇餐廳",
          onPressed: randomChooseRestaurant,
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
                onListSelected: (selectedList) async {
                  final res = await FirebaseService.addNewRestaurant(
                    listID: selectedList.listID,
                    name: restaurant.name, 
                    address: restaurant.address, 
                    description: restaurant.description, 
                    type: restaurant.type, 
                    price: restaurant.price, 
                    hasAC: restaurant.hasAC
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(res.success ? '成功新增 ${restaurant.name} 到 ${selectedList.title}' : res.message)),
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