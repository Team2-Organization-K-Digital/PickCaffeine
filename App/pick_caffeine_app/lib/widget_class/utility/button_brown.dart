import 'package:flutter/material.dart';
import 'package:pick_caffeine_app/app_colors.dart';

class ButtonBrown extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ButtonBrown({
    super.key,
    required this.text,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text,style: TextStyle(fontWeight: FontWeight.bold),),
    );
  }
}

