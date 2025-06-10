import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StoreMainTabbar extends GetxController with GetTickerProviderStateMixin {
  late TabController storeInfoController;
  late TabController storeMainController;
  var closeForeverValue = false.obs;
  var openCloseValue = false.obs;
  var infoReivewTabIndex = 0.obs;
  var bottomTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    storeInfoController = TabController(length: 2, vsync: this);
    storeMainController = TabController(length: 2, vsync: this);
  }

  @override
  void onClose() {
    storeInfoController.dispose();
    storeMainController.dispose();
    super.onClose();
  }
}
