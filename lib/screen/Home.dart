import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh tin'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('post_from_admin')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((document) {
              var name = document['name'];
              var title = document['title'];
              var information = document['information'];
              var imageURL = document['imageURL']; // Thêm trường imageURL

              return InfoTile(
                  name: name,
                  title: title,
                  information: information,
                  imageURL: imageURL);
            }).toList(),
          );
        },
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String name;
  final String title;
  final String information;
  final String imageURL; // Thêm imageURL

  const InfoTile(
      {Key? key,
      required this.name,
      required this.title,
      required this.information,
      required this.imageURL})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize:
                    1.5 * Theme.of(context).textTheme.titleMedium!.fontSize!,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Information: $information'),
            // Sử dụng GestureDetector để bắt sự kiện nhấn vào ảnh
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      child:
                          Image.network(imageURL), // Hiển thị ảnh trong dialog
                    );
                  },
                );
              },
              child: Image.network(imageURL), // Hiển thị ảnh
            ),
          ],
        ),
      ),
    );
  }
}
