import 'package:flutter/material.dart';
import 'package:flutter_news/bookmark/bookmarkScreen.dart';
import 'package:flutter_news/component/navigator.dart';
import 'package:flutter_news/news/newsScreen.dart';

class ScaffoldComponent extends StatefulWidget {
  const ScaffoldComponent({super.key});

  @override
  State<ScaffoldComponent> createState() => _ScaffoldComponentState();
}

class _ScaffoldComponentState extends State<ScaffoldComponent> {
  int _selectedIndex = 0; // 현재 선택된 탭 인덱스

  final List _screens = [const NewsScreen(), const BookmarkScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: '뉴스'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: '북마크'),
          ],
        ),
      ),
    );
  }
}
