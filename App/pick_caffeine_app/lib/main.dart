import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pick_caffeine_app/view/customer/customer_home_map.dart';

import 'package:pick_caffeine_app/vm/image_vm_dart';  
import 'package:pick_caffeine_app/vm/vm_store_update.dart';

void main() {
  Get.put<ImageModel>(ImageModel());
  Get.put(VmStoreUpdate());
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
      home: CustomerHomeMap(),
    );
  }
}
