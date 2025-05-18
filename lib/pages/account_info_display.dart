import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../firebase/firebase_service.dart';
import '../states/app_state.dart';

class AccountInfoPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AppState>(context).user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final firebaseService = FirebaseService(userID: user.uid);

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: firebaseService.watchMyInfo(),
        builder: (context, snapshot) {
          final user = context.watch<AppState>().user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator()); // 或 return Container();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('找不到資訊，你怎麼進來的?'));
          }

          final userInfo = snapshot.data!;
          final username = userInfo['username'] ?? '未命名';
          final email = userInfo['email'] ?? '未提供';

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                    ),
                    elevation: 4,
                    // margin: EdgeInsets.all(24),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                              children: [
                                const Icon(Icons.account_circle, size: 20,),
                                const SizedBox(width: 8,),
                                const Text('使用者名稱', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ]
                          ),
                          const SizedBox(height: 16,),
                          Row(
                            children: [
                              const SizedBox(width: 24,),
                              Flexible(
                                child: Text(
                                  '$username',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  softWrap: true,
                                  maxLines: null,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 32,),
                          Row(
                            children: [
                              const Icon(Icons.email_rounded, size: 20,),
                              const SizedBox(width: 8,),
                              const Text('Email : ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16,),
                          Row(
                            children: [
                              const SizedBox(width: 24,),
                              Flexible(
                                child: Text(
                                  '$email',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  softWrap: true,
                                  maxLines: null,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 32,),
                          Row(
                            children: [
                              TextButton(
                                  onPressed: () {
                                    /* TODO */
                                  },
                                  child: Text('修改密碼')
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ),
                ),
                const SizedBox(height: 32,),
                ElevatedButton(
                  onPressed: () async {
                    await context.read<AppState>().signOut();
                    context.go('/login');
                  },
                  child: Text('登出')
                ),
              ],
            )


          );
        },
      )

    );
  }
}

// Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Text('👤 使用者名稱：$username', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// Text('📧 電子郵件：$email'),
// ],
// ),