import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:what_for_meal/logging/logging.dart';
import 'package:what_for_meal/pages/event_form_page.dart';
import 'package:what_for_meal/pages/my_events_page.dart';
import 'package:what_for_meal/pages/favorite_events_page.dart';
import 'package:what_for_meal/states/app_state.dart';
import 'package:what_for_meal/utils/location_helper.dart';
import 'package:what_for_meal/widgets/card.dart';

import '../firebase/constants.dart';
import '../firebase/firebase_service.dart';
import '../firebase/model.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> with WidgetsBindingObserver {
  final GeoHasher geoHasher = GeoHasher();
  Position? _position;
  String? _errorMessage;
  List<String>? _nearbyHashes;

  Future<void> _currentPosition() async {
    try {
      final pos = await determinePosition();
      logger.i(pos);
      setState(() {
        _position = pos;
        final myHash = geoHasher.encode(_position!.longitude, _position!.latitude, precision: 5);
        _nearbyHashes = geoHasher.neighbors(myHash).values.toList();
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '定位失敗：$e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentPosition();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _currentPosition();
    }
  }

  Map<String, List<Event>> _groupEventsByGoal(List<Event> events) {
    final grouped = <String, List<Event>>{
      '興趣同好聚': [],
      '揪團湊優惠': [],
      '語言交換飯局': [],
      '毛孩友善聚餐': [],
      '其他': [],
    };
    for (var e in events) {
      final goal = e.goal;
      if (grouped.containsKey(goal)) {
        grouped[goal]!.add(e);
      } else {
        grouped['其他']!.add(e);
      }
    }
    return grouped;
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
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        toolbarHeight: kToolbarHeight,
        title: Row(
          children: [
            IconButton(
              tooltip: '創建活動',
              icon: const Icon(Icons.edit_calendar_sharp),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EventFormPage()),
                );
              },
            ),
            IconButton(
              tooltip: '已收藏的活動',
              icon: const Icon(Icons.favorite),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FavoriteEventsPage(userId: user.uid)),
                );
              },
            ),
            const SizedBox(width: 32),
            const Text('以食會友'), // 這是你的標題
          ],
        ),
        actions: [
          IconButton(
            tooltip: '查看已參加的活動',
            icon: const Icon(Icons.perm_contact_calendar_sharp),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MyEventsPage(userId: user.uid)),
              );
            },
          ),
          IconButton(
            tooltip: '重新定位',
            icon: const Icon(Icons.my_location),
            onPressed: _currentPosition,
          ),
          IconButton(
            tooltip: '使用說明',
            icon: const Icon(Icons.info),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '1. 點擊卡片查看活動詳情\n'
                    '2. 長按卡片（創建者）可編輯活動\n'
                    '3. 點擊愛心收藏或取消收藏\n'
                    '4. 點擊 +1 參加活動',
                    textAlign: TextAlign.left,
                  ),
                  duration: Duration(seconds: 6),
                  showCloseIcon: true,
                ),
              );
            },
          ),
        ],
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _position == null
            ? Center(child: Text(_errorMessage ?? '正在取得定位'))
            : StreamBuilder<List<String>>(
                stream: FirebaseService.favoriteEventIdsStream(user.uid),
                builder: (context, favSnapshot) {
                  final favoriteIds = favSnapshot.data ?? [];

                  return StreamBuilder<List<Event>>(
                    stream: FirebaseFirestore.instance
                        .collection(CollectionNames.events)
                        .where(EventFields.geoHash, whereIn: _nearbyHashes)
                        .where(EventFields.dateTime, isGreaterThanOrEqualTo: Timestamp.now())
                        .snapshots()
                        .map((snap) {
                      final center = _position!;
                      final List<Event> nearbyEvents = [];

                      for (var doc in snap.docs) {
                        final data = doc.data();
                        final GeoPoint geo = data[EventFields.location];

                        final dist = Geolocator.distanceBetween(
                          center.latitude,
                          center.longitude,
                          geo.latitude,
                          geo.longitude,
                        );

                        if (dist <= 1000) {
                          nearbyEvents.add(Event(
                            id: doc.id,
                            title: data[EventFields.title] ?? '',
                            goal: data[EventFields.goal] ?? '',
                            description: data[EventFields.description] ?? '',
                            dateTime: data[EventFields.dateTime] as Timestamp,
                            numberOfPeople: (data[EventFields.numberOfPeople] as num?)?.toInt() ?? 1,
                            restoName: data[EventFields.restoName] ?? '',
                            address: data[EventFields.address] ?? '',
                            participants: List<String>.from(data[EventFields.participants] ?? []),
                            participantNames: List<String>.from(data[EventFields.participantNames] ?? []),
                          ));
                        }
                      }

                      return nearbyEvents;
                    }),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.active) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('載入失敗：${snapshot.error}'));
                      }

                      final events = snapshot.data ?? [];
                      if (events.isEmpty) {
                        return const Center(child: Text('周圍 1km 內沒有活動'));
                      }

                      final groupedEvents = _groupEventsByGoal(events);

                      return ListView(
                        padding: const EdgeInsets.all(8),
                        children: groupedEvents.entries.map((entry) {
                          final goal = entry.key;
                          final eventsInGroup = entry.value;

                          return ExpansionTile(
                            initiallyExpanded: true,
                            title: Text('$goal (${eventsInGroup.length})'),
                            children: eventsInGroup.map((event) {
                              return EventCard(
                                isCreator: false,
                                event: event,
                                onPlusOne: () async {
                                  final res = await FirebaseService.joinEvent(eventId: event.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(res.message, textAlign: TextAlign.center),
                                        duration: const Duration(seconds: 3),
                                        showCloseIcon: true,
                                      ),
                                    );
                                  }
                                },
                                onCancel: null,
                                onEdit: null,
                                onDelete: null,
                                favoriteEventIds: favoriteIds,
                                onToggleFavorite: (isFav) async {
                                  if (isFav) {
                                    await FirebaseService.removeFavoriteEvent(
                                      userId: user.uid,
                                      eventId: event.id,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('已取消收藏'), duration: Duration(seconds: 2)),
                                      );
                                    }
                                  } else {
                                    await FirebaseService.addFavoriteEvent(
                                      userId: user.uid,
                                      eventId: event.id,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('已加入收藏'), duration: Duration(seconds: 2)),
                                      );
                                    }
                                  }
                                },
                              );
                            }).toList(),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}