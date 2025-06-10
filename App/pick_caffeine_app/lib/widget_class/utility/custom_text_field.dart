import 'package:flutter/material.dart';
import 'package:pick_caffeine_app/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.readOnly = false
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      cursorColor: AppColors.brown,
      decoration: InputDecoration(
        labelText: label,
        focusColor: AppColors.lightbrown,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: AppColors.white,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.lightbrown)
        )
      ),
      readOnly: readOnly,
    );
  }
}