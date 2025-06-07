import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pick_caffeine_app/app_colors.dart';

class MenuUtility {
  Widget unsaleContainer() {
    return Container(
      width: double.infinity,
      height: 140,
      color: AppColors.greyopac,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, size: 70, color: AppColors.brown),
            Text('품절', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
