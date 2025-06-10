import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/view/login/login.dart';
import 'package:pick_caffeine_app/vm/changjun/customer_tabbar.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
import 'package:pick_caffeine_app/vm/eunjun/vm_handler_temp.dart';
import 'package:pick_caffeine_app/model/kwonhyong/kwonhyoung_controller.dart';

void main() {
  Get.put(JunTemp());
  Get.put(CustomerTabbar());
  // Get.put(CustomerBodyTabbar());
  Get.put(VmHandlerTemp());
  Get.put(RequestController());
  Get.put(InquiryController());
  Get.put(DeclarationController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Login(),
    );
  }
}
