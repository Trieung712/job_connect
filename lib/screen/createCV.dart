import 'package:flutter/material.dart';
import 'InputScreen.dart';

class CreateCV extends StatefulWidget {
  const CreateCV({Key? key}) : super(key: key);

  @override
  State<CreateCV> createState() => _CreateCVState();
}

class _CreateCVState extends State<CreateCV> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Thêm padding cho nút
          child: ElevatedButton(
            onPressed: () {
              // Điều hướng đến màn hình nhập thông tin mới
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserInfoScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue, // Màu chữ trên nút
              padding: EdgeInsets.symmetric(
                  horizontal: 50, vertical: 20), // Kích thước nút
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10), // Định dạng hình dạng của nút
              ),
            ),
            child: Text(
              'Tạo CV của bạn ngay',
              style: TextStyle(fontSize: 20), // Cỡ chữ của nút
            ),
          ),
        ),
      ),
    );
  }
}
