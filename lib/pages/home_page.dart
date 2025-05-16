import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:what_for_meal/main.dart';

import '../states/app_state.dart';
import '../firebase/firebase_service.dart';
import '../widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  int _selectedIndex = 0;
  late final TabController _tabCtrl;
  late final FirebaseService firebaseService;
  final TextEditingController _listTitle = TextEditingController();
  
  final _titles = ['我的主頁', '探索', '以食會友', '帳戶資訊'];

  @override
  void initState(){
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    firebaseService = FirebaseService(userID: uid);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _listTitle.dispose();
    super.dispose();
  }

  // 創建清單的 list
  void _showAddDialog() {
    _listTitle.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('新增清單', textAlign: TextAlign.center),
        content: TextField(controller: _listTitle, decoration: const InputDecoration(hintText: '清單標題')),
        actions: [
          DialogActionButtons(onConfirm: () async {
            await firebaseService.addNewList(_listTitle.text.trim(), ['', '', '']);
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  Widget get _body {
    if(_selectedIndex == 0){
      return TabBarView(
          controller: _tabCtrl,
          children: [
            // Personal lists
            StreamBuilder(
              stream: firebaseService.watchMyLists(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('尚未建立任何清單'));
                }

                return buildListView(docs: snapshot.data!.docs, isMine: true, service: firebaseService);
              }
            ),
            // Shared lists
            FutureBuilder(
              future: firebaseService.getSharedLists(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('目前沒有公開清單'));
                }
                return buildListView(docs: snapshot.data!, isMine: false, service: firebaseService);
                
              }
            ),
          ]
        );
    }
    // TODO: other pages
    else if(_selectedIndex == 1) {
      return Center(child: Text('${_titles[_selectedIndex]}頁面'));
    }
    else if(_selectedIndex == 2) {
      return Center(child: Text('${_titles[_selectedIndex]}頁面'));
    }
    else {
      return Center(child: Text('${_titles[_selectedIndex]}頁面'));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        bottom: _selectedIndex == 0
                ? TabBar( controller: _tabCtrl,
                          tabs: const [Tab(text: '我的清單'), Tab(text: '公開清單')],
                          labelColor: theme.colorScheme.onPrimary,
                        )
                : null,
        actions: _selectedIndex == 0
            ? [IconButton(icon: const Icon(Icons.post_add), onPressed: _showAddDialog)]
            : null,
      ),
      body:  _body,
       // import from /widgets/widgets.dart
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() {
          _selectedIndex = i;
        }),
      )
    );
  }
}