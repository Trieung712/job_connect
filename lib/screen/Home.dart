import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'DetailScreen.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

DateTime timestampToDateTime(String timestamp) {
  List<String> parts = timestamp.split(' ');
  List<String> timeParts = parts[0].split(':');
  List<String> dateParts = parts[1].split('/');
  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);
  int second = int.parse(timeParts[2]);
  int day = int.parse(dateParts[0]);
  int month = int.parse(dateParts[1]);
  int year = int.parse(dateParts[2]);
  return DateTime(year, month, day, hour, minute, second);
}

class _HomeState extends State<Home> {
  bool _isBackPressed = false;
  int _perPage = 10;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Chặn nút back
      onWillPop: () async {
        if (_isBackPressed) {
          // Nếu nhấn nút back hai lần, thực hiện hành động như nút home
          SystemNavigator.pop();
          return true; // Thoát ứng dụng
        } else {
          // Nhấn lần đầu, đặt _isBackPressed thành true
          _isBackPressed = true;
          // Hiển thị toast báo nhấn lại lần nữa để thoát
          Fluttertoast.showToast(
            msg: "Nhấn back lần nữa để thoát ứng dụng",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          // Đặt lại _isBackPressed sau một khoảng thời gian (2 giây trong trường hợp này)
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              _isBackPressed = false;
            });
          });
          return false; // Không thoát ứng dụng
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Thông tin hữu ích'),
          automaticallyImplyLeading:
              false, // Đặt giá trị này thành false để loại bỏ icon back
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('post_from_hr')
              .orderBy('dateTime', descending: true)
              .limit(_perPage * _currentPage)
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
            // Kiểm tra nếu còn nhiều tài liệu để tải
            if (snapshot.data!.docs.length < _perPage * _currentPage) {
              _hasMoreData = false;
            }
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!_isLoadingMore &&
                    _hasMoreData &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  _loadMore();
                  return true;
                }
                return false;
              },
              child: ListView(
                children: [
                  ...snapshot.data!.docs.map((document) {
                    var name = document['name'];
                    var title = document['title'];
                    var information = document['information'];
                    var imageURL = document['imageURL'];
                    var timestamp = document['timestamp'];
                    var userId = document['userId']; // Lấy userId từ document

                    return InfoTile(
                      name: name,
                      title: title,
                      information: information,
                      imageURL: imageURL,
                      timestamp: timestamp,
                      userId: userId,
                    );
                  }).toList(),
                  if (!_isLoadingMore && !_hasMoreData)
                    ListTile(
                      title: Center(
                        child: Text('-- BẠN ĐÃ ĐỌC TOÀN BỘ THÔNG TIN --'),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _loadMore() {
    setState(() {
      _isLoadingMore = true;
    });
    _currentPage++;
    setState(() {
      _isLoadingMore = false;
    });
  }
}

class InfoTile extends StatefulWidget {
  final String name;
  final String title;
  final String imageURL;
  final String information;
  final String timestamp;
  final String userId;

  InfoTile({
    Key? key,
    required this.name,
    required this.title,
    required this.imageURL,
    required this.information,
    required this.timestamp,
    required this.userId,
  }) : super(key: key);

  @override
  _InfoTileState createState() => _InfoTileState();
}

class _InfoTileState extends State<InfoTile> {
  @override
  Widget build(BuildContext context) {
    String shortInformation = widget.information.split('\n').first;

    return Card(
      child: ListTile(
        leading: SizedBox(
          width: 100,
          height: 100,
          child: Image.network(
            widget.imageURL,
            fit: BoxFit.cover,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _AvatarWithName(
                  name: widget.name,
                  userId: widget.userId,
                ),
              ],
            ),
            Text(
              widget.timestamp,
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              widget.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            _ShortInfo(shortInformation: shortInformation),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                name: widget.name,
                title: widget.title,
                imageURL: widget.imageURL,
                information: widget.information,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AvatarWithName extends StatelessWidget {
  final String name;
  final String userId;

  const _AvatarWithName({
    Key? key,
    required this.name,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey,
              ),
              SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          );
        }
        if (snapshot.hasError) {
          return Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.red,
              ),
              SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          );
        }

        var userDocument = snapshot.data;
        var profileImageUrl = userDocument?['profile_url'] ?? '';

        return Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundImage: profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : null,
              backgroundColor:
                  profileImageUrl.isEmpty ? Colors.grey : Colors.transparent,
            ),
            SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }
}

class _ShortInfo extends StatelessWidget {
  final String shortInformation;

  const _ShortInfo({
    Key? key,
    required this.shortInformation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      shortInformation,
      style: TextStyle(color: Colors.blue, fontSize: 15),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
