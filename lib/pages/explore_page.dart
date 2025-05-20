import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:what_for_meal/utils/geolocation_utils.dart';
import '../states/app_state.dart';
import '../firebase/firebase_service.dart';
import '../utils/location_helper.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late Future<Position> _posFuture;

  @override
  void initState() {
    super.initState();
    _posFuture = determinePosition();
  }

  Map<String, List<Map<String, dynamic>>> randomRecommend(List<Map<String, dynamic>> restaurants) {
    // 依 category 分組
    final Map<String, List<Map<String, dynamic>>> byCategory = {};
    for (var r in restaurants) {
      final cat = r['type'] as String? ?? '其他';
      byCategory.putIfAbsent(cat, () => []).add(r);
    }
    // 計算每個 category 分配到的餐廳數量
    final total = restaurants.length;
    final random = Random();
    final recommended = <String, List<Map<String, dynamic>>> {};
    byCategory.forEach((cat, restos) {
      final num = ((restos.length) / total * 30).round();
      recommended.putIfAbsent(cat, () => []);
      // 隨機抽出 num 間餐廳
      for(int i=0; i<num && restos.isNotEmpty; i++){
        recommended[cat]!.add(restos.removeAt(random.nextInt(restos.length)));
      }
    });

    return recommended;
  }

  Future<Widget> buildExploreResults(
      BuildContext context,
      String uid,
      GeoPoint center,
      FirebaseService service,
  ) async {
    int searchRadius = 500;

    while (true) {
      final userIds = await service.fetchNearbyUserIds(uid, center, searchRadius, precision: 5);
      print(userIds);
      final restaurants = userIds.isNotEmpty
                          ? (await service.collectRestaurantsFromUsers(userIds))
                              .map((e) => Map<String, dynamic>.from(e)) // key 強制轉型成 String
                              .toList()
                          : <Map<String, dynamic>>[];

      if (userIds.isEmpty || restaurants.isEmpty) {
        final result = await showExploreDialog(context);
        
        if (result == null || result.isEmpty) {
          return const Center(child: Text('未輸入搜尋半徑，探索已取消'));
        }
        final newRadius = int.tryParse(result);
        if (newRadius == null || newRadius <= 0 || newRadius > 5000) {
          return const Center(child: Text('半徑大小需為 0~5000 公尺'));
        }
        searchRadius = newRadius;
        continue;
      }
      // 抓到資料可以顯示
      final recommendedRestos = randomRecommend(restaurants);
      return ListView(
        padding: const EdgeInsets.all(8),
        children: recommendedRestos.entries.map((entry) {
          final category = entry.key;
          final list = entry.value;
          return ExpansionTile(
            title: Text('$category (${list.length})'),
            children: list.map((r) {
              return Card(
                child: ListTile(
                  leading: IconButton(
                    icon: const Icon(Icons.map),
                    onPressed: () {
                      launchUrl(Uri.parse(generateGoogleMapLink(r['address'])));
                    },
                  ),
                  title: Text(
                    r['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("地址：${r['address']}"),
                      Text("備註：${r['description']}"),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AppState>(context).user;
    if (user == null) {
      return const Center(child: Text('請先登入以查看推薦餐廳'));
    }
    final uid = user.uid;
    final service = FirebaseService(userID: uid);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => setState(() {
            _posFuture = determinePosition();
          }),
          icon: Icon(Icons.my_location),
          tooltip: '重新定位',
        ),
        title: Text('探 索'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: FutureBuilder<Position>(
        future: _posFuture,
        builder: (context, locSnap) {
          if (locSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (locSnap.hasError || locSnap.data == null) {
            return Center(child: Text('定位失敗：${locSnap.error}'));
          }
          final pos = locSnap.data!;
          final center = GeoPoint(pos.latitude, pos.longitude);
          print('${center.latitude}, ${center.longitude}');
          return FutureBuilder<Widget>(
            future: buildExploreResults(context, uid, center, service),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Text('錯誤：${snap.error}'));
              }
              return snap.data!;
            },
          );
        }
      ),
    );
  }
}
