import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../firebase/firebase_service.dart';

class PrimaryTextButton extends StatelessWidget {
  const PrimaryTextButton({super.key, this.icon, required this.label, required this.onPressed, this.style});

  final Widget? icon;
  final Widget label;
  final void Function()? onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton.icon(
      onPressed: onPressed,
      style: (style != null) ? style : TextButton.styleFrom(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: theme.textTheme.titleMedium,
      ),
      label: label,
    );
  }
}


class PrimaryElevatedButton extends StatelessWidget {
  const PrimaryElevatedButton({super.key, this.icon, required this.label, required this.onPressed, this.style});

  final Widget? icon;
  final Widget label;
  final void Function()? onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
      style: (style != null) ? style : ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.grey.shade400),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        iconColor: Colors.black,
        iconSize: 25,
        textStyle: theme.textTheme.titleMedium,
      ),
    );
  }
}


class WhiteElevatedButton extends StatelessWidget {
  const WhiteElevatedButton({super.key, this.icon, required this.label, required this.onPressed, this.style});

  final Widget? icon;
  final Widget label;
  final void Function()? onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
      style: (style != null) ? style : ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        iconColor: Colors.black,
        iconSize: 25,
        textStyle: theme.textTheme.titleMedium,
      ),
    );
  }
}

// 底部的 app bar
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomNavigationBar(
      backgroundColor: theme.colorScheme.secondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: '主頁',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore_rounded),
          label: '探索',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          activeIcon: Icon(Icons.people_rounded),
          label: '以食會友',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.manage_accounts),
          label: '帳戶資訊',
        ),
      ],
      iconSize: 28,
      currentIndex: currentIndex,
      selectedFontSize: 16,
      unselectedFontSize: 14,
      selectedItemColor: theme.colorScheme.primary,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: onTap,
    );
  }
}

// List veiw of homepage (我的清單/公開清單)
Widget buildListView({
  required List<QueryDocumentSnapshot> docs,
  required bool isMine,
  required FirebaseService service,
}) {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: docs.length,
    itemBuilder:  (context, index) {
      final data = docs[index].data() as Map<String, dynamic>;
      final title = data['title'] ?? '無標題';
      final listID = docs[index].id;

      return DismissibleCardItem(
        keyValue: listID,
        enabled: isMine,
        onDismissed: isMine
        ? () async {
              await service.deleteList(listID);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已刪除清單：$title')),
                    );
              }
        : () {},
        child: ListTile(
          leading: Icon(Icons.list_alt),
          title: Text(title),
          onTap: () {
            if (context.mounted && isMine) {
              context.goNamed('list', pathParameters: {
                'listID': listID,
                'listTitle': title,
              });
            }
            else if(context.mounted && !isMine){
              context.goNamed('sharedList', pathParameters: {
                'listID': listID,
                'listTitle': title,
              });
            }
          },
        )
      );
    }
  );
}
// dialog 出現的 確認/取消按鈕
class DialogActionButtons extends StatelessWidget {
  final Future<void> Function() onConfirm;
  final Future<void> Function()? onCancel;
  final String confirmText;
  final String cancelText;

  const DialogActionButtons({
    super.key,
    required this.onConfirm,
    // optional text
    this.onCancel,
    this.confirmText = '確定',
    this.cancelText = '取消',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () async {
            if (onCancel != null) {
              await onCancel!();
            } else {
              Navigator.of(context).pop(); // 預設行為
            }
          },
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () async {
            await onConfirm();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}

// 清單/餐廳向右刪除
class DismissibleCardItem extends StatelessWidget{
  final String keyValue;
  final VoidCallback onDismissed;
  final Widget child;
  final EdgeInsets margin;
  final bool enabled;

  const DismissibleCardItem({
    super.key,
    required this.keyValue,
    required this.onDismissed,
    required this.child,
    this.enabled = true,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });
  
  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return Card(margin: margin, child: child);
    }
    return Dismissible(
      key: Key(keyValue),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) => onDismissed(),
      child: Card(
        margin: margin,
        child: child,
      ),
    );
  }
}