import 'package:flutter/material.dart';

class TextFormWidget extends StatelessWidget {
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const TextFormWidget({
    this.label,
    this.hintText,
    this.prefixIcon,
    this.validator,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: TextFormField(
        style: const TextStyle(color: Colors.grey),
        cursorColor: Colors.grey[300],
        validator: validator,
        decoration: InputDecoration(
          filled: true,
          labelText: label,
          contentPadding: const EdgeInsets.all(10),
          hintStyle: const TextStyle(color: Colors.grey),
          hintText: hintText,
          fillColor: Colors.grey,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
