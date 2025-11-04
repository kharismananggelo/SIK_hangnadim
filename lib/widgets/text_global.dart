import 'package:flutter/material.dart';

class TextGlobal extends StatefulWidget {
  const TextGlobal({
    Key? key,
    required this.controller,
    required this.text,
    required this.textInputType,
    required this.obscure,
    this.label,
    this.error = false,
    this.errorText,
  }) : super(key: key);

  final TextEditingController controller;
  final String text;
  final TextInputType textInputType;
  final bool obscure;
  final String? label;
  final bool error;
  final String? errorText;

  @override
  _TextGlobalState createState() => _TextGlobalState();
}

class _TextGlobalState extends State<TextGlobal> {
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscure; // Initialize dengan nilai dari widget
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null && widget.label!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: Text(
              widget.label!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.error ? Colors.red : Colors.black,
              ),
            ),
          ),

        // Container field dengan suffix icon
        Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          height: 52,
          padding: EdgeInsets.only(
            top: 3,
            left: 15,
            right: 8,
          ), // Tambahkan right padding untuk icon
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: widget.error
                    ? Colors.red.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 7,
              ),
            ],
            border: widget.error
                ? Border.all(color: Colors.red, width: 1)
                : null,
          ),
          child: Row(
            children: [
              // TextField
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  keyboardType: widget.textInputType,
                  obscureText: widget.obscure ? _isObscure : false,
                  decoration: InputDecoration(
                    hintText: widget.text,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                    hintStyle: TextStyle(
                      height: 1,
                      color: widget.error
                          ? Colors.red.withOpacity(0.7)
                          : Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
              ),

              // Icon mata (hanya tampil jika obscure = true)
              if (widget.obscure)
                IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
            ],
          ),
        ),

        // Error message
        if (widget.error &&
            widget.errorText != null &&
            widget.errorText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 4, right: 20),
            child: Text(
              widget.errorText!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
