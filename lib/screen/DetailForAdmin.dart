import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Home.dart';

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
      appBar: AppBar(
        title: Text('Chi tiết'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              SizedBox(height: 8.0),
              SelectableText(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              SizedBox(height: 8.0),
              SelectableText(
                information,
                style: TextStyle(fontSize: 18.0),
              ),
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
                    child: Text('Phê duyệt'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      rejectPost(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Màu nền đỏ
                    ),
                    child: Text('Từ chối'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void approvePost(BuildContext context) async {
    // Get a reference to Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Get a reference to the post document
      DocumentReference postRef =
          firestore.collection('waiting_posts').doc(postId);

      // Get the data of the post
      DocumentSnapshot postSnapshot = await postRef.get();

      if (postSnapshot.exists) {
        // Get the data from the waiting_posts collection
        Map<String, dynamic> postData =
            postSnapshot.data() as Map<String, dynamic>;

        // Add the post data to the post_from_hr collection
        await firestore.collection('post_from_hr').add(postData);

        // Delete the post from the waiting_posts collection
        await postRef.delete();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phê duyệt thành công')),
        );
        // Wait for a short duration to display the success message
        await Future.delayed(Duration(seconds: 2));

        Navigator.pop(context);
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi phê duyệt bài đăng')),
      );
      print('Error approving post: $e');
    }
  }

  void rejectPost(BuildContext context) async {
    // Get a reference to Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Get a reference to the post document
      DocumentReference postRef =
          firestore.collection('waiting_posts').doc(postId);

      // Delete the post from the waiting_posts collection
      await postRef.delete();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã từ chối bài đăng')),
      );
      // Wait for a short duration to display the success message
      await Future.delayed(Duration(seconds: 2));

      Navigator.pop(context);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi từ chối bài đăng')),
      );
      print('Error rejecting post: $e');
    }
  }
}
