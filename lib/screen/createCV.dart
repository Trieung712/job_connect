import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateCV extends StatefulWidget {
  const CreateCV({super.key});

  @override
  State<CreateCV> createState() => _CreateCVState();
}

class _CreateCVState extends State<CreateCV> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CreateCV'),
      ),
      body: Center(
        child: Text(
          'CreateCV',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
