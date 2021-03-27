import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import "package:http/http.dart" as http;

class FirebaseNotifications {
  FirebaseMessaging _firebaseMessaging;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  BuildContext context;
  static final String _serverToken =
      "AAAAb4itHww:APA91bHJ2R1E2deUfQmJ1dSeAtbaKkzihKj3yfiboYcw-EmSKeGZh5pg_OwkPDq6WFgUTps2iU-Q8xHQ7W0VJyclnchehQXhr8BUUkmsiPagHD66CCPeTG6vc8W-7Bwu-Rl4o2yX7cSw";

  void setUpFirebase(BuildContext context) {
    this.context = context;
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = new AndroidInitializationSettings('@drawable/logo');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
    _firebaseMessaging = FirebaseMessaging();
    firebaseCloudMessagingListeners();
  }

  Future _showNotificationWithDefaultSound(String title, String message) async {
    var androidPlatformChannelSpecifics =
        AndroidNotificationDetails('app.msquare', 'motorcity', 'motorcity', importance: Importance.high, priority: Priority.high, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      '$title',
      '$message',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token) {
      // print(token);
    });
    _firebaseMessaging.subscribeToTopic("all");

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        final notification = message['notification'];

        final title = notification['title'];
        final body = notification['body'];
        _showNotificationWithDefaultSound(title, body);
      },
      onResume: (Map<String, dynamic> message) async {},
      onLaunch: (Map<String, dynamic> message) async {},
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      //print("Settings registered: $settings");
    });
  }

  static void sendNotifications(String _title, String _body) async {
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$_serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': '$_body', 'title': '$_title'},
          'priority': 'high',
          'to': "/topics/all_trackers",
        },
      ),
    );
  }
}
