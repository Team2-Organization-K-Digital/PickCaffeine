import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/view/customer/customer_home_list.dart';
import 'package:pick_caffeine_app/view/customer/customer_home_map.dart';
import 'package:pick_caffeine_app/view/customer/customer_search.dart';
import 'package:pick_caffeine_app/vm/changjun/customer_tabbar.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';
import 'package:pick_caffeine_app/widget_class/utility/button_brown.dart';

// ----------------------------------------------------------------- //
class CustomerHomeTabbar extends StatelessWidget {
  CustomerHomeTabbar({super.key});

  final tabHandler = Get.find<CustomerTabbar>();
  final storeHandler = Get.find<JunTemp>();
  final TextEditingController searchController = TextEditingController();
  final gpshandler = Get.find<Vmgamseong>();

  @override
  Widget build(BuildContext context) {
    storeHandler.fetchStore();
    gpshandler.loadStoresAndMarkers();
    return Obx(
      () =>
          storeHandler.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Scaffold(
                appBar: AppBar(
                  toolbarHeight: 0,
                  backgroundColor: AppColors.white,
                ),
                backgroundColor: AppColors.white,
                body: Column(
                  children: [
                    const SizedBox(height: 12),

                    // 검색 바 영역
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.brown.shade200,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.brown.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.search_sharp,
                                    color: AppColors.brown,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      cursorColor: AppColors.brown,
                                      controller: searchController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '매장을 검색해보세요',
                                      ),
                                      onTap: ()async {
                                        await storeHandler.fetchStore();
                                        Get.to(()=>CustomerSearch())!.then((_) => storeHandler.fetchStore());
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
                        children: [CustomerHomeList(), CustomerHomeMap()],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
