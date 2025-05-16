import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../states/app_state.dart';
import '../firebase/firebase_service.dart';
import '../widgets/widgets.dart';
import '../widgets/dialog.dart';
import '../utils/geolocation_utils.dart';

class ListPage extends StatefulWidget{
  final String listID;
  final String listTitle;
  const ListPage({
    super.key,
    required this.listID,
    required this.listTitle,
  });

  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  int _selectedIndex = 0;
  late final FirebaseService firebaseService;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    firebaseService = FirebaseService(userID: uid);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showRestaurantDialog() => showRestaurantDialog(context, listID: widget.listID, service: firebaseService);
  void _showFilterDialog()    => showFilterDialog(context, listID: widget.listID, service: firebaseService);
  void _showPublicizeDialog() => showPublicizeDialog(context, listID: widget.listID, listTitle: widget.listTitle, service: firebaseService);
  void _onRandomChoice()      { /* 隨機選擇 */ }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index){
        case 0:
          if(mounted) context.go('/home');
          break;
        case 1:
          break;
        case 2:
          break;
        case 3:
          break;
    }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add_box),
              // 新增餐廳
              onPressed: () => _showRestaurantDialog(),
            ),
            IconButton(
              icon: Icon(Icons.public),
              // 公開清單
              onPressed: () => _showPublicizeDialog(),
            ),
            Spacer(),
            // 清單標題
            Text(widget.listTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Spacer(),
            // 隨機選擇
            IconButton(
              icon: Icon(Icons.casino),
              onPressed: () => _onRandomChoice(),
            ),
            IconButton(
              icon: Icon(Icons.filter_list_alt),
              // TODO Filter the displayed restaurant
              onPressed: () => _showFilterDialog(),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseService.watchRestaurantsInList(widget.listID),
        builder: (context, snapshot) {
          // if(snapshot.hasError) print(snapshot.error);
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if(docs.isEmpty){
            return Center(child: Text('尚未建立餐廳'),);
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, index){
              final data = docs[index].data() as Map<String, dynamic>;
              
              final name = data['name'] ?? "你沒有寫餐廳名字";
              final address = data['address'] ?? "沒寫地址是要怎麼去？？";
              final description = data['description'] ?? "還不快寫評價！！";

              return DismissibleCardItem(
                keyValue: docs[index].id,
                onDismissed: () async {
                  await firebaseService.deleteRestaurant(widget.listID, docs[index].id);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已刪除 $name')));
                },
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                   // 長按可編輯餐廳
                  onLongPress: () => showRestaurantDialog(
                    context,
                    listID: widget.listID,
                    service: firebaseService,
                    doc: docs[index],
                  ),
                  child: ListTile(
                    leading: IconButton(
                      icon: const Icon(Icons.map),
                      onPressed: () {
                        launchUrl(Uri.parse(generateGoogleMapLink(address)));
                      },
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("地址：$address"),
                        Text("備註：$description"),
                      ],
                    ),
                  ),
                  ),
              );
            },
          );
        }
      ),
      bottomNavigationBar: AppBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        )
    );
  }

}