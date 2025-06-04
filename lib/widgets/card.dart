import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';
import '../firebase/model.dart';
import '../pages/restaurants_page.dart';
import '../widgets/dialog.dart';
import '../logging/logging.dart';

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
            Text('修改時間: ${list.updateTimeAsDate != null ? dateFormat.format(list.updateTimeAsDate!) : '未知'}'),
            Text('公開狀態: ${list.isPublic? '已公開' : '未公開'}'),
          ],
        ),
        subtitleTextStyle: theme.textTheme.titleSmall,
        onTap: () {
          Provider.of<AppState>(context, listen: false)
            .setSelectedListIDInMain(list.listID);
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
        confirmDismiss: (direction) async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) {
              return DoubleCheckDismissDialog(displayText: '確定要刪除這個清單嗎？',);
            },
          );
          logger.d('Confirm result for dismiss list: $result');
          return result ?? false;
        },
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
    required this.onListSelected,
    super.key,
  });

  final Restaurant restaurant;
  final bool dismissible;
  final Function? onDismissed;
  final Function? onListSelected;
  final bool fromPersonal;  // decide editable

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
        leading: Icon(Icons.storefront_outlined),
        title: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Text(restaurant.name, overflow: TextOverflow.ellipsis,)
            ),
            if (!fromPersonal) // 不是在我的清單中的餐廳才顯示
              Positioned(
                right: -10,
                top: -12,
                child: IconButton(
                  icon: Icon(Icons.favorite_rounded),
                  tooltip: '收藏到清單',
                  onPressed:() {
                    showDialog(
                      context: context,
                      builder: (context) => SelectListDialog(
                        onListSelected: onListSelected
                      )
                    );
                  },
                ),
              )
          ],
        ),
        titleTextStyle: theme.textTheme.titleLarge,
        subtitle: Column(
          crossAxisAlignment : CrossAxisAlignment.start,
          children: [
            Text('地址: ${restaurant.address}'),
            Text(
              '描述: ${restaurant.description}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 2,
              runSpacing: 6,
              alignment: WrapAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.restaurant_menu),
                    const SizedBox(width: 2,),
                    Text(restaurant.type),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_money),
                    const SizedBox(width: 2,),
                    Text(restaurant.price),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
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
          showDialog(
            context: context, 
            builder: (context) => ShowRestaurantDialog(restaurant: restaurant)
          );
        },
        onLongPress: () {
          if (fromPersonal) {
            showDialog(
              context: context,
              builder: (context) => EditRestaurantDialog(
                restaurant: restaurant,
              ),
            );
            logger.d('user onLongPress and show EditRestaurantDialog');
          }
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
        confirmDismiss: (direction) async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) {
              return DoubleCheckDismissDialog(displayText: '確定要刪除這個餐廳嗎？',);
            },
          );
          logger.d('Confirm result for dismiss restaurant: $result');
          return result ?? false;
        },
        onDismissed: (direction) => onDismissed!(),
        child: card,
      );
    }
  }
}

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.isCreator,
    required this.event,
    required this.onEdit,
    required this.onCancel,
    required this.onPlusOne,
    required this.onDelete,
    required this.favoriteEventIds,
    required this.onToggleFavorite,
  });

  final Event event;
  final bool isCreator;
  final Function? onEdit;
  final Function? onCancel;
  final Function? onPlusOne;
  final Function? onDelete;
  final List<String> favoriteEventIds;
  final Function(bool isCurrentlyFav)? onToggleFavorite;

  bool get isFavorited => favoriteEventIds.contains(event.id);

  String _getCountdownText(DateTime eventTime) {
    final now = DateTime.now();
    final diff = eventTime.difference(now);

    if (diff.isNegative) return '已開始';
    if (diff.inDays > 0) return '剩 ${diff.inDays} 天';
    if (diff.inHours > 0) return '剩 ${diff.inHours} 小時';
    if (diff.inMinutes > 0) return '剩 ${diff.inMinutes} 分';
    return '即將開始';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countdown = _getCountdownText(event.dateTime.toDate());
    final creatorName = event.participantNames.isNotEmpty
        ? event.participantNames.first
        : '未知';

    ButtonStyle filledStyle(Color bgColor) => FilledButton.styleFrom(
      backgroundColor: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );

    List<Widget> actionButtons = [
      Expanded(
        child: FilledButton.icon(
          icon: SizedBox(
            width: 20,
            child: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red : theme.colorScheme.onPrimary,
            ),
          ),
          label: Text(
            isFavorited ? '取消收藏' : '收藏',
            style: TextStyle(color: theme.colorScheme.onPrimary),
          ),
          style: filledStyle(theme.colorScheme.primary),
          onPressed: () => onToggleFavorite?.call(isFavorited),
        ),
      ),
    ];

    if (onPlusOne != null) {
      actionButtons.add(const SizedBox(width: 8));
      actionButtons.add(
        Expanded(
          child: FilledButton.icon(
            icon: const SizedBox(
              width: 20,
              child: Icon(Icons.exposure_plus_1, color: Colors.white),
            ),
            label: Text('參加', style: TextStyle(color: theme.colorScheme.onPrimary)),
            style: filledStyle(theme.colorScheme.primary),
            onPressed: () => onPlusOne!(),
          ),
        ),
      );
    }

    if (!isCreator && onCancel != null) {
      actionButtons.add(const SizedBox(width: 8));
      actionButtons.add(
        Expanded(
          child: FilledButton.icon(
            icon: const SizedBox(
              width: 20,
              child: Icon(Icons.exposure_minus_1, color: Colors.white),
            ),
            label: Text('取消參加', style: TextStyle(color: theme.colorScheme.onPrimary)),
            style: filledStyle(theme.colorScheme.primary),
            onPressed: () => onCancel!(),
          ),
        ),
      );
    }

    if (isCreator && onDelete != null) {
      actionButtons.add(const SizedBox(width: 8));
      actionButtons.add(
        Expanded(
          child: FilledButton.icon(
            icon: SizedBox(
              width: 20,
              child: Icon(Icons.delete, color: theme.colorScheme.onPrimary),
            ),
            label: Text('刪除', style: TextStyle(color: theme.colorScheme.onPrimary)),
            style: filledStyle(theme.colorScheme.error),
            onPressed: () => onDelete!(),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => EventDetailDialog(event: event),
        );
      },
      onLongPress: () {
        if (isCreator && onEdit != null) {
          onEdit!();
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        clipBehavior: Clip.hardEdge,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    countdown,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Text('時間: ${event.formattedDate} ${event.formattedTime}'),
              Text('地址: ${event.address}'),
              Text('人數：${event.participantNames.length} / ${event.numberOfPeople}'),
              Text('創建者：$creatorName'),
              const SizedBox(height: 12),
              Row(children: actionButtons),
            ],
          ),
        ),
      ),
    );
  }
}