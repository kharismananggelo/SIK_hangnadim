import 'package:flutter/material.dart';

class ButtonGlobal extends StatelessWidget {
  const ButtonGlobal({
    Key? key,
    required this.buttonText,
    required this.onTap,
    this.buttonColor = Colors.blue,
    this.textColor = Colors.white,
    this.margin = const EdgeInsets.only(left: 30, right: 30),
    this.height = 55,
    this.borderRadius = 8,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w600,
  }) : super(key: key);

  final String buttonText;
  final VoidCallback onTap;
  final Color buttonColor;
  final Color textColor;
  final EdgeInsetsGeometry margin;
  final double height;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: margin,
        alignment: Alignment.center,
        height: height,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ]
        ), 
        child: Text(
          buttonText,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}