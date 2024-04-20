import 'dart:io';
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
        print('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      // Xử lý khi có lỗi xảy ra
      print('Error loading image: $e');
    }
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          GestureDetector(
                            onTap: () {
                              // Navigate back or any other action.
                            },
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.black,
                              size: 22.0,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 25.0),
                            child: Text(
                              'PROFILE',
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
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Personal Information',
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
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Name',
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
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Flexible(
                              child: TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: "Enter Your Full Name",
                                ),
                                enabled: !_status,
                                autofocus: !_status,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Email ID',
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
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Flexible(
                              child: TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  hintText: "Enter Your Email",
                                ),
                                enabled: !_status,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Phone Number',
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
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Flexible(
                              child: TextField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  hintText: "Enter Phone Number",
                                ),
                                enabled: !_status,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                child: Text(
                                  'Job',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              flex: 2,
                            ),
                            Expanded(
                              child: Container(
                                child: Text(
                                  'Experience',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              flex: 2,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.only(right: 10.0),
                                child: TextField(
                                  controller: _jobController,
                                  decoration: InputDecoration(
                                    hintText: "Enter your job",
                                  ),
                                  enabled: !_status,
                                ),
                              ),
                              flex: 2,
                            ),
                            Flexible(
                              child: TextField(
                                controller: _experienceController,
                                decoration: InputDecoration(
                                  hintText: "Enter your experience",
                                ),
                                enabled: !_status,
                              ),
                              flex: 2,
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
                          child: Text('Logout'),
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
                    "Save",
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
    String job = _jobController.text;
    String experience = _experienceController.text;

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
        'job': job,
        'experience': experience,
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
