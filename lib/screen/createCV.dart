import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'InputScreen.dart';

class CreateCV extends StatefulWidget {
  const CreateCV({super.key});

  @override
  State<CreateCV> createState() => _CreateCVState();
}

class _CreateCVState extends State<CreateCV> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: createScreen(),
    );
  }
}

class createScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Điều hướng đến màn hình nhập thông tin mới
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserInfoScreen()),
            );
          },
          child: Text('Tạo CV của bạn ngay'),
        ),
      ),
    );
  }
}
