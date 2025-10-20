import 'package:flutter/material.dart';

class TextGlobal extends StatelessWidget {
  const TextGlobal({
    Key? key, 
    required this.controller, 
    required this.text, 
    required this.textInputType, 
    required this.obscure,
    this.label, // Tambahkan parameter baru (opsional)
  }) : super(key: key);
  
  final TextEditingController controller;
  final String text;
  final TextInputType textInputType;
  final bool obscure;
  final String? label; // Nullable untuk membuatnya opsional

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tambahkan label jika provided
        if (label != null && label!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        
        // Container field yang sudah ada
        Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          height: 52,
          padding: EdgeInsets.only(top: 3, left: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 7,
              ),
            ]
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: textInputType,
            obscureText: obscure,
            decoration: InputDecoration(
                hintText: text,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(0),
                hintStyle: TextStyle(
                  height: 1,
                  color: Colors.black.withOpacity(0.5),
                )
            ),
          ),
        ),
      ],
    );
  }
}