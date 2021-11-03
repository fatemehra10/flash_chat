// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
User? loggedInUser;

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController controller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late String messageText;
  int counter = 0 ;
  

  Future<bool> postHttp(Map<String , dynamic> body) async{
    print("post HTTP");
    try{
      print("\x1B[31m $body \x1B[0m");
    var response = await Dio().post(
      "https://fcm.googleapis.com/fcm/send", 
      data: body, 
      
      options: Options( 
        method: "POST",
        headers: {
          "Content-Type" : "application/json",
          "Authorization" : "key=AAAAiiWKnsk:APA91bEmjz7fgmqzIXCq26bGyrypbWrh4RYNNL2vyAI7S47Yc974Txfe7JQOEaXhFGE9gASSBWv4ClTElpu-sln-FJBqEri8eE7AU0zsxKmyihetl7C1QQs77vN_saS6Dc5Qy9gs8up4" 
        }));
        if(response.statusCode == 200){
          print("200");
          print("\x1B[31m ${response.data} \x1B[0m");
          return true;
        }
        else{
          print("\x1B[31m ${response.statusCode} \x1B[0m");
          return false;
        }
    }catch(e){
          print("\x1B[31m $e \x1B[0m");
          return false;
    }

  }
  @override
  void initState() {
    super.initState();   
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if(notification != null && android != null){
        if(notification.title!.contains("${loggedInUser!.email}") == false){
        
            flutterLocalNotificationsPlugin.show(notification.hashCode,
            "New Messages",notification.body,NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher')
            ));
          }
      }

     });

     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
       print("\x1B[31m A new onMessageOpenedApp event was published! \x1B[0m");
       RemoteNotification? notification = message.notification;
       AndroidNotification? android = message.notification?.android;
       if(notification != null && android != null){
         showDialog(context: context, builder: (_){
            return AlertDialog(
              title: Text('${notification.title}'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Helllooo")
                  ],
                ) ,),
            );
         });
       }
      });
    getCurrentUser();
  }

  void getCurrentUser() async {
    debugPrint('\x1B[33m ok \x1B[0m');
    try {
        final user = await _auth.currentUser;
        if (user != null) {
          var token = await user.getIdToken();
          Hive.box("box").put("token", token);
          loggedInUser = user;
          print("Email:${loggedInUser!.email}");
        }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: [
          IconButton(
              onPressed: () {
                _auth.signOut();
                Hive.box("box").clear();
                Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> FlashChat()));
              },
              icon: Icon(Icons.close))
        ],
        title: Text("⚡️Chat"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MessageStream(),
          Container(
            decoration: kMessageContainerDecoration,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: TextField(
                  controller: controller,
                  onChanged: (value) {
                    messageText = value;
                  },
                  decoration: kMessageTextFieldDecoration,
                )),
                TextButton(
                  onPressed: () async {
                  var time = DateTime.now().microsecondsSinceEpoch;
                   debugPrint('\x1B[33m ${DateTime.now()} \x1B[0m');
                   debugPrint('\x1B[33m $time \x1B[0m');
                    
                    controller.clear();
                    //FirebaseMessaging.instance.unsubscribeFromTopic("all");      
                    _firestore.collection("messages").add(
                        {"text": messageText, "sender": loggedInUser!.email , "id" : time});
                        counter++;
                        Map<String , dynamic> sendNotification = {
                              "to": "/topics/all",
                                "notification": {
                                  "title": "${loggedInUser!.email}:New Messages",
                                  "body": messageText
                                  }
                              };
                        
                        postHttp(sendNotification);
                        
                        
                        print("OK");
    
                  },
                  child: Text(
                    "Send",
                    style: kSendButtonTextStyle,
                  ),
                )
              ],
            ),
          )
        ],
      )),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection("messages").snapshots(),
      builder: (context, snapshot) {
        print("BUILDER");
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data!.docs;
        print("MESSAGES");
        List<MessageBubble>? messagesBubble = [];
        for (var message in messages) {
          final messageText = message.get("text");
          debugPrint('\x1B[33m $messageText \x1B[0m');
          final messageSender = message.get("sender");
          final currentUser = loggedInUser!.email;
          final messageBubble = MessageBubble(
            text: messageText,
            sender: messageSender,
            id: message.get("id"),
            isMe: currentUser == messageSender,
          );
          messagesBubble.add(messageBubble);
        }
       messagesBubble.sort((a,b)=> a.id.compareTo(b.id));
        messagesBubble = List.from(messagesBubble.reversed);
        if(messagesBubble[(0)].sender != loggedInUser!.email){
          
          flutterLocalNotificationsPlugin.show(0, "New Messages", messagesBubble[0].text, NotificationDetails(
                          android: AndroidNotificationDetails(
                            channel.id, 
                            channel.name , 
                            channelDescription: channel.description , 
                            importance: Importance.high,
                            color: Colors.lightBlueAccent,
                            playSound: true,)
                        ));
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messagesBubble,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final int id;
  final bool isMe;

  const MessageBubble(
      {Key? key, required this.text, required this.sender, required this.isMe, required this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Material(
            elevation: 5,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
              topLeft: Radius.circular(isMe ? 30 : 0),
              topRight: Radius.circular(isMe ? 0 : 30)
            ),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                text,
                style: TextStyle(color:isMe ? Colors.white : Colors.black87, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
