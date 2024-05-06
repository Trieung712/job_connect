import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class CVTemplate extends StatelessWidget {
  final String name;
  final String email;
  final String dob;
  final String profession;
  final String organization;
  final String experience;
  final String phone;
  final String address;
  final String linkedIn;
  final String university;
  final String programmingLanguages;
  final String certifications;
  final String additionalDescription;
  final File? image;
  final double officeSkill;
  final double englishSkill;
  final double communicationSkill;
  final double teamworkSkill;
  final double managementSkill;
  const CVTemplate({
    required this.name,
    required this.email,
    required this.dob,
    required this.profession,
    required this.organization,
    required this.experience,
    required this.phone,
    required this.address,
    required this.linkedIn,
    required this.university,
    required this.programmingLanguages,
    required this.certifications,
    required this.additionalDescription,
    required this.image,
    required this.officeSkill,
    required this.englishSkill,
    required this.communicationSkill,
    required this.teamworkSkill,
    required this.managementSkill,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Template 1"),
      ),
      body: SingleChildScrollView(
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(color: Colors.orange, boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(5, 0), // changes position of shadow
                ),
              ]),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  image != null
                      ? CircleAvatar(
                          radius: 60,
                          backgroundImage: FileImage(image!),
                        )
                      : const CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.amber,

                          // Thêm ảnh đại diện
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  TitleText(
                    txt: name,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    profession,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const BodyText(),
                  const SizedBox(
                    height: 20,
                  ),
                  TitleText(txt: "Contact me"),
                  ContactWidget(
                    ico: Icons.mail,
                    text: email,
                  ),
                  ContactWidget(
                    ico: Icons.phone,
                    text: phone,
                  ),
                  ContactWidget(
                    ico: Icons.pin_drop,
                    text: address,
                  ),
                  ContactWidget(
                    ico: Icons.facebook,
                    text: linkedIn,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TitleText(txt: "Skills"),
                  SizedBox(
                    height: 25,
                  ),
                  SkillProgress(
                    skill: "Office",
                    prog: officeSkill,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SkillProgress(
                    skill: "English",
                    prog: englishSkill,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SkillProgress(
                    skill: "Communication",
                    prog: communicationSkill,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SkillProgress(
                    skill: "Teamwork",
                    prog: teamworkSkill,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SkillProgress(
                    skill: "Management",
                    prog: managementSkill,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  SecTitleTxt(
                    txt: "Education",
                  ),
                  FullEdu(
                    txt1: university,
                    txt2: university,
                  ),
                  SecTitleTxt(
                    txt: "Experience",
                  ),
                  FullEdu(
                    txt1: experience,
                    txt2: experience,
                  ),
                  SecTitleTxt(
                    txt: "Languages",
                  ),
                  FullEdu(
                    txt1: programmingLanguages,
                    txt2: programmingLanguages,
                  ),
                  FullEdu(
                    txt1: "English",
                    txt2: "German",
                  ),
                  SecTitleTxt(
                    txt: "Certificates",
                  ),
                  FullEdu(
                    txt1: certifications,
                    txt2: certifications,
                  ),
                  SecTitleTxt(
                    txt: "Description",
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Text(
                          additionalDescription,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.amber,
                          ),
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
    );
  }
}

class FullEdu extends StatelessWidget {
  String txt1, txt2;
  FullEdu({
    required this.txt1,
    required this.txt2,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SideIco(),
        EduSide(
          name: txt1,
          edu: txt2,
        ),
      ],
    );
  }
}

class EduSide extends StatelessWidget {
  String name, edu;
  EduSide({
    required this.name,
    required this.edu,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 18, color: Colors.amber),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            edu,
            style: TextStyle(fontSize: 18, color: Colors.amber),
          ),
        ],
      ),
    );
  }
}

class SideIco extends StatelessWidget {
  const SideIco({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.radio_button_checked,
            color: Colors.orange,
            size: 25,
          ),
          SizedBox(
            height: 20,
            child: VerticalDivider(
              thickness: 2,
              color: Colors.orange,
            ),
          ),
          Icon(
            Icons.radio_button_checked,
            color: Colors.orange,
            size: 25,
          ),
        ],
      ),
    );
  }
}

class SecTitleTxt extends StatelessWidget {
  String txt;
  SecTitleTxt({
    required this.txt,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      style: TextStyle(
        fontSize: 24,
        color: Colors.orange,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class SkillProgress extends StatelessWidget {
  String skill;
  double prog;

  SkillProgress({
    required this.skill,
    required this.prog,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      height: 40,
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FittedBox(
            child: Text(
              skill,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            height: 13,
            child: LinearProgressIndicator(
              value: prog,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              color: Colors.white,
              minHeight: 10,
              backgroundColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class ContactWidget extends StatelessWidget {
  String text;
  IconData ico;

  ContactWidget({
    required this.text,
    required this.ico,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            ico,
            size: 24,
            color: Colors.white,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}

class BodyText extends StatelessWidget {
  const BodyText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(10.0),
    );
  }
}

// ignore: must_be_immutable
class TitleText extends StatelessWidget {
  String txt;
  TitleText({
    required this.txt,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
    );
  }
}
