import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:what_for_meal/firebase/model.dart';
import 'package:what_for_meal/utils/geolocation_utils.dart';
import 'package:what_for_meal/widgets/card.dart';
import '../logging/logging.dart';

import '../states/app_state.dart';
import '../firebase/firebase_service.dart';
import '../utils/location_helper.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _radiusController = TextEditingController(text: '500');
  Position? _position;
  bool _loading = false;
  List<Restaurant> _restaurants = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    try {
      final pos = await determinePosition();
      logger.i(pos);
      setState(() => _position = pos);
    } catch (e) {
      setState(() => _errorMessage = '定位失敗：$e');
    }
  }

  // 從後端抓資料, 結果存在 _restaurants
  Future<void> _search() async {
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('尚未定位，無法探索'))
      );
      return;
    }

    final radius = int.tryParse(_radiusController.text);
    if (radius == null || radius <= 0 || radius > 5000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('半徑需介於 1~5000 公尺'))
      );
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _restaurants.clear();
    });

    final center = GeoPoint(_position!.latitude, _position!.longitude);
    try {
      final res = await FirebaseService.fetchNearbyUserRestaurants(
        center, radius, precision: 5
      );
      
      setState(() {
        _restaurants = res.restaurants;
        // case 1. 搜尋成功, 但沒有其他使用者 or 該使用者沒有建立餐廳
        if (_restaurants.isEmpty && res.success) {
          _errorMessage = '方圓 ${radius}m 內沒有資料，請增加搜尋半徑來探索美食！';
        }
        else if (!res.success){
          _errorMessage = res.message;
        }
      });
    } catch (e) {
      setState(() => _errorMessage = '探索失敗：$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Map<String, List<Restaurant>> _randomRecommend(List<Restaurant> list) {
    final byCat = <String, List<Restaurant>>{};
    for (var r in list) {
      final cat = r.type;
      byCat.putIfAbsent(cat, () => []).add(r);
    }
    final total = list.length;
    final rnd = Random();
    final out = <String, List<Restaurant>>{};

    byCat.forEach((cat, items) {
      // 按比例去隨機抽餐廳
      final count = ((items.length / total) * 30).round();
      out[cat] = [];
      for (var i = 0; i < count && items.isNotEmpty; i++) {
        out[cat]!.add(items.removeAt(rnd.nextInt(items.length)));
      }
    });

    return out;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AppState>(context).user;
    if (user == null) {
      return const Center(child: Text('請先登入'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('探索美食'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            tooltip: '重新定位',
            icon: const Icon(Icons.my_location),
            onPressed: _determinePosition,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 半徑輸入 + 探索按鈕
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _radiusController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '搜尋半徑（公尺）',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _search,
                  child: const Text('探索'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Loading / Error
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Expanded(child: Center(child: Text(_errorMessage!)))
            else
              // 顯示推薦的餐廳
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: _randomRecommend(_restaurants)
                      .entries
                      .map((entry) {
                    final category = entry.key;
                    final restos = entry.value;
                    return ExpansionTile(
                      title: Text('$category (${restos.length})'),
                      children: restos.map((restaurant) {
                        return RestaurantDismissibleCard(
                          restaurant: restaurant, 
                          dismissible: false, 
                          onDismissed: null, 
                          fromPersonal: false
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
