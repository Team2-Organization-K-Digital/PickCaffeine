import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/view/customer/customer_product_options.dart';
import 'package:pick_caffeine_app/view/login/login.dart';
import 'package:pick_caffeine_app/view/store/store_home_body_tabbar.dart';
import 'package:pick_caffeine_app/view/store/store_home_info.dart';
import 'package:pick_caffeine_app/view/store/store_products_list.dart';
import 'package:pick_caffeine_app/vm/Eunjun/vm_handler_temp.dart';

void main() {
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
      home: StoreHomeBodyTabbar(),
    );
  }
}
