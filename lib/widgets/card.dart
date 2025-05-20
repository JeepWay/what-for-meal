import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../firebase/model.dart';
import '../pages/restaurants_page.dart';

class ListDismissibleCard extends StatelessWidget{

  const ListDismissibleCard({
    required this.list,
    required this.dismissible,
    required this.onDismissed,
    required this.fromPersonal,
    super.key,
  });

  final PersonalList list;
  final bool dismissible;
  final Function? onDismissed;
  final bool fromPersonal;  // decide editable

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
        leading: Icon(Icons.list_alt),
        title: Text(list.title),
        titleTextStyle: theme.textTheme.titleLarge,
        subtitle: Column(
          crossAxisAlignment : CrossAxisAlignment.start,
          children: [
            Text('創建者: ${list.userName}'),
            Text('修改時間: ${list.creatTimeAsDate != null ? dateFormat.format(list.creatTimeAsDate!) : '未知'}'),
            Text('公開狀態: ${list.isPublic? '已公開' : '未公開'}'),
          ],
        ),
        subtitleTextStyle: theme.textTheme.titleSmall,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RestaurantsListScreen(list: list, editable: fromPersonal),
            ),
          );
        },
      ),
    );

    if (!dismissible) {
      return card;
    } else {
      return Dismissible(
        key: Key(list.listID),
        direction: DismissDirection.endToStart,
        background: Container(  // for delete animation
          color: theme.colorScheme.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Icon(Icons.delete, color: theme.colorScheme.onError),
        ),
        onDismissed: (direction) => onDismissed!(),
        child: card,
      );
    }
  }
}


class RestaurantDismissibleCard extends StatelessWidget {
  const RestaurantDismissibleCard({
    required this.restaurant,
    required this.dismissible,
    required this.onDismissed,
    required this.fromPersonal,
    super.key,
  });

  final Restaurant restaurant;
  final bool dismissible;
  final Function? onDismissed;
  final bool fromPersonal;  // decide editable

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
        leading: Icon(Icons.storefront_outlined),
        title: Text(restaurant.name),
        titleTextStyle: theme.textTheme.titleLarge,
        subtitle: Column(
          crossAxisAlignment : CrossAxisAlignment.start,
          children: [
            Text('地址: ${restaurant.address}'),
            Text('描述: ${restaurant.description}'),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu),
                    const SizedBox(width: 2,),
                    Text(restaurant.type),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.attach_money),
                    const SizedBox(width: 2,),
                    Text(restaurant.price),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ac_unit),
                    const SizedBox(width: 2,),
                    Text(restaurant.hasAC ? '有冷氣' : '沒冷氣'),
                  ],
                ),
              ],
            ),
          ],
        ),
        subtitleTextStyle: theme.textTheme.titleSmall,
        onTap: () {
          // TODO 點擊餐廳卡片，跳出新的頁面，顯示更多內容、提供修改、以 Map 開啟、返回餐廳列表等功能
        },
      ),
    );

    if (!dismissible) {
      return card;
    } else {
      return Dismissible(
        key: Key(restaurant.restaurantID),
        direction: DismissDirection.endToStart,
        background: Container(  // for delete animation
          color: theme.colorScheme.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Icon(Icons.delete, color: theme.colorScheme.onError),
        ),
        onDismissed: (direction) => onDismissed!(),
        child: card,
      );
    }
  }
}