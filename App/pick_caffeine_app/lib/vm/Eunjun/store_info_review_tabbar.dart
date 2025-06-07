import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreInfoReviewTabbar extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController storeInfoController;
  var closeForeverValue = false.obs;
  var openCloseValue = false.obs;

  @override
  void onInit() {
    super.onInit();
    storeInfoController = TabController(length: 2, vsync: this);
  }

  @override
  void onClose() {
    storeInfoController.dispose();
    super.onClose();
  }
}
