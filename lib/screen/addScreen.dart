import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

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
  late String _userId;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _userName = userDoc['name'];
        _userId = user.uid;
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
        _userName.isEmpty ||
        _userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập đầy đủ các mục')),
      );
      return;
    }

    Reference ref = FirebaseStorage.instance
        .ref()
        .child('images')
        .child(DateTime.now().toString() + '.jpg');
    UploadTask uploadTask = ref.putFile(_image!);
    TaskSnapshot taskSnapshot = await uploadTask;
    String imageURL = await taskSnapshot.ref.getDownloadURL();
    DateTime currentTime = DateTime.now();
    String formattedTime =
        DateFormat('HH:mm:ss dd/MM/yyyy').format(currentTime);
    await FirebaseFirestore.instance.collection('waiting_posts').add({
      'userId': _userId,
      'name': _userName,
      'title': enteredTitle,
      'information': enteredInformation,
      'imageURL': imageURL,
      // Lưu URL hồ sơ của người dùng
      'timestamp': formattedTime,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã gửi cho Quản trị viên phê duyệt. ')),
    );

    _titleController.clear();
    _informationController.clear();
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tạo bài đăng mới'),
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
                    labelText: 'Nhập tiêu đề bài đăng',
                    border: OutlineInputBorder(),
                  ),
                  controller: _titleController,
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Thông tin chi tiết',
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
                      Text('Thêm ảnh', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _submitData,
                  child:
                      Text('Đăng bài', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                    ),
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
