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
  late bool _status, _isEditing = false;
  final FocusNode myFocusNode = FocusNode();
  File? _image;
  String? _userId;
  bool _isBackPressed = false;
  final picker = ImagePicker();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

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
        String? imageUrl = userData['profile_url'];

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
        print('Không tải được ảnh: ${response.statusCode}');
      }
    } catch (e) {
      // Xử lý khi có lỗi xảy ra
      print('Lỗi khi tải ảnh: $e');
    }
  }

  Future<void> _clearUserData() async {
    // Clear image from local cache
    setState(() {
      _image = null;
    });

    // Optionally clear other cached user data here, if you use SharedPreferences or any other local storage

    // Clear Firestore cache
    FirebaseFirestore.instance.clearPersistence();
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
        backgroundColor: Colors.white,
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
                                    : AssetImage('images/profile.png')
                                        as ImageProvider,
                              ),
                            ),
                            if (_isEditing)
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
                                  maxLength: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        !_status ? _getActionButtons() : Container(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(130.0, 15.0, 130.0,
                              0), // Giảm khoảng cách từ trên xuống và từ trái qua

                          child: ElevatedButton(
                            onPressed: () {
                              _showLogoutConfirmationDialog(context);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.red), // Đặt màu sắc nút thành đỏ
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      20.0), // Đặt viền cong cho nút
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .center, // Đưa biểu tượng và văn bản vào giữa theo chiều ngang
                              children: [
                                Icon(Icons.logout,
                                    color: Colors.white), // Thêm biểu tượng
                                SizedBox(
                                    width:
                                        8), // Khoảng cách giữa biểu tượng và văn bản
                                Text('Đăng xuất',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
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
                    "Hủy",
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
        backgroundColor: Colors.lightBlueAccent,
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
          // Đặt _isEditing thành true khi chỉnh sửa được kích hoạt
          _isEditing = true;
        });
      },
    );
  }

  Future<void> _logOut() async {
    // Clear user data
    await _clearUserData();

    // Log out from Firebase
    await FirebaseAuth.instance.signOut();

    // Navigate to Login page
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LogIn()));
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Bạn chắc chứ?',
              style: TextStyle(
                color: Colors.blue,
              )),
          content: Text('Bạn có muốn đăng xuất không?',
              style: TextStyle(color: Colors.blue)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Quay lại', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () async {
                await _logOut();
              },
              child: Text('OK',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
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

    // Thực hiện tải hình ảnh lên Firebase Storage (nếu có)
    String? imageUrl;
    if (_image != null) {
      imageUrl = await _uploadImageToFirebaseStorage(_image!);
    }

    // Thực hiện lưu vào Firestore
    if (_userId != null) {
      // Chỉ cập nhật đường dẫn của hình ảnh mới
      FirebaseFirestore.instance.collection('users').doc(_userId).set({
        'name': name,
        'email': email,
        'phone': phone,
        'profile_url': imageUrl, // Lưu đường dẫn của ảnh mới
      }, SetOptions(merge: true));
    }

    // Sau khi lưu, cập nhật trạng thái về readOnly
    setState(() {
      _status = true;
      _isEditing = false;
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

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }
}
