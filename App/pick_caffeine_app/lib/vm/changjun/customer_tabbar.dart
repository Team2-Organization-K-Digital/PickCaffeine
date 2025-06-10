import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerTabbar extends GetxController with GetTickerProviderStateMixin{
  late TabController customertabController;
  final RxInt customercurrentIndex = 0.obs;
// 홈 body tabbar 관련
  late TabController customerbodyController;
  final RxInt customerBodyIndex = 0.obs;
// ------------------------------------------------------------ //
  @override
  void onInit() {
    super.onInit();
    customertabController = TabController(length: 2, vsync: this);
    customertabController.addListener(() {
      customercurrentIndex.value = customertabController.index;
    });
    customerbodyController = TabController(length: 2, vsync: this);
    customerbodyController.addListener(() {
      customerBodyIndex.value = customerbodyController.index;
    });
  }
// ------------------------------------------------------------ //
  @override
  void onClose() {
    customertabController.dispose();
    customerbodyController.dispose();
    super.onClose();
  }
// ------------------------------------------------------------ //
}