import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/log/login.dart';
import 'package:path_provider/path_provider.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  late bool _status;
  final FocusNode myFocusNode = FocusNode();
  File? _image;
  String? _userId;
  bool _isBackPressed = false;
  final picker = ImagePicker();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _jobController = TextEditingController();
  TextEditingController _experienceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _fetchUserData();
    _status = true;
  }

  Future<void> _fetchUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Tải dữ liệu từ Firestore
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        // Lấy đường dẫn hình ảnh từ DocumentSnapshot
        String? imageUrl = userData['image_url'];

        // Kiểm tra xem đường dẫn hình ảnh có tồn tại không
        if (imageUrl != null && imageUrl.isNotEmpty) {
          // Nếu có, tải hình ảnh từ Firestore
          // Ví dụ: sử dụng phương thức _getImageFromUrl(imageUrl)
          _getImageFromUrl(imageUrl);
        }

        // Cập nhật các trường dữ liệu khác từ DocumentSnapshot
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _jobController.text = userData['job'] ?? '';
          _experienceController.text = userData['experience'] ?? '';
        });
      }
    }
  }

  Future<void> _getImageFromUrl(String imageUrl) async {
    try {
      // Sử dụng thư viện http để tải hình ảnh từ URL
      var response = await http.get(Uri.parse(imageUrl));

      // Kiểm tra xem tải hình ảnh thành công hay không
      if (response.statusCode == 200) {
        // Tạo một tệp tạm thời để lưu hình ảnh được tải xuống
        File tempImage =
            File('${(await getTemporaryDirectory()).path}/temp_image.jpg');

        // Ghi dữ liệu của hình ảnh vào tệp tạm thời
        await tempImage.writeAsBytes(response.bodyBytes);

        // Gán hình ảnh từ tệp tạm thời cho biến _image
        setState(() {
          _image = tempImage;
        });
      } else {
        // Xử lý khi không tải được hình ảnh
        print('Không ti được ảnh: ${response.statusCode}');
      }
    } catch (e) {
      // Xử lý khi có lỗi xảy ra
      print('Lỗi khi tải ảnh: $e');
    }
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('Không có ảnh nào được chọn.');
      }
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
        body: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 250.0,
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 20.0, top: 20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 25.0),
                              child: Text(
                                'HỒ SƠ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  fontFamily: 'sans-serif-light',
                                  color: Colors.black,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Stack(
                          fit: StackFit.loose,
                          children: <Widget>[
                            Center(
                              child: CircleAvatar(
                                radius: 70,
                                backgroundColor: Colors.transparent,
                                backgroundImage: _image != null
                                    ? FileImage(_image!)
                                    : AssetImage('images/profile-user.png')
                                        as ImageProvider,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 40,
                              child: GestureDetector(
                                onTap: () {
                                  getImage();
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 25.0,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  color: Color(0xffFFFFFF),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Thông tin cá nhân',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  _status ? _getEditIcon() : Container(),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Tên',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Flexible(
                                child: TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    hintText:
                                        "Nhập tên đầy đủ của bạn(hoặc tên công ty)",
                                  ),
                                  enabled: !_status,
                                  autofocus: !_status,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Email của bạn',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Flexible(
                                child: TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    hintText: "Nhập Email của bạn",
                                  ),
                                  enabled: !_status,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Số điện thoại',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Flexible(
                                child: TextField(
                                  controller: _phoneController,
                                  decoration: InputDecoration(
                                    hintText: "Nhập số điện thoại",
                                  ),
                                  enabled: !_status,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _showLogoutConfirmationDialog(context);
                            },
                            child: Text('Đăng xuất'),
                          ),
                        ),
                        !_status ? _getActionButtons() : Container(),
                      ],
                    ),
                  ),
                ),
                // Nút logout
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                child: TextButton(
                  onPressed: () {
                    _saveProfileData();
                  },
                  child: Text(
                    "Lưu",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _status = true;
                      FocusScope.of(context).requestFocus(FocusNode());
                    });
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return GestureDetector(
      child: CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Back'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => LogIn()));
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void _saveProfileData() async {
    // Lưu thông tin vào Firestore
    String name = _nameController.text;
    String email = _emailController.text;
    String phone = _phoneController.text;

    // Thực hiện tải hình ảnh lên Firebase Storage (ví dụ)
    String? imageUrl;
    if (_image != null) {
      imageUrl = await _uploadImageToFirebaseStorage(_image!);
    }

    // Thực hiện lưu vào Firestore
    if (_userId != null) {
      FirebaseFirestore.instance.collection('users').doc(_userId).set({
        'name': name,
        'email': email,
        'phone': phone,
        'image_url': imageUrl,
      }, SetOptions(merge: true));
    }

    // Sau khi lưu, cập nhật trạng thái về readOnly
    setState(() {
      _status = true;
    });
  }

  Future<String?> _uploadImageToFirebaseStorage(File imageFile) async {
    try {
      // Tạo reference đến vị trí lưu trữ trên Firebase Storage
      var storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(_userId!);

      // Tải hình ảnh lên Firebase Storage
      var uploadTask = storageRef.putFile(imageFile);

      // Lấy đường dẫn của hình ảnh sau khi tải lên thành công
      var imageUrl = await (await uploadTask).ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }
}
