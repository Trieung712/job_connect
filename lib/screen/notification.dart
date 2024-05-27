import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông báo'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream: _getNotificationsStream(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final notifications = snapshot.data!.docs;
            // Sắp xếp các thông báo theo thời gian từ mới đến cũ
            notifications.sort((a, b) => b['time'].compareTo(a['time']));
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final message = notification['message'] ?? '';
                final time = notification['time'] ?? '';
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 2.0, horizontal: 16.0),
                  child: Card(
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        message,
                        style: TextStyle(color: Colors.blue, fontSize: 13),
                      ),
                      trailing: Text(
                        time,
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getNotificationsStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid ?? '';
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}
