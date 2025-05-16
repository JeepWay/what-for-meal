import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../firebase/firebase_service.dart';
import '../widgets/widgets.dart';
import '../utils/geolocation_utils.dart';

// 編輯/新增餐廳共用的 dialog
Future<void> showRestaurantDialog(
  BuildContext context, {
  required String listID,
  required FirebaseService service,
  QueryDocumentSnapshot? doc, // If doc is provided, it's editing mode.
}) async {
  // Initial the variables
  final isEdit = doc != null;
  final data = doc?.data() as Map<String, dynamic>?;
  final nameCtl = TextEditingController(text: data?['name'] as String? ?? '');
  final addrCtl = TextEditingController(text: data?['address'] as String? ?? '');
  final descCtl = TextEditingController(text: data?['description'] as String? ?? '');

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
                isEdit ? '編輯餐廳' : '新增餐廳',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtl, decoration: InputDecoration(labelText: '名稱')),

            TextButton.icon(
              onPressed: () {
                final name = nameCtl.text.trim();
                if (name.isEmpty) return;
                final url = generateGoogleMapLink(name);
                launchUrl(Uri.parse(url));
              },
              label: Text('自動生成 Google Map 連結',
                          style: TextStyle(color: Colors.grey),),
              icon: Icon(Icons.location_on),
            ),

            TextField(controller: addrCtl, decoration: InputDecoration(labelText: '地址')),
            SizedBox(height: 8),
            TextField(controller: descCtl, decoration: InputDecoration(labelText: '描述')),
            SizedBox(height: 16),
            // 寫 filter 的下拉選單
          ],
        ),
      ),
      actions: [
        DialogActionButtons(
          onConfirm: () async {
            final result = await convertAddressToGeohash(addrCtl.text.trim());
            final restaurantData = {
              'name': nameCtl.text.trim(),
              'address': addrCtl.text.trim(),
              'description': descCtl.text.trim(),
              'lat': result['latitude'],
              'lon': result['longitude'],
              'geohash': result['geohash'],
            };

            if(isEdit){
              await service.updateRestaurant(listID, doc.id, restaurantData);
              Navigator.of(context).pop();
            }
            else {
              await service.addRestaurant(listID, restaurantData);
              Navigator.of(context).pop();
            }
          }
        )
      ],
    ),
  );
}

// 設定篩選器（沒完成）
Future<void> showFilterDialog(
  BuildContext context, {
  required String listID,
  required FirebaseService service,
}) async {

  final filterZeroCtrl = TextEditingController();
  final filterOneCtrl = TextEditingController();
  final filterTwoCtrl = TextEditingController();

  
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('設定篩選器',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
              ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            TextField(controller: filterZeroCtrl, decoration: InputDecoration(labelText: '價格')),
            SizedBox(height: 16),
            TextField(controller: filterOneCtrl, decoration: InputDecoration(labelText: '冷氣')),
            SizedBox(height: 16),
            TextField(controller: filterTwoCtrl, decoration: InputDecoration(labelText: '類型')),
            SizedBox(height: 16),
            
          ],
        ),
      ),
      actions: [
        DialogActionButtons(
          onConfirm: () async {
            final filters = [
              filterZeroCtrl.text.trim(),
              filterOneCtrl.text.trim(),
              filterTwoCtrl.text.trim(),
            ];
          },
        ),
      ],
    ),
  );
}

// 清單設定成公開/非公開
Future<void> showPublicizeDialog(
  BuildContext context, {
  required String listID,
  required String listTitle,
  required FirebaseService service,
}) async {

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('公開「$listTitle」清單',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold,),
              ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('是否要公開當前清單內容，讓所有使用者皆可看到該清單，但不能更改。'),
      ),
      actions: [
        DialogActionButtons(
          onConfirm: () async {
            await service.updateList(listID, {'isPublic': true});
            Navigator.of(context).pop();
          },
          onCancel: () async {
            await service.updateList(listID, {'isPublic': false});
            Navigator.of(context).pop();
          },
          confirmText: '公開',
          cancelText: '不公開',
        ),
      ],
    ),
  );
}