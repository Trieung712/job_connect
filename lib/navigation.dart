import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:my_app/screen/Home.dart';
import 'package:my_app/screen/addScreen.dart';
import 'package:my_app/screen/createCV.dart';
import 'package:my_app/screen/profile.dart';
import 'package:my_app/screen/waitingPost.dart';
import 'package:my_app/screen/notification.dart';
import 'package:my_app/screen/waitpost_forHR.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({Key? key}) : super(key: key);

  @override
  _NavigationMenuState createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  late int _selectedIndex;
  late int userRole;
  bool _isLoading = true;
  bool _errorLoading = false;

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
      return Container(
        color: Colors.white, // Set the background color
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue), // Customize the color
              ),
              SizedBox(height: 20), // Add some spacing
              Text(
                'Loading...', // Add a text indicating loading
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
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
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }

  List<Widget> _getScreens(int userRole) {
    if (userRole == 1) {
      return <Widget>[
        Home(),
        AddScreen(),
        WaitingPostHR(),
        NotiScreen(),
        Profile(),
      ];
    } else if (userRole == 2) {
      return <Widget>[
        Home(),
        CreateCV(),
        Profile(),
      ];
    } else {
      return <Widget>[
        Home(),
        AddScreen(),
        WaitingPost(),
        Profile(),
      ];
    }
  }

  List<BottomNavigationBarItem> _getBottomNavigationBarItems(int userRole) {
    if (userRole == 1) {
      return <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Trang chính',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box_rounded),
          label: 'Đăng bài',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.drive_folder_upload_outlined),
          label: 'Bài đăng chờ duyệt',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Thông báo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Hồ sơ',
        ),
      ];
    } else if (userRole == 2) {
      return <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Trang chính',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.create),
          label: 'Tạo CV',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Hồ sơ',
        ),
      ];
    } else {
      return <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Trang chính',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box_rounded),
          label: 'Đăng bài',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.drive_folder_upload),
          label: 'Bài đăng chờ duyệt',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Hồ sơ',
        ),
      ];
    }
  }
}
