
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:pick_caffeine_app/view/login/login.dart';
import 'package:pick_caffeine_app/vm/changjun/customer_tabbar.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
import 'package:pick_caffeine_app/vm/eunjun/image_provider.dart';
import 'package:pick_caffeine_app/vm/eunjun/vm_handler_temp.dart';
import 'package:pick_caffeine_app/vm/gamseong/image_vm.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';
import 'package:pick_caffeine_app/vm/kwonhyoung/kwonhyoung_controller.dart';

import 'package:pick_caffeine_app/vm/seoyun/vm_handler.dart';

void main() async{
  await GetStorage.init();
  Get.put(JunTemp());
  Get.put(CustomerTabbar());
  Get.put(CustomerTabbar());
  Get.put(VmHandlerTemp());
  Get.put(Vmgamseong());
  Get.put(InquiryController());
  Get.put(DeclarationController());
  Get.put(Order());
  Get.put(ImageModel());
  Get.put(ImageModelgamseong());

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
      home: Login(),
    );
  }
}
