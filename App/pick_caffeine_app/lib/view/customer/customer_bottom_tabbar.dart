// 홈 페이지 하단 탭바
/*
// ----------------------------------------------------------------- //
  - title         : 고객의 홈 페이지 하단 탭바
  - Description   : 고객 회원이 처음 로그인 했을 때 나타나는 페이지 하단 탭바
  - Author        : Lee ChangJun
  - Created Date  : 2025.06.08
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
import 'package:pick_caffeine_app/view/customer/customer_home_list.dart';
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
        children: [CustomerHomeList(),CreateAccountUser()],
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
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            ],
          ),
        ),
      ),

    );
  }
}