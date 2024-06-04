import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:my_app/screen/waitpost_forHR.dart';

class DetailHRScreen extends StatefulWidget {
  final String userId;
  final String postId;
  final String name;
  final String title;
  final String information;
  final String imageURL;

  const DetailHRScreen({
    Key? key,
    required this.userId,
    required this.postId,
    required this.name,
    required this.title,
    required this.information,
    required this.imageURL,
  }) : super(key: key);

  @override
  _DetailHRScreenState createState() => _DetailHRScreenState();
}

class _DetailHRScreenState extends State<DetailHRScreen> {
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _informationController;
  File? _image;
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _titleController = TextEditingController(text: widget.title);
    _informationController = TextEditingController(text: widget.information);
    _imageUrl = widget.imageURL;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _informationController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('waiting_posts')
          .doc(widget.postId);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw 'Document not found';
      }

      if (_image != null) {
        final String fileName = widget.postId + '.jpg';
        final firebase_storage.Reference ref =
            firebase_storage.FirebaseStorage.instance.ref().child(fileName);
        await ref.putFile(_image!);
        final String downloadUrl = await ref.getDownloadURL();

        await docRef.update({
          'name': _nameController.text,
          'title': _titleController.text,
          'information': _informationController.text,
          'imageURL': downloadUrl,
        });

        setState(() {
          _imageUrl = downloadUrl;
        });
      } else {
        await docRef.update({
          'name': _nameController.text,
          'title': _titleController.text,
          'information': _informationController.text,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thành công!')),
      );
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại: $error')),
      );
    }
  }

  Future<void> _changeImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _deletePost() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('waiting_posts')
          .doc(widget.postId);

      await docRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bài viết đã được xóa')),
      );
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa bài viết thất bại: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa bài đăng'),
        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Xác nhận xóa bài viết'),
                        content: Text('Bạn có chắc muốn xóa bài viết này?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: _deletePost,
                            child: Text(
                              'Xóa',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'Xóa bài',
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                ),
                SizedBox(height: 8.0),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
                ),
                SizedBox(height: 8.0),
                TextFormField(
                  controller: _informationController,
                  maxLines: null,
                  decoration: InputDecoration(labelText: 'Information'),
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 8.0),
                _image != null
                    ? Image.file(
                        _image!,
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      )
                    : _imageUrl.isNotEmpty
                        ? Image.network(
                            _imageUrl,
                            fit: BoxFit.cover,
                            height: 200,
                            width: double.infinity,
                          )
                        : SizedBox(height: 0),
                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: _changeImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text('Đổi hình ảnh',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    ),
                    child: Text('Lưu chỉnh sửa',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
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
