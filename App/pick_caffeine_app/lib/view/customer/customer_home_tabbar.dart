// 홈 페이지 상단 탭바
/*
// ----------------------------------------------------------------- //
  - title         : 고객의 홈 페이지 상단 탭바
  - Description   : 고객 회원이 처음 로그인 했을 때 나타나는 list page 를 포함한
  -                 map page 를 연결하는 상단 body tabbar
  - Author        : Lee ChangJun
  - Created Date  : 2025.06.11
  - Last Modified : 2025.06.11
  - package       : GetX

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.11 v1.0.0  : body tabbar 의 제작 및 화면 layout issue 해결,
  -                      merge 된 팀원들의 작업 page 연결 확인
// ----------------------------------------------------------------- //
*/
// ----------------------------------------------------------------- //
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/view/customer/customer_home_list.dart';
import 'package:pick_caffeine_app/view/customer/customer_home_map.dart';
import 'package:pick_caffeine_app/vm/changjun/customer_tabbar.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
import 'package:pick_caffeine_app/widget_class/utility/button_brown.dart';
// ----------------------------------------------------------------- //
class CustomerHomeTabbar extends StatelessWidget {
  CustomerHomeTabbar({super.key});
  final tabHandler = Get.find<CustomerTabbar>();
  final storeHandler = Get.find<JunTemp>();
  final TextEditingController searchController = TextEditingController();
  // ----------------------------------------------------------------- //
  @override
  Widget build(BuildContext context) {
    storeHandler.fetchStore();
  // ----------------------------------------------------------------- //
    return Obx(
      () =>
      storeHandler.isLoading.value
      ? Center(child: CircularProgressIndicator())
      : Scaffold(
        appBar: AppBar(toolbarHeight: 0),
        body: SingleChildScrollView(
          child: Column(
            children: [
// textfield : for search
              Row(
                children: [
                  SizedBox(width: 15),
                  SizedBox(
                    width: 260,
                    child: SearchBar(
                      surfaceTintColor: MaterialStatePropertyAll(
                        Colors.white,
                      ),
                      shadowColor: MaterialStatePropertyAll(
                        Colors.white,
                      ),
                      // onTap: () => Get.to(CustomerHomeMap()),
                      hintText: '검색',
                      controller: searchController,
                    ),
                  ),
                  SizedBox(width: 20),
// button : for search
                  ButtonBrown(
                    text: '검색',
                    onPressed: () {
                      //
                    },
                  ),
                ],
              ),
// body tabbar
              TabBar(
                controller: tabHandler.customerbodyController,
                onTap: (value) {
                  tabHandler.customerbodyController.index = value;
                  tabHandler.customerBodyIndex.value = value;
                },
// body tabbar : list
                tabs: [Tab(text: '매장 리스트'), Tab(text: '지도 보기')],
              ),
// body tabbar : layout
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
// body tabbar : screen
                child: IndexedStack(
                  index: tabHandler.customerBodyIndex.value,
                  children: [CustomerHomeList(), CustomerHomeMap()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
