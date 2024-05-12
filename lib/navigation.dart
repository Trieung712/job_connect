import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:my_app/screen/Home.dart';
import 'package:my_app/screen/addScreen.dart';
import 'package:my_app/screen/createCV.dart';
import 'package:my_app/screen/profile.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({Key? key}) : super(key: key);

  @override
  _NavigationMenuState createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  late int _selectedIndex;
  late int userRole;
  bool _isLoading =
      true; // Biến để xác định xem dữ liệu đang được tải hay không
  bool _errorLoading =
      false; // Biến để xác định xem có lỗi xảy ra khi tải dữ liệu hay không

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    userRole = 1;
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance.collection("users").doc(uid).get();
        setState(() {
          userRole = int.parse(
              snapshot.data()?['role'] ?? '1'); // Chuyển đổi từ String sang int
          _isLoading =
              false; // Đặt biến trạng thái là false khi dữ liệu đã được tải
        });
      }
    } catch (e) {
      print("Error loading user role: $e");
      setState(() {
        _errorLoading =
            true; // Đặt biến trạng thái là true nếu có lỗi xảy ra khi tải dữ liệu
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_errorLoading) {
      return Center(
        child: Text("Error loading data. Please try again later."),
      );
    }

    if (_isLoading) {
      return CircularProgressIndicator(); // Hoặc một tiêu đề loading khác
    }

    List<Widget> _screens = _getScreens(userRole);

    return Scaffold(
      body: Center(
        child: _screens.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _getBottomNavigationBarItems(userRole),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }

  List<Widget> _getScreens(int userRole) {
    if (userRole == 1) {
      return <Widget>[
        Home(),
        AddScreen(),
        CreateCV(),
        Profile(),
      ];
    } else {
      return <Widget>[
        Home(),
        CreateCV(),
        Profile(),
      ];
    }
  }

  List<BottomNavigationBarItem> _getBottomNavigationBarItems(int userRole) {
    if (userRole == 1) {
      return const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box_rounded),
          label: 'Post',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.create),
          label: 'CreateCV',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      return const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.create),
          label: 'CreateCV',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }
  }
}
