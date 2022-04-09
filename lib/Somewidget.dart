import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Somewidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/success-back.png"), fit: BoxFit.cover),
        ),),
    );
  }
}
