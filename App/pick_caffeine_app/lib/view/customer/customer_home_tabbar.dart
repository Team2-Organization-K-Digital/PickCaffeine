import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/view/customer/customer_home_list.dart';
import 'package:pick_caffeine_app/view/customer/customer_home_map.dart';
import 'package:pick_caffeine_app/vm/changjun/customer_tabbar.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
import 'package:pick_caffeine_app/vm/changjun/store_list_handler.dart';
import 'package:pick_caffeine_app/widget_class/utility/button_brown.dart';

class CustomerHomeTabbar extends StatelessWidget {
  CustomerHomeTabbar({super.key});
  final tabHandler = Get.find<CustomerTabbar>();
  final storeHandler = Get.find<JunTemp>();
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    storeHandler.fetchStore();
    return Obx(
      () => 
      storeHandler.isLoading.value?
          Center(child: CircularProgressIndicator()):
        
        // if (storeHandler.storeData.isEmpty) {
        //   return Center(child: Text('데이터를 불러오는데 실패 했습니다.'));
        // }
        Scaffold(
        appBar: AppBar(toolbarHeight: 0),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 15),
                  SizedBox(
                    width: 310,
                    child: SearchBar(
                      surfaceTintColor: MaterialStatePropertyAll(Colors.white),
                      shadowColor: MaterialStatePropertyAll(Colors.white) ,
                      // onTap: () => Get.to(CustomerHomeMap()),
                      hintText: '검색',
                      controller: searchController,
                    )
                  ),
                  SizedBox(width: 20),
                  ButtonBrown(
                    text: '검색',
                    onPressed: () {
                      //
                    },
                  ),
                ],
              ),
              TabBar(
                controller: tabHandler.customerbodyController,
                onTap: (value) {
                  tabHandler.customerbodyController.index = value;
                  tabHandler.customerBodyIndex.value = value;
                },
                tabs: [Tab(text: '매장 리스트'), Tab(text: '지도 보기')],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
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
