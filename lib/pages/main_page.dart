import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 

import '../widgets/dialog.dart';
import '../widgets/card.dart';
import '../states/app_state.dart';
import '../firebase/firebase_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>  with SingleTickerProviderStateMixin{
  late final TabController _tabCtrl;

  @override
  void initState(){
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      setState(() {}); // re-construct appBar on click
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<Widget> _getAppBarActions() {
    switch (_tabCtrl.index) {
      case 0: // persinal lists
        return <Widget>[
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '點擊清單可查看餐廳列表\n左滑清單可刪除該清單\n長按清單可編輯該清單名稱',
                    textAlign: TextAlign.center,
                  ),
                  duration: Duration(seconds: 3),
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
          ),
        ];
      case 1: // public lists
        return <Widget>[
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '點擊清單可查看餐廳列表',
                    textAlign: TextAlign.center,
                  ),
                  duration: Duration(seconds: 3),
                  showCloseIcon: true,
                ),
              );
            },
          ),
        ];
      default:
        return <Widget>[];
    }
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
        actions:_getAppBarActions(),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          /// personal lists
          Consumer<AppState>(
            builder: (context, appState, child) {
              final personalLists = appState.personalLists;
              if (personalLists.isEmpty) {
                return Center(
                  child: Text('尚未建立任何個人清單', style: theme.textTheme.titleLarge,)
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: personalLists.length,
                itemBuilder: (context, index) {
                  final list = personalLists[index];
                  return GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) => EditListDialog(list: list),
                      );
                    },
                    child: ListDismissibleCard(
                      list: list,
                      dismissible: true,
                      onDismissed: () async {
                        final response = await FirebaseService.deleteList(listID: list.listID);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: response.success 
                                ? Text('已刪除清單： ${list.title}', textAlign: TextAlign.center,)
                                : Text(response.message, textAlign: TextAlign.center,),
                              duration: Duration (seconds: 3),
                              showCloseIcon: true,
                            ),
                          );
                        }
                      },
                      fromPersonal: true,
                    ),
                  );
                },
              );
            }
          ),
          /// public lists
          Consumer<AppState>(
            builder: (context, appState, child) {
              final publicLists = appState.publicLists;
              if (publicLists.isEmpty) {
                return Center(
                  child: Text('沒有找到任何公開清單', style: theme.textTheme.titleLarge,)
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: publicLists.length,
                itemBuilder: (context, index) {
                  final list = publicLists[index];
                  return ListDismissibleCard(
                    list: list,
                    dismissible: false,
                    onDismissed: null,
                    fromPersonal: false,
                  );
                },
              );
            }
          ),
        ]
      ),
    );
  }
}