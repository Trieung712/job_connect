import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'DetailForAdmin.dart';

class WaitingPost extends StatefulWidget {
  const WaitingPost({Key? key});

  @override
  State<WaitingPost> createState() => _WaitingPostState();
}

class _WaitingPostState extends State<WaitingPost> {
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
              .collection('waiting_posts')
              .orderBy('timestamp', descending: true)
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
                var imageURL = document['imageURL'];
                var postId = document.id; // Lấy postId từ document ID

                return InfoTile(
                  name: name,
                  title: title,
                  imageURL: imageURL,
                  information: information,
                  postId: postId,
                );
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
  final String postId;

  const InfoTile({
    Key? key,
    required this.name,
    required this.title,
    required this.imageURL,
    required this.information,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String shortInformation = information.split('\n').first;

    return Card(
      child: ListTile(
        leading: SizedBox(
          width: 100,
          height: 100,
          child: Image.network(
            imageURL,
            fit: BoxFit.cover,
          ),
        ),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailForAdminScreen(
                name: name,
                title: title,
                imageURL: imageURL,
                information: information,
                postId: postId,
              ),
            ),
          );
        },
      ),
    );
  }
}
