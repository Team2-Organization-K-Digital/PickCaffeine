import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/view/customer/customer_store_detail.dart';
import 'package:pick_caffeine_app/view/store/store_main_bottom_tabbar.dart';
import 'package:pick_caffeine_app/vm/changjun/customer_tabbar.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
import 'package:pick_caffeine_app/vm/Eunjun/vm_handler_temp.dart';
import 'package:pick_caffeine_app/model/kwonhyong/kwonhyoung_controller.dart';
import 'package:pick_caffeine_app/vm/oder_list.dart';

void main() {
  Get.put(JunTemp());
  Get.put(CustomerTabbar());
  Get.put(VmHandlerTemp());
  Get.put(RequestController());
  Get.put(InquiryController());
  Get.put(DeclarationController());
  Get.put(Order());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    if (Device.get().isTablet) {
      return GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),

        home: StoreMainBottomTabbar(),
      );
    }
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      home: CustomerStoreDetail(),
    );
  }
}
