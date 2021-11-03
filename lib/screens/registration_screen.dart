// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/component/button.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: Hero(
                tag: "logo",
                child: SizedBox(
                  height: 200,
                  child: Image.asset("asset/images/logo.png"),
                ),
              ),
            ),
            SizedBox(
              height: 48,
            ),
            TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value){
                email = value;
              },
              decoration: kTextFieldDecoration.copyWith(hintText: "Enter your Email")
            ),
            SizedBox(height: 8,),
            TextField(
              textAlign: TextAlign.center,
              obscureText: true,
              onChanged: (value){
                password = value;
              },
              decoration: kTextFieldDecoration.copyWith(hintText: "Enter your Password")
            ),
            SizedBox(height: 24,),
            Button(title: "Register", pressed: () async{
              setState(() {
                showSpinner = true;
              });
              try {
                final newUser = await _auth.createUserWithEmailAndPassword(
                    email: email, password: password);
                if(newUser != null){
                  Navigator.push(context,MaterialPageRoute(builder: (context)=> ChatScreen()));
                }
                setState(() {
                  showSpinner = false;
                });
              }on FirebaseAuthException catch (e) {
                if (e.code == 'weak-password') {
                  print('The password provided is too weak.');
                } else if (e.code == 'email-already-in-use') {
                  print('The account already exists for that email.');
                }
              } catch (e) {
                print("ERROR");
                print(e);
              }
            }, backgroundColor: Colors.lightBlueAccent)
          ],
        ),),

    );
  }
}
