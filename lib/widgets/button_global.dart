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
    this.isLoading = false, // ✅ cukup ini aja
  }) : super(key: key);

  final String buttonText;
  final VoidCallback? onTap;
  final Color buttonColor;
  final Color textColor;
  final EdgeInsetsGeometry margin;
  final double height;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool disabled = isLoading || onTap == null;
    final Color bgColor = disabled ? Colors.grey : buttonColor;
    final Color fgColor = disabled ? Colors.white : textColor;

    return InkWell(
      onTap: disabled ? null : onTap,
      child: Container(
        margin: margin,
        alignment: Alignment.center,
        height: height,
        decoration: BoxDecoration(
          color: isLoading ? buttonColor.withOpacity(0.6) : bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                buttonText,
                style: TextStyle(
                  color: fgColor,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
              ),
      ),
    );
  }
}
