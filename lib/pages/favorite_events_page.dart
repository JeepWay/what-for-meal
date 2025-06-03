import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:what_for_meal/firebase/firebase_service.dart';
import 'package:what_for_meal/firebase/model.dart';
import 'package:what_for_meal/widgets/card.dart';
import '../firebase/constants.dart';

class FavoriteEventsPage extends StatefulWidget {
  final String userId;
  const FavoriteEventsPage({super.key, required this.userId});

  @override
  State<FavoriteEventsPage> createState() => _FavoriteEventsPageState();
}

class _FavoriteEventsPageState extends State<FavoriteEventsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('收藏的活動'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: StreamBuilder<List<String>>(
          stream: FirebaseService.favoriteEventIdsStream(widget.userId),
          builder: (context, favSnapshot) {
            final favIds = favSnapshot.data ?? [];
            if (favIds.isEmpty) {
              return const Center(child: Text('尚未收藏任何活動'));
            }
            return StreamBuilder<List<Event>>(
              stream: FirebaseFirestore.instance
                  .collection(CollectionNames.events)
                  .where(FieldPath.documentId, whereIn: favIds)
                  .snapshots()
                  .map((snap) => snap.docs.map((doc) {
                        final data = doc.data();
                        return Event(
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
                        );
                      }).toList()),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final events = snapshot.data!;
                if (events.isEmpty) {
                  return const Center(child: Text('收藏的活動可能已被刪除'));
                }

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final alreadyJoined = event.participants.contains(widget.userId);

                    return EventCard(
                      isCreator: false,
                      event: event,
                      onPlusOne: alreadyJoined
                          ? null
                          : () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final result = await FirebaseService.joinEvent(eventId: event.id);
                              if (!mounted) return;
                              if (result.success) {
                                setState(() {});
                              }
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(result.message),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                      onCancel: alreadyJoined
                          ? () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final result = await FirebaseService.cancelEvent(eventId: event.id);
                              if (!mounted) return;
                              if (result.success) {
                                setState(() {});
                              }
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(result.message),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          : null,
                      onEdit: null,
                      onDelete: null,
                      favoriteEventIds: favIds,
                      onToggleFavorite: (isFav) async {
                        final messenger = ScaffoldMessenger.of(context);
                        if (isFav) {
                          await FirebaseService.removeFavoriteEvent(
                            userId: widget.userId,
                            eventId: event.id,
                          );
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('已取消收藏'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          await FirebaseService.addFavoriteEvent(
                            userId: widget.userId,
                            eventId: event.id,
                          );
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('已加入收藏'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    );
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