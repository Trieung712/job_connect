import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import package fluttertoast

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _informationController = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  late String _userName;
  DateTime? _lastPressedAt; // Track last time back button was pressed
  bool _isBackPressed = false; // Track if back button is pressed

  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  Future<void> _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _userName = userDoc['name'];
      });
    }
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _submitData() async {
    final enteredTitle = _titleController.text;
    final enteredInformation = _informationController.text;

    if (enteredTitle.isEmpty ||
        enteredInformation.isEmpty ||
        _image == null ||
        _userName.isEmpty) {
      // Hiển thị thông báo nếu dữ liệu không đủ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập đầy đủ các mục')),
      );
      return;
    }

    // Tiếp tục xử lý khi dữ liệu đầy đủ
    // Upload hình ảnh lên Firebase Storage
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('images')
        .child(DateTime.now().toString() + '.jpg');
    UploadTask uploadTask = ref.putFile(_image!);
    TaskSnapshot taskSnapshot = await uploadTask;
    String imageURL = await taskSnapshot.ref.getDownloadURL();
    DateTime currentTime = DateTime.now();
    // Thêm dữ liệu vào Firestore
    await FirebaseFirestore.instance.collection('post_from_admin').add({
      'name': _userName,
      'title': enteredTitle,
      'information': enteredInformation,
      'imageURL': imageURL,
      'timestamp': currentTime,
    });

    // Hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đăng bài thành công')),
    );

    // Xóa dữ liệu sau khi đăng thành công
    _titleController.clear();
    _informationController.clear();
    setState(() {
      _image = null;
    });
  }

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
          title: Text('Add New Information'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'What do you want to share?',
                    border: OutlineInputBorder(),
                  ),
                  controller: _titleController,
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Write something...',
                    border: OutlineInputBorder(),
                  ),
                  controller: _informationController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
                SizedBox(height: 16),
                _image != null
                    ? Stack(
                        alignment: AlignmentDirectional.bottomEnd,
                        children: [
                          Image.file(
                            _image!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _image = null;
                              });
                            },
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                SizedBox(height: 16),
                TextButton.icon(
                  onPressed: getImage,
                  icon: Icon(Icons.photo, color: Colors.white),
                  label:
                      Text('Add Photo', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitData,
                  child: Text('Post', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
