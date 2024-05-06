import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin hữu ích'),
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
        title: SelectableText(
          name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              title,
              style: TextStyle(
                fontSize:
                    1.5 * Theme.of(context).textTheme.subtitle1!.fontSize!,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ExpandableText(
              text: information,
              maxLines: 4, // Số dòng tối đa
              style: TextStyle(color: Colors.blue),
            ),
            SizedBox(height: 8),
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

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle style;

  const ExpandableText({
    required this.text,
    this.maxLines = 2,
    this.style = const TextStyle(),
  });

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      widget.text,
      maxLines: _isExpanded ? null : widget.maxLines,
      style: widget.style,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: _isExpanded ? null : widget.maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width);

    if (textPainter.didExceedMaxLines) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textWidget,
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _isExpanded ? 'Thu gọn' : '...Xem thêm',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (_isExpanded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textWidget,
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Thu gọn',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return textWidget;
    }
  }
}
