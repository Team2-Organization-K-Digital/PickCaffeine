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
      style: TextStyle(color: AppColors.brown),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.brown),
        focusColor: AppColors.brown,
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.brown, width: 2)),
        // border: const OutlineInputBorder(
        //   borderSide: BorderSide(color: AppColors.brown, width: 2)
        // ),
        filled: true,
        fillColor: AppColors.white,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.brown, width: 2)
        ),
      ),
      readOnly: readOnly,
    );
  }
}