import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'DetailScreen.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isBackPressed = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Intercept back button press
      onWillPop: () async {
        if (_isBackPressed) {
          // If back button is pressed twice, perform action like home button
          SystemNavigator.pop();
          return true; // Exit the app
        } else {
          // First press, set _isBackPressed to true
          _isBackPressed = true;
          // Show toast indicating to press again to exit
          Fluttertoast.showToast(
            msg: "Nhấn back lần nữa để thoát ứng dụng",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          // Reset _isBackPressed after a certain delay (2 seconds in this case)
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              _isBackPressed = false;
            });
          });
          return false; // Don't exit the app
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Thông tin hữu ích'),
          automaticallyImplyLeading:
              false, // Đặt giá trị này thành false để loại bỏ icon back
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('post_from_admin')
              .orderBy('timestamp',
                  descending: true) // Sắp xếp theo thời gian giảm dần
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            return ListView(
              children: snapshot.data!.docs.map((document) {
                var name = document['name'];
                var title = document['title'];
                var information = document['information'];
                var imageURL = document['imageURL']; // Thêm trường imageURL

                return InfoTile(
                    name: name,
                    title: title,
                    information: information,
                    imageURL: imageURL);
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String name;
  final String title;
  final String imageURL;
  final String information;

  const InfoTile({
    Key? key,
    required this.name,
    required this.title,
    required this.imageURL,
    required this.information,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Cắt chuỗi thông tin để chỉ hiển thị một dòng
    String shortInformation = information.split('\n').first;

    return Card(
      child: ListTile(
        leading: SizedBox(
          width: 100, // Đặt chiều rộng cố định cho hình ảnh
          height: 100, // Đặt chiều cao cố định cho hình ảnh
          child: Image.network(
            imageURL,
            fit: BoxFit.cover, // Để ảnh scale để vừa với kích thước khung
          ),
        ), // Hiển thị ảnh bên trái
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              shortInformation,
              style: TextStyle(color: Colors.blue),
              maxLines: 1, // Chỉ hiển thị một dòng
              overflow: TextOverflow
                  .ellipsis, // Hiển thị dấu chấm cuối dòng nếu vượt quá
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                name: name,
                title: title,
                imageURL: imageURL,
                information: information,
              ),
            ),
          );
        },
      ),
    );
  }
}
