import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pick_caffeine_app/model/kwonhyong/purchase_cart.dart';
import 'package:pick_caffeine_app/view/customer/customer_store_detail.dart';

import 'package:pick_caffeine_app/view/store/store_home_body_tabbar.dart';
import 'package:pick_caffeine_app/view/store/store_main_bottom_tabbar.dart';
import 'package:pick_caffeine_app/vm/Eunjun/store_main_tabbar.dart';

import 'package:pick_caffeine_app/vm/Eunjun/vm_handler_temp.dart';

void main() async {
  Get.put(VmHandlerTemp());
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
      home: StoreMainBottomTabbar(),
    );
  }
}
