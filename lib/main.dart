// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/screens/Login_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  "id",
  "AndroidNotificationChannel",
  importance: Importance.high,
  playSound: true,
  description: "DescriptionChannel",
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
Future<void> _fireaseMessagingBackgroundHandler(RemoteMessage message) async{
  await Firebase.initializeApp();
  print("A bg message just showed up : ${message.messageId}");
  print("\x1B[33m A new onMessageOpenedApp event was published! \x1B[0m");
}

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_fireaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true , badge: true , sound: true);
  FirebaseMessaging.instance.subscribeToTopic("all");
  var token = await FirebaseMessaging.instance.getToken();
  print("\x1B[31m $token \x1B[0m");
  await Hive.initFlutter();
  await Hive.openBox("box");
  runApp(const FlashChat());
}

class FlashChat extends StatelessWidget {
  const FlashChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(Hive.box("box").get("token"));
    print("Token");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Hive.box("box").get("token") == null ? "welcome_screen": "chat_screen" ,
      routes: {
        "welcome_screen":(context)=>WelcomeScreen(),
        "login_screen":(context)=> LoginScreen(),
        "registration_screen":(context)=> RegistrationScreen(),
        "chat_screen":(context)=> ChatScreen()
      },

    );
  }
}
