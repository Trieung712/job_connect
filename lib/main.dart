import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'firebase_options.dart';
import 'log/login.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Thiết lập Firebase App Check
  await FirebaseAppCheck.instance.activate();

  // Thiết lập local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload) async {
      print("Received Local Notification: [$title, $body, $payload]");
    },
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      String? payload = notificationResponse.payload;
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
    },
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  Future<void> _setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Yêu cầu quyền thông báo từ người dùng
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Lấy FCM token và lưu vào Firestore
    String? token = await messaging.getToken();
    if (token != null) {
      print("FCM Token: $token");

      // Lấy thông tin người dùng hiện tại từ Firebase Authentication
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'fcmToken': token,
        });
      }
    }

    // Lắng nghe và xử lý thông báo khi ứng dụng chạy trong foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Hiển thị local notification
        _showNotification(
            message.notification!.title!, message.notification!.body!);
      }
    });

    // Lắng nghe khi người dùng nhấn vào thông báo
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: LogIn(),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<void> sendPushMessage(String token, String title, String body) async {
  final serviceAccount = ServiceAccountCredentials.fromJson(r'''
 {
  "type": "service_account",
  "project_id": "datn-78f14",
  "private_key_id": "b0e4459ec7d0a5984de0ecf0f00991651ec692db",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC1GPqjBvXMa2Fp\njq3t8ssta5fSdPBAX3idG/ltLHgsXT5vveT8hePrSk6B6ZXJCzvaFHFbE+RQrSfh\nEVUGBWANsGO9D1HuPLLmq5YCKyQeHhKDgOad8spTZm5TF204u3aSjf5ZXx8mTykc\n7nWi1+8VYBf776SPDs7kEuVnfwA/ZSErpZVPNxG28KVHM4GAKfJNQ4pdOyNLkUqM\naZVXlKGce1adWwATx7UHktQtKO5dyfU1t+/7kjJbx0YUdDMmK6dU967ExsJqYNzU\nu+FOWTnBqMizOWx4+DIiYO55KG0+Yrt4Z6wxvMX4GwWgs8yiqiyFsyQGpf6pwYyg\nmk1mqvr7AgMBAAECggEAUaXy7oinTmRFdY11/nd+QjqlpyXA4g0JOLBRmva3Ma1S\nhpezg2SsNzt3vNu/A/b0I6Ue3GTSBcuj1LX3QvEuds2FkkozcrlcIWLQDac8r/V3\n/GEj2KeLr+FZMU45GKBwW6/4MnwP87ox+5DJacN4UAdUmOpZI4SWI78fPbPFPU8M\nNfXkZ7HRKojiAf2xCV7wg436C1QLI/Y8fwUOsQrklnGgVQaGB4fVJkeZ9MCCb58P\ncqVO6BFPplurJqen1kmux4u4GTuRjWhqbde/g8QS9/upwtU3wBfGwyJ7CZV6O2v9\nZsGDNy1HjgNYlHMvR6qFnrkBonvdALBPsRzZYCukCQKBgQDwjLJi6wAAzD//TD2X\n8rAdDs4wbBiUXki+oXMdZAkKycuprYLscYtxl3PZ4F0vdJmUhRlz8cqEYBwztIgG\nvYNI5LBoAXESs7Dq9nA2OdkaYX2SDT4tMzi/OqSSsM7UXAR+QnCuaK5hK8Si3GUW\n/3HaQ2Ihds1++6tgc9LNGqTJEwKBgQDAurnWgArAN5HbKCRHDd0kE/G0gRY76IK1\nXT/US7+g4QX4mBZlf+I/QJVuG9uEV0zLiX+zaTdxi7e+KXiMRJorAct/KFNK6qrV\nnfjuuE002VND3YfsjwlZjhmgCqAQMEk4w5eF1s917cJ+nV+X/Hyw4Guu9EiHZ067\ndyRmsu9reQKBgQCmNlG8j+y8oGVIHoIg0Axox6YpR0fknRFex2gnUsv8rFsRr1bb\n0cksgB4I2kMJW2QTf7SKrPPmbBKQl5m2LpTcdUh/VR+wcIE6mXYHwgkFdX+yv3vK\n962qVPcKdSk1Cy//niEGIkb71aZVcjxXm8IrsovH27M6nuNYDjAGkPZ0CQKBgCAn\nhxXIawLCwqzjt5m7MGfyg+LvnnwEQLptglazBJecs1hUV3g7q82NwuCJ+UfNINzc\nZdfS+BMTkmZBmQEd+PKv6/mdCrh3CmV1Y7DAQvFMSN4Lub+35YFxecj/vNC2naDA\n0SjdO+Oa9VYWf3pl/4+rAYxA6VDd5X7VU9dmhxdRAoGAISsc6n2qGKUw5YHST/FJ\nSYelYDTgKRXASLxQp8q5G9xamug7pBOzWpwQMaX308MfmHLkXJXyYmebf7vAFvHm\nuO059+IngMjHib3APLy00Y5sAo5oRfB/L9JSx+bCb4bw+mWVZjl5FlMYWa1wReb4\nmwsCnduyhdyo9FEdb59dFsA=\n-----END PRIVATE KEY-----\n",
  "client_email": "datn-78f14@appspot.gserviceaccount.com",
  "client_id": "113669009129559871679",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/datn-78f14%40appspot.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
  ''');

  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  final client = await clientViaServiceAccount(serviceAccount, scopes);

  final url =
      'https://fcm.googleapis.com/v1/projects/your-project-id/messages:send';

  final message = jsonEncode({
    "message": {
      "token": token,
      "notification": {
        "title": title,
        "body": body,
      },
      "data": {
        "key1": "value1",
        "key2": "value2",
      }
    }
  });

  final response = await client.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: message,
  );

  if (response.statusCode == 200) {
    print('Message sent successfully');
  } else {
    print('Failed to send message: ${response.body}');
  }

  client.close();
}
