import 'package:flutter/material.dart';
import 'package:pick_caffeine_app/app_colors.dart';

class ButtonLightBrown extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ButtonLightBrown({
    super.key,
    required this.text,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightbrown,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text,style: TextStyle(fontWeight: FontWeight.bold),),
    );
  }
}

