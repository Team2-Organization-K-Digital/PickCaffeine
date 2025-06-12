import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/view/customer/customer_home_list.dart';
import 'package:pick_caffeine_app/view/customer/customer_home_tabbar.dart';
import 'package:pick_caffeine_app/view/customer/customer_purchase_list.dart';
import 'package:pick_caffeine_app/view/customer/customer_store_detail.dart';
import 'package:pick_caffeine_app/view/login/login.dart';
import 'package:pick_caffeine_app/view/store/store_chart_duration.dart';
import 'package:pick_caffeine_app/view/store/store_main_bottom_tabbar.dart';
import 'package:pick_caffeine_app/vm/changjun/customer_tabbar.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
import 'package:pick_caffeine_app/vm/eunjun/vm_handler_temp.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';
import 'package:pick_caffeine_app/vm/kwonhyoung/kwonhyoung_controller.dart';
import 'package:pick_caffeine_app/vm/seoyun/vm_handler.dart';
import 'package:pick_caffeine_app/vm/seoyun/vm_image_handler.dart';

void main() {
  Get.put(JunTemp());
  Get.put(CustomerTabbar());
  Get.put(VmHandlerTemp());
  Get.put(InquiryController());
  Get.put(DeclarationController());
  Get.put(Order());
  Get.put(VmImageHandler());
  Get.put(Vmgamseong());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    if (Device.get().isPhone) {
      //Do some notch business
      return GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: Login(),
      );
    }
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: CustomerPurchaseList(),
    );
  }
}
