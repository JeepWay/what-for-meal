import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/widgets.dart';
import '../firebase/firebase_service.dart';
import '../firebase/constants.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Stream<Map<String, dynamic>?> userStream = 
    FirebaseAuth.instance.currentUser != null
      ? FirebaseFirestore.instance
        .collection(CollectionNames.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) => snapshot.data())
      : const Stream.empty();

  Future<void> _signOut() async {
    final response = await FirebaseService.signOut();
    if (mounted) {
      context.go('/login');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: response.success 
            ? Text(response.message)
            : Text('強制登出，${response.message}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('帳戶資訊'), 
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, theme.colorScheme.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person, 
                    size: 80, 
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '個人資料',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<Map<String, dynamic>?>(
                    stream: userStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('錯誤: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Text('尚未登入', style: TextStyle(color: Colors.grey));
                      }
                      final data = snapshot.data!;
                      return Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.email, color: theme.colorScheme.primary,),
                            title: Text('電子郵件', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(data[UserFileds.email] ?? '未提供', style: TextStyle(color: Colors.black54)),
                          ),
                          ListTile(
                            leading: Icon(Icons.person_outline, color: theme.colorScheme.primary,),
                            title: Text('使用者名稱', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(data[UserFileds.userName] ?? '未提供', style: TextStyle(color: Colors.black54)),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  PrimaryOutlinedButton(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout),
                    label: Text('登出'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}