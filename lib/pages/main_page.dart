import 'package:flutter/material.dart';

import '../widgets/dialog.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>  with SingleTickerProviderStateMixin{
  late final TabController _tabCtrl;
  final TextEditingController _listTitle = TextEditingController();

  @override
  void initState(){
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _listTitle.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('主頁'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kTextTabBarHeight),
          child: Container(
            color: theme.colorScheme.secondary,
            child: TabBar(
              controller: _tabCtrl,
              tabs: const [Tab(text: '我的清單'), Tab(text: '公開清單')],
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface,
              indicatorColor: theme.colorScheme.onPrimary,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info), 
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '點擊清單可查看餐廳列表\n左滑清單可刪除該清單',
                    textAlign: TextAlign.center,
                  ),
                  duration: Duration (seconds: 3),
                  showCloseIcon: true,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.post_add), 
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AddPersonalListDialog();
                }
              );
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          Center(child: Text('目前沒有個人清單')),
          Center(child: Text('目前沒有公開清單')),
        ]
      ),
    );
  }
}