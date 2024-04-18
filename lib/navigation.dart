import 'package:flutter/material.dart';
import 'package:my_app/screen/home.dart';
import 'package:my_app/screen/chat.dart';
import 'package:my_app/screen/profile.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _currentIndex = 0;

  @override
  final List<Widget> screens = const [
    Home(),
    Chatpage(),
    Profile(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Hiển thị màn hình tương ứng với _currentIndex
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.cyan.shade300,
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _currentIndex =
                index; // Cập nhật _currentIndex khi người dùng chọn một nút trên navigation bar
          });
        },
        items: [
          Icon(Icons.home),
          Icon(Icons.chat),
          Icon(Icons.person),
        ],
      ),
    );
  }
}
