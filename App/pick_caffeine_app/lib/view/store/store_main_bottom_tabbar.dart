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
import 'package:get_storage/get_storage.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/view/store/store_chart_duration.dart';
import 'package:pick_caffeine_app/view/store/store_home_body_tabbar.dart';
import 'package:pick_caffeine_app/view/store/store_purchase_list.dart';
import 'package:pick_caffeine_app/vm/changjun/chart_handler.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
import 'package:pick_caffeine_app/vm/eunjun/vm_handler_temp.dart';

class StoreMainBottomTabbar extends StatelessWidget {
  StoreMainBottomTabbar({super.key});
  final handler = Get.find<VmHandlerTemp>();
  final box = GetStorage();
  // ----------------------------------------------------- //
  // ChangJun : Chart handler
  final chartHandler = Get.find<JunTemp>();
  final DateTime now = DateTime.now();
  // ----------------------------------------------------- //

  @override
  Widget build(BuildContext context) {
    // ----------------------------------------------------- //
    // ChangJun : Chart funtions
    // chartHandler.fetchChart();
    chartHandler.fetchDuration();
    chartHandler.fetchYearDuration();
    // chartHandler.fetchProductChart(now.year, now.month);
    // chartHandler.fetchQuantityChart(now.year, now.month);
    // ----------------------------------------------------- //
    return PopScope(
      canPop: false,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: Stack(
            children: [
              TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: handler.storeMainController,
                children: [
                  StoreHomeBodyTabbar(),
                  StorePurchaseList(),
                  StoreChartDuration(),
                ],
              ),
              Positioned(
                top: 40,
                left: 20,
                child: IconButton(
                  onPressed: () {
                    Get.back();
                    handler.fetchValue.value = false;
                  },

                  icon: Icon(Icons.logout_outlined, size: 50),
                ),
              ),
            ],
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
      ),
    );
  }
}
