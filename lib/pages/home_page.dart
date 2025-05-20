import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main_page.dart';
import 'explore_page.dart';
import 'event_page.dart';
import 'profile_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  final List<Widget> _pages = [
    MainPage(),
    ExplorePage(),
    EventPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: theme.colorScheme.secondary,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: '主頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore_rounded),
            label: '探索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people_rounded),
            label: '以食會友',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts_outlined),
            activeIcon: Icon(Icons.manage_accounts_rounded),
            label: '帳戶資訊',
          ),
        ],
        iconSize: 35,
        height: 60,
        currentIndex: 0,
        activeColor: theme.colorScheme.primary,
        inactiveColor: theme.colorScheme.onSecondary,
      ), 
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context){
            return CupertinoPageScaffold(
              child: _pages[index]);
          },
        );
      },
    );
  }
}