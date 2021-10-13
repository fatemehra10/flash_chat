// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/component/button.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  late String password;
  late String email;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:  Padding(padding: EdgeInsets.symmetric(horizontal: 24),
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
                decoration:kTextFieldDecoration.copyWith(hintText: "Enter your Password")
              ),
              SizedBox(height: 24,),
              Button(title: "Log In", pressed: () async{
                setState(() {
                  showSpinner = true;
                });
                try{
                  final user =await _auth.signInWithEmailAndPassword(email: email, password: password);
                  if(user != null){
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>ChatScreen()));
                  }
                  setState(() {
                    showSpinner = false;
                  });
                }on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    print('No user found for that email.');
                  } else if (e.code == 'wrong-password') {
                    print('Wrong password provided for that user.');
                  }
                }
              }, backgroundColor: Colors.lightBlueAccent)
            ],
          ),),
    );
  }
}
