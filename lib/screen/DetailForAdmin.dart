import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailForAdminScreen extends StatelessWidget {
  final String name;
  final String title;
  final String information;
  final String imageURL;
  final String postId;

  const DetailForAdminScreen({
    Key? key,
    required this.name,
    required this.title,
    required this.information,
    required this.imageURL,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Chi tiết'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35.0,
                        color: Colors.blue),
                  ),
                  SizedBox(height: 8.0),
                  SelectableText(
                    title,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
                  ),
                  SizedBox(height: 8.0),
                  SelectableText(information, style: TextStyle(fontSize: 22.0)),
                  SizedBox(height: 8.0),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Image.network(
                                imageURL), // Hiển thị ảnh trong dialog
                          );
                        },
                      );
                    },
                    child: Image.network(imageURL), // Hiển thị ảnh
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          approvePost(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Màu nền xanh
                        ),
                        child: Text(
                          'Phê duyệt',
                          style:
                              TextStyle(color: Colors.white), // Màu chữ trắng
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          rejectPost(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Màu nền đỏ
                        ),
                        child: Text(
                          'Từ chối',
                          style:
                              TextStyle(color: Colors.white), // Màu chữ trắng
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInformationText(String text) {
    final RegExp linkRegExp = RegExp(
      r'http[s]?://[a-zA-Z0-9./?=_-]+',
      caseSensitive: false,
    );

    final List<TextSpan> spans = [];
    final matches = linkRegExp.allMatches(text);

    int lastMatchEnd = 0;
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: TextStyle(
              color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _launchURL(match.group(0)!);
            },
        ),
      );
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black, fontSize: 18.0),
        children: spans,
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void approvePost(BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentReference postRef =
          firestore.collection('waiting_posts').doc(postId);
      DateTime currentTime = DateTime.now();
      String formattedTime =
          DateFormat('HH:mm:ss dd/MM/yyyy').format(currentTime);

      DocumentSnapshot postSnapshot = await postRef.get();

      if (postSnapshot.exists) {
        Map<String, dynamic> postData =
            postSnapshot.data() as Map<String, dynamic>;
        await firestore.collection('notifications').add({
          'userId': postData['userId'],
          'message':
              'Bài viết "${postData['title']}" của bạn đã được phê duyệt',
          'time': '$formattedTime',
        });
        await firestore.collection('post_from_hr').add(postData);
        await postRef.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phê duyệt thành công')),
        );
        await Future.delayed(Duration(seconds: 2));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi phê duyệt bài đăng')),
      );
      print('Error approving post: $e');
    }
  }

  void rejectPost(BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String rejectReason = '';
    bool noReasonEntered = false;

    try {
      final result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Lí do từ chối', style: TextStyle(color: Colors.blue)),
            content: TextField(
              onChanged: (value) {
                rejectReason = value;
              },
              decoration: InputDecoration(
                hintText: 'Nhập lí do từ chối',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Quay lại',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (rejectReason.isNotEmpty) {
                    Navigator.pop(context, rejectReason);
                  } else {
                    noReasonEntered = true;
                    Fluttertoast.showToast(
                      msg: 'Vui lòng nhập lí do từ chối',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  }
                },
                child: Text(
                  'Xác nhận',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          );
        },
      );

      if (result != null) {
        DocumentReference postRef =
            firestore.collection('waiting_posts').doc(postId);
        DateTime currentTime = DateTime.now();
        String formattedTime =
            DateFormat('HH:mm:ss dd/MM/yyyy').format(currentTime);

        DocumentSnapshot postSnapshot = await postRef.get();
        if (postSnapshot.exists) {
          Map<String, dynamic> postData =
              postSnapshot.data() as Map<String, dynamic>;
          await firestore.collection('notifications').add({
            'userId': postData['userId'],
            'message':
                'Bài viết "${postData['title']}" của bạn đã bị từ chối với lí do: $rejectReason',
            'time': formattedTime,
          });
        }

        await postRef.delete();

        Fluttertoast.showToast(
          msg: 'Đã từ chối bài đăng',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        Navigator.pop(context);
      }
    } catch (e) {
      print('Error rejecting post: $e');
      Fluttertoast.showToast(
        msg: 'Đã xảy ra lỗi khi từ chối bài đăng',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
