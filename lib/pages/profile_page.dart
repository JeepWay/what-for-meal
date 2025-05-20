import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/widgets.dart';
import '../firebase/firebase_service.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

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
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '帳戶資訊頁面', 
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20)
            ),
            PrimaryOutlinedButton(
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
              label: Text('登出'),
            ),
          ],
        ),
      ),
    );
  }
}