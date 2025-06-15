import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/view/customer/customer_home_list.dart';
import 'package:pick_caffeine_app/view/customer/customer_home_map.dart';
import 'package:pick_caffeine_app/vm/changjun/customer_tabbar.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_gps_handller.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';
import 'package:pick_caffeine_app/widget_class/utility/button_brown.dart';

// ----------------------------------------------------------------- //
class CustomerHomeTabbar extends StatelessWidget {
  CustomerHomeTabbar({super.key});

  final tabHandler = Get.find<CustomerTabbar>();
  final storeHandler = Get.find<JunTemp>();
  final TextEditingController searchController = TextEditingController();
  final vmgpshandller = Get.find<VmGpsHandller>();

  @override
  Widget build(BuildContext context) {
    storeHandler.fetchStore();
    // vmgpshandleer.checkLocationPermission();
    vmgpshandller.loadStoresAndMarkers();
    // ----------------------------------------------------------------- //
    return Obx(
      () =>
          storeHandler.isLoading.value
              ? Center(child: CircularProgressIndicator())
              : Scaffold(
                appBar: AppBar(toolbarHeight: 0),
                body: Column(
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
                            shadowColor: MaterialStatePropertyAll(Colors.white),
                            // onTap: () => Get.to(CustomerHomeMap()),
                            hintText: '검색',
                            controller: searchController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            // 검색 기능
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 13, horizontal: 22),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('검색'),
                        ),
                      ],
                    ),
                  

                  const SizedBox(height: 15),

                  // 탭바
                  TabBar(
                    controller: tabHandler.customerbodyController,
                    onTap: (value) {
                      tabHandler.customerbodyController.index = value;
                      tabHandler.customerBodyIndex.value = value;
                    },
                    labelColor: Colors.brown,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    indicatorColor: Colors.brown,
                    indicatorWeight: 3,
                    tabs: const [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.store),
                          SizedBox(width: 5),
                          Tab(text: '매장 리스트'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_outlined),
                          SizedBox(width: 5),
                          Tab(text: '지도 보기'),
                        ],
                      ),
                    ],
                  ),

                  // 탭 화면
                  Expanded(
                    child: IndexedStack(
                      index: tabHandler.customerBodyIndex.value,
                      children: [
                        CustomerHomeList(),
                        CustomerHomeMap(),
                      ],
                    ),
                  ),
              ],
            ),
      )
    );
  }
}
