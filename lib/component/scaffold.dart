import 'package:flutter/material.dart';
import 'package:flutter_news/bookmark/bookmarkScreen.dart';
import 'package:flutter_news/news/newsScreen.dart';

class ScaffoldComponent extends StatefulWidget {
  final VoidCallback? toggleTheme; // 테마 토글 콜백
  final ThemeMode themeMode;

  const ScaffoldComponent({super.key, this.toggleTheme, required this.themeMode});

  @override
  State<ScaffoldComponent> createState() => _ScaffoldComponentState();
}

class _ScaffoldComponentState extends State<ScaffoldComponent> {
  int _selectedIndex = 0;

  final List _screens = [const NewsScreen(), const BookmarkScreen()];
  final List<String> _titles = ["", "북마크"];

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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(_titles[_selectedIndex], style: Theme.of(context).textTheme.bodyLarge),
          centerTitle: true,
          actions: [
            IconButton(
              icon: widget.themeMode == ThemeMode.light ? Icon(Icons.light_mode) : Icon(Icons.dark_mode),
              onPressed: widget.toggleTheme,
            ),
          ],
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: '뉴스'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: '북마크'),
          ],
          selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
          backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        ),
      ),
    );
  }
}
