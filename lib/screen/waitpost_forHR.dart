import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'DetailforHR.dart';

class WaitingPostHR extends StatefulWidget {
  const WaitingPostHR({Key? key});

  @override
  State<WaitingPostHR> createState() => _WaitingPostHRState();
}

class _WaitingPostHRState extends State<WaitingPostHR> {
  bool _isBackPressed = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return WillPopScope(
      onWillPop: () async {
        if (_isBackPressed) {
          SystemNavigator.pop();
          return true;
        } else {
          _isBackPressed = true;
          Fluttertoast.showToast(
            msg: "Nhấn back lần nữa để thoát ứng dụng",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              _isBackPressed = false;
            });
          });
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Bài đăng chờ duyệt'),
          automaticallyImplyLeading: false,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('waiting_posts')
              .where('userId', isEqualTo: currentUser?.uid)
              .orderBy('dateTime', descending: false)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              if (snapshot.error.toString().contains('index')) {
                return Center(
                  child: Text(
                    'The required index is being built. Please try again later.',
                  ),
                );
              }
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
                var timestamp = document['timestamp'];
                var postId = document.id;
                var userId = document['userId'];

                return InfoTile(
                  name: name,
                  title: title,
                  information: information,
                  imageURL: imageURL,
                  timestamp: timestamp,
                  postId: postId,
                  userId: userId,
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
  final String timestamp;
  final String postId;
  final String userId;

  const InfoTile({
    Key? key,
    required this.name,
    required this.title,
    required this.imageURL,
    required this.information,
    required this.timestamp,
    required this.postId,
    required this.userId,
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
            Row(
              children: [
                _AvatarWithName(name: name, userId: userId),
              ],
            ),
            Text(
              timestamp,
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            _ShortInfo(shortInformation: shortInformation),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit), // Thay đổi biểu tượng nếu cần thiết
          onPressed: () {
            // Xử lý sự kiện khi nút được nhấn
            // Ví dụ: Mở màn hình sửa đổi thông tin
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailHRScreen(
                  name: name,
                  title: title,
                  imageURL: imageURL,
                  information: information,
                  userId: userId,
                  postId: postId,
                ),
              ),
            );
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailHRScreen(
                name: name,
                title: title,
                imageURL: imageURL,
                information: information,
                userId: userId,
                postId: postId,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AvatarWithName extends StatelessWidget {
  final String name;
  final String userId;

  const _AvatarWithName({
    Key? key,
    required this.name,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey,
              ),
              SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          );
        }
        if (snapshot.hasError) {
          return Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.red,
              ),
              SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          );
        }

        var userDocument = snapshot.data;
        var profileImageUrl = userDocument?['profile_url'] ?? '';

        return Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundImage: profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : null,
              backgroundColor:
                  profileImageUrl.isEmpty ? Colors.grey : Colors.transparent,
            ),
            SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }
}

class _ShortInfo extends StatelessWidget {
  final String shortInformation;

  const _ShortInfo({
    Key? key,
    required this.shortInformation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      shortInformation,
      style: TextStyle(color: Colors.blue, fontSize: 15),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
