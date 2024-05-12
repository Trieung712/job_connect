import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String name;
  final String title;
  final String information;
  final String imageURL;

  const DetailScreen({
    Key? key,
    required this.name,
    required this.title,
    required this.information,
    required this.imageURL,
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
              SizedBox(height: 8.0),
              // Additional interactive widgets can be added here if needed
            ],
          ),
        ),
      ),
    );
  }
}
