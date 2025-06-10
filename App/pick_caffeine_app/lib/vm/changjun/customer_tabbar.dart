import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerTabbar extends GetxController with GetSingleTickerProviderStateMixin{
  late TabController customertabController;
  final RxInt customercurrentIndex = 0.obs;
// ------------------------------------------------------------ //
  @override
  void onInit() {
    super.onInit();
    customertabController = TabController(length: 2, vsync: this);
    customertabController.addListener(() {
      customercurrentIndex.value = customertabController.index;
    });
  }
// ------------------------------------------------------------ //
  @override
  void onClose() {
    customertabController.dispose();
    super.onClose();
  }
// ------------------------------------------------------------ //
}