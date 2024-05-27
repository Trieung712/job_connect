import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/template/cv_temp1.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  String name = '';
  String email = '';
  String dob = '';
  String profession = '';
  String organization = '';
  String experience = '';
  String phone = '';
  String address = '';
  String linkedIn = '';
  String university = '';
  String additionalDescription = '';
  String language = '';
  String certificates = '';
  File? _image;

  double officeSkill = 0.0;
  double englishSkill = 0.0;
  double communicationSkill = 0.0;
  double teamworkSkill = 0.0;
  double managementSkill = 0.0;

  Future<String?> generateDescription(String prompt) async {
    final model =
        GenerativeModel(model: 'gemini-pro', apiKey: dotenv.env['API_KEY']!);

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    if (response.text != null) {
      return response.text!;
    } else {
      throw Exception('Failed to generate description');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Info'),
      ),
      body: Stack(
        children: [
          // Ảnh nền
          Positioned.fill(
            child: Image.asset(
              'images/back_test.jpg', // Đường dẫn đến ảnh nền của bạn
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      _pickImage(ImageSource.gallery);
                    },
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.lightBlueAccent,
                      child: _image == null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.black,
                            )
                          : ClipOval(
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tên của bạn',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      filled: true, // Cho phép ô nhập liệu được tô màu nền
                      fillColor: Colors.white54,
                    ),
                    onChanged: (value) {
                      setState(() {
                        name = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      filled: true, // Cho phép ô nhập liệu được tô màu nền
                      fillColor: Colors.white54,
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Ngày sinh',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      filled: true, // Cho phép ô nhập liệu được tô màu nền
                      fillColor: Colors.white54,
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {
                        dob = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Chuyên môn',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      filled: true, // Cho phép ô nhập liệu được tô màu nền
                      fillColor: Colors.white54,
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {
                        profession = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nơi học tập/làm việc ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      filled: true, // Cho phép ô nhập liệu được tô màu nền
                      fillColor: Colors.white54,
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {
                        organization = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Kinh nghiệm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      filled: true, // Cho phép ô nhập liệu được tô màu nền
                      fillColor: Colors.white54,
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {
                        experience = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      filled: true, // Cho phép ô nhập liệu được tô màu nền
                      fillColor: Colors.white54,
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {
                        phone = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Địa chỉ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      filled: true, // Cho phép ô nhập liệu được tô màu nền
                      fillColor: Colors.white54,
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {
                        address = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Link Facebook',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      filled: true, // Cho phép ô nhập liệu được tô màu nền
                      fillColor: Colors.white54,
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {
                        linkedIn = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Đại học đã tốt nghiệp',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      filled: true, // Cho phép ô nhập liệu được tô màu nền
                      fillColor: Colors.white54,
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {
                        university = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Khả năng ngôn ngữ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      filled: true, // Cho phép ô nhập liệu được tô màu nền
                      fillColor: Colors.white54,
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {
                        language = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Các chứng chỉ đã có',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      filled: true, // Cho phép ô nhập liệu được tô màu nền
                      fillColor: Colors.white54,
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {
                        certificates = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kĩ năng',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('Văn phòng'),
                      FlutterSlider(
                        values: [officeSkill],
                        max: 1,
                        min: 0,
                        step: FlutterSliderStep(step: 0.1),
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          setState(() {
                            officeSkill = lowerValue;
                          });
                        },
                        tooltip: FlutterSliderTooltip(
                          textStyle: TextStyle(fontSize: 16),
                          boxStyle: FlutterSliderTooltipBox(
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        handler: FlutterSliderHandler(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(Icons.circle, color: Colors.white, size: 20),
                        ),
                      ),
                      Text('Ngoại ngữ'),
                      FlutterSlider(
                        values: [englishSkill],
                        max: 1,
                        min: 0,
                        step: FlutterSliderStep(step: 0.1),
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          setState(() {
                            englishSkill = lowerValue;
                          });
                        },
                        tooltip: FlutterSliderTooltip(
                          textStyle: TextStyle(fontSize: 16),
                          boxStyle: FlutterSliderTooltipBox(
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        handler: FlutterSliderHandler(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(Icons.circle, color: Colors.white, size: 20),
                        ),
                      ),
                      Text('Giao tiếp'),
                      FlutterSlider(
                        values: [communicationSkill],
                        max: 1,
                        min: 0,
                        step: FlutterSliderStep(step: 0.1),
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          setState(() {
                            communicationSkill = lowerValue;
                          });
                        },
                        tooltip: FlutterSliderTooltip(
                          textStyle: TextStyle(fontSize: 16),
                          boxStyle: FlutterSliderTooltipBox(
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        handler: FlutterSliderHandler(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(Icons.circle, color: Colors.white, size: 20),
                        ),
                      ),
                      Text('Làm việc nhóm'),
                      FlutterSlider(
                        values: [teamworkSkill],
                        max: 1,
                        min: 0,
                        step: FlutterSliderStep(step: 0.1),
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          setState(() {
                            teamworkSkill = lowerValue;
                          });
                        },
                        tooltip: FlutterSliderTooltip(
                          textStyle: TextStyle(fontSize: 16),
                          boxStyle: FlutterSliderTooltipBox(
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        handler: FlutterSliderHandler(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(Icons.circle, color: Colors.white, size: 20),
                        ),
                      ),
                      Text('Quản lí thời gian'),
                      FlutterSlider(
                        values: [managementSkill],
                        max: 1,
                        min: 0,
                        step: FlutterSliderStep(step: 0.1),
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          setState(() {
                            managementSkill = lowerValue;
                          });
                        },
                        tooltip: FlutterSliderTooltip(
                          textStyle: TextStyle(fontSize: 16),
                          boxStyle: FlutterSliderTooltipBox(
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        handler: FlutterSliderHandler(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(Icons.circle, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Mô tả thêm',
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {
                        additionalDescription = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        String prompt =
                            'I am a "$profession" with "$experience" experience working at "$organization". Help me create a brief sentence for employers to hire me. Description should not exceed 25 words';
                        String? generatedDescription =
                            await generateDescription(prompt);

                        setState(() {
                          additionalDescription = generatedDescription ?? '';
                        });

                        showDialog(
                          context: context,
                          builder: (context) {
                            String tempDescription = generatedDescription ?? '';
                            TextEditingController descriptionController =
                                TextEditingController(text: tempDescription);
                            return AlertDialog(
                              title: Text('Tạo mô tả'),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    TextFormField(
                                      controller: descriptionController,
                                      maxLines: null,
                                      onChanged: (value) {
                                        tempDescription = value;
                                      },
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'CẨN THẬN KHI SỬ DỤNG.'
                                      '\nĐây là nội dung tạo từ AI, nó có thể sai sót.'
                                      '\nHãy chỉnh sửa theo ý bạn ',
                                      style: TextStyle(color: Colors.red),
                                    ), // Thêm dòng thông báo màu đỏ
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          additionalDescription =
                                              tempDescription;
                                        });
                                        Navigator.pop(context);
                                        // Thực hiện các tác vụ khác ở đây sau khi mô tả được lưu
                                        // Ví dụ: điều hướng đến màn hình khác, gửi dữ liệu đến máy chủ, vv.
                                      },
                                      child: Text('Lưu mô tả'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                        ;
                      } catch (e) {
                        print('Không tạo được mô tả: $e');
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text('Không tạo được mô tả.'),
                              actions: <Widget>[
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Đóng'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Text('Tạo mô tả'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CVTemplate(
                            name: name,
                            email: email,
                            dob: dob,
                            profession: profession,
                            organization: organization,
                            experience: experience,
                            phone: phone,
                            address: address,
                            linkedIn: linkedIn,
                            university: university,
                            programmingLanguages: language,
                            certifications: certificates,
                            additionalDescription: additionalDescription,
                            image: _image,
                            officeSkill: officeSkill,
                            englishSkill: englishSkill,
                            communicationSkill: communicationSkill,
                            teamworkSkill: teamworkSkill,
                            managementSkill: managementSkill,
                          ),
                        ),
                      );
                    },
                    child: Text('Tạo CV'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
