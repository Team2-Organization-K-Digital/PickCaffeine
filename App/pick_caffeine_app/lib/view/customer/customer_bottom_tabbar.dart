// 홈 페이지 하단 탭바
/*
// ----------------------------------------------------------------- //
  - title         : 고객의 홈 페이지 하단 탭바
  - Description   : 고객 회원이 처음 로그인 했을 때 나타나는 페이지 하단 탭바
  - Author        : Lee ChangJun
  - Created Date  : 2025.06.08
  - Last Modified : 2025.06.08
  - package       : GetX

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.09 v1.0.0  : 고객이 이용할 다른 page 들을 이어주는 tabbar 구현

  - 2025.06.10 v1.0.1  : 팀원들의 작업 페이지를 탭바에 연결
// ----------------------------------------------------------------- //
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/view/customer/customer_home_list.dart';
import 'package:pick_caffeine_app/view/customer/customer_home_tabbar.dart';
import 'package:pick_caffeine_app/view/customer/customer_my_pick.dart';
import 'package:pick_caffeine_app/view/customer/customer_purchase_list.dart';
import 'package:pick_caffeine_app/view/login/create_account_user.dart';
import 'package:pick_caffeine_app/vm/changjun/customer_tabbar.dart';


class CustomerBottomTabbar extends StatelessWidget {
  CustomerBottomTabbar({super.key});
  final CustomerTabbar controller = Get.find<CustomerTabbar>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: controller.customertabController,
        children: [
          CustomerHomeTabbar(),
          CreateAccountUser(),
          // CustomerPurchaseList(),
          // CustomerMyPick()
          ],
      ),
      bottomNavigationBar: Obx(
        () => SizedBox(
          height: 110,
          child: BottomNavigationBar(
            currentIndex: controller.customercurrentIndex.value,
            backgroundColor: AppColors.brown,
            unselectedItemColor: AppColors.white,iconSize: 40,
            selectedItemColor: AppColors.lightbrown,
          
            onTap: (index) {
              controller.customertabController.index = index;
            },
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
              BottomNavigationBarItem(icon: Icon(Icons.note), label: '주문내역'),
              // BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'My Pick'),
              // BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: '내 정보'),
            ],
          ),
        ),
      ),

    );
  }
}