// 홈 페이지 (바텀 탭바)
/*
// ----------------------------------------------------------------- //
  - title         : MainBottomTabbar (Store)
  - Description   : 
  - Author        : Kim Eunjun
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.08
  - package       : 

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  :
// ----------------------------------------------------------------- //
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/view/store/store_home_body_tabbar.dart';
import 'package:pick_caffeine_app/view/store/store_purchase_list.dart';
import 'package:pick_caffeine_app/vm/eunjun/vm_handler_temp.dart';

class StoreMainBottomTabbar extends StatelessWidget {
  StoreMainBottomTabbar({super.key});
  final handler = Get.find<VmHandlerTemp>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: TabBarView(
          controller: handler.storeMainController,
          children: [StoreHomeBodyTabbar(), StorePurchaseList()],
        ),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            iconSize: 35,
            selectedFontSize: 18,
            unselectedFontSize: 16,
            unselectedItemColor: AppColors.white,
            selectedItemColor: AppColors.lightbrown,
            backgroundColor: AppColors.brown,
            currentIndex: handler.bottomTabIndex.value,
            onTap: (index) {
              handler.storeMainController.index = index;
              handler.bottomTabIndex.value = index;
            },
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'label'),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt),
                label: '주문 내역',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: '매출 현황',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
