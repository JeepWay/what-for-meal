import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:what_for_meal/firebase/firebase_service.dart';
import 'package:what_for_meal/firebase/model.dart';
import 'package:what_for_meal/pages/event_form_page.dart';
import 'package:what_for_meal/widgets/card.dart';
import 'package:what_for_meal/widgets/dialog.dart';

import '../firebase/constants.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key, required this.userId});
  final String userId;

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('已參加的活動'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        leading: IconButton(
          tooltip: '返回',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '1. 點擊活動可查看詳細資訊\n2. 點擊 -1 可取消參加活動(創建者只可刪除活動)\n3. 點擊鉛筆可編輯活動\n4. 左滑可刪除活動',
                    textAlign: TextAlign.left,
                  ),
                  duration: Duration(seconds: 6),
                  showCloseIcon: true,
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder<List<Event>>(
          stream: FirebaseFirestore.instance
              .collection(CollectionNames.events)
              .where(EventFields.participants, arrayContains: widget.userId)
              .where(EventFields.dateTime, isGreaterThanOrEqualTo: Timestamp.now())
              .orderBy(EventFields.dateTime)
              .snapshots()
              .map((snap) => snap.docs.map((doc) {
                    return Event(
                      id: doc.id,
                      title: doc[EventFields.title] as String? ?? '',
                      goal: doc[EventFields.goal] as String? ?? '',
                      description: doc[EventFields.description] as String? ?? '',
                      dateTime: doc[EventFields.dateTime] as Timestamp,
                      numberOfPeople: (doc[EventFields.numberOfPeople] as num?)?.toInt() ?? 1,
                      restoName: doc[EventFields.restoName] as String? ?? '',
                      address: doc[EventFields.address] as String? ?? '',
                      participants: List<String>.from(doc[EventFields.participants] ?? <String>[]),
                      participantNames:
                          List<String>.from(doc[EventFields.participantNames] ?? <String>[]),
                    );
              }).toList()),

          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.active) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('載入失敗：${snapshot.error}'));
            }
            final events = snapshot.data ?? <Event>[];
            if (events.isEmpty) {
              return const Center(child: Text('尚未參加任何活動'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final isCreator = event.participants.first == widget.userId;
                return EventCard(
                  isCreator: isCreator,
                  event: event,
                  onPlusOne: null,
                  onCancel: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => DoubleCheckDismissDialog(
                        titleText: '確認取消',
                        displayText: '確定要取消參加活動「${event.title}」嗎？',
                      ),
                    );
                    if (confirm == true) {
                      final res = await FirebaseService.cancelEvent(eventId: event.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: res.success
                                ? Text('已取消參加活動 ${event.title}', textAlign: TextAlign.center)
                                : Text(res.message, textAlign: TextAlign.center),
                            duration: Duration(seconds: 3),
                            showCloseIcon: true,
                          ),
                        );
                      }
                    }
                  },
                  onEdit: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EventFormPage(event: event)),
                    );
                  },
                  onDismissed: () async {
                    final res = await FirebaseService.deleteEvent(eventId: event.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: res.success
                              ? Text('已刪除活動 ${event.title}', textAlign: TextAlign.center)
                              : Text(res.message, textAlign: TextAlign.center),
                          duration: Duration(seconds: 3),
                          showCloseIcon: true,
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
