// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String title;
  final Function pressed;
  final Color backgroundColor;

  const Button(
      {Key? key, required this.title, required this.pressed, required this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Material(
        elevation: 5,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        child: MaterialButton(
          textColor: Colors.white,
          onPressed: () => pressed(),
          minWidth: 200,
          height: 42,
          child: Text(title),
        ),
      ),
    );
  }
}

