// 매장 상세 페이지 (정보)
/*
// ----------------------------------------------------------------- //
  - title         : Store Detail Page (Information)
  - Description   :
  - Author        : Kim EunJun
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.08
  - package       : 

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  :
// ----------------------------------------------------------------- //
*/

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/model/Eunjun/store.dart';
import 'package:pick_caffeine_app/view/customer/customer_products_list.dart';
import 'package:pick_caffeine_app/view/customer/customer_store_review.dart';
import 'package:pick_caffeine_app/view/store/store_home_info.dart';
import 'package:pick_caffeine_app/view/store/store_home_review.dart';

import 'package:pick_caffeine_app/vm/eunjun/vm_handler_temp.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CustomerStoreDetail extends StatelessWidget {
  CustomerStoreDetail({super.key});
  final handler = Get.find<VmHandlerTemp>();
  final storeId = "111";

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final user_id = box.read('loginId');
    final storeId = box.read('storeId');
    handler.fetchValue = false;
    handler.storeImages.clear();
    handler.fetchStore(storeId);
    handler.fetchMyStores(user_id);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          notificationPredicate: (notification) => false,
        ),
        body: Obx(
          () =>
              handler.loginStore.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Stack(
                    children: [
                      NestedScrollView(
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 360,
                                      child:
                                          handler.storeImages.isEmpty
                                              ? Center(
                                                child: Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                ),
                                              )
                                              : Obx(
                                                () => Stack(
                                                  children: [
                                                    CarouselSlider(
                                                      items:
                                                          handler.storeImages,
                                                      options: CarouselOptions(
                                                        height:
                                                            350, // height 와 viewportFraction 을 기준으로 이미지의 크기가 설정됨.
                                                        autoPlay: false,
                                                        viewportFraction:
                                                            1, // 각 페이지가 차지하는 viewport의 정도임. 0.8로 설정하면 Indicator 가 없는 슬라이드 구성가능함.
                                                        enlargeCenterPage:
                                                            true, // 이미지보다 화면이 클 수 있는지 설정
                                                        initialPage:
                                                            0, // 초기 페이지 인덱스
                                                        onPageChanged: (
                                                          index,
                                                          reason,
                                                        ) {
                                                          handler
                                                                  .activeIndex
                                                                  .value =
                                                              index; // 페이지가 변경될 때, indicator 의 인덱스를 변경함.
                                                        },
                                                      ),
                                                    ),
                                                    Positioned.fill(
                                                      //slider 의 높이를 Stack 의 크기만큼 늘려주기 위해서 Positioned.fill 사용함
                                                      child: Align(
                                                        alignment:
                                                            Alignment
                                                                .bottomCenter, // 하단 가운데 정렬
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets.only(
                                                                bottom: 10.0,
                                                              ),
                                                          alignment:
                                                              Alignment
                                                                  .bottomCenter,
                                                          child: AnimatedSmoothIndicator(
                                                            activeIndex:
                                                                handler
                                                                    .activeIndex
                                                                    .value,
                                                            count:
                                                                handler
                                                                    .storeImages
                                                                    .length,
                                                            effect: SlideEffect(
                                                              dotHeight: 10,
                                                              dotWidth: 10,
                                                              activeDotColor:
                                                                  AppColors
                                                                      .grey,
                                                              dotColor: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                    0.6,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      // : ListView.builder(
                                      //   scrollDirection:
                                      //       Axis.horizontal,

                                      //   itemCount:
                                      //       handler.storeImages.length,
                                      //   itemBuilder: (context, index) {
                                      //     print(
                                      //       handler.storeImages.length,
                                      //     );
                                      //     return SizedBox(
                                      //       height: 350,
                                      //       child:
                                      //           handler
                                      //               .storeImages[index],
                                      //     );
                                      //   },
                                      // ),
                                    ),

                                    // 가게 이름 + 수정 버튼
                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Text(
                                    //       handler.loginStore.first.store_name,
                                    //       style: TextStyle(fontSize: 30),
                                    //     ),
                                    //   ],
                                    // ),
                                    // SizedBox(height: 20),
                                    // // TabBar
                                    // TabBar(
                                    //   controller: handler.storeInfoController,
                                    //   tabs: [Tab(text: '정보'), Tab(text: '리뷰')],
                                    //   onTap: (value) {
                                    //     handler.infoReivewTabIndex.value =
                                    //         value;
                                    //   },
                                    // ),
                                    // SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                            SliverPersistentHeader(
                              pinned: true,
                              floating: false,
                              delegate: TabPersistentHeaderDelegate(),
                            ),
                          ];
                        },

                        body: TabBarView(
                          controller: handler.storeInfoController,
                          children: [StoreHomeInfo(), CustomerStoreReview()],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: MediaQuery.of(context).size.width * 0.05,
                        child: IconButton(
                          onPressed: () async {
                            final myStore = handler.myStores.where(
                              (ms) => ms.store_id == storeId,
                            );
                            if (myStore.isEmpty) {
                              final myStores = MyStores(
                                user_id: user_id,
                                store_id: storeId,
                                selected_date: DateTime.now().toString(),
                              );
                              await handler.insertMyStores(myStores);
                              await handler.fetchMyStores(user_id);
                            } else {
                              await handler.deleteMyStores(storeId);
                              await handler.fetchMyStores(user_id);
                            }
                          },
                          icon: Icon(
                            Icons.favorite_outline,
                            color:
                                handler.myStores
                                        .where((ms) => ms.store_id == storeId)
                                        .isEmpty
                                    ? AppColors.grey
                                    : AppColors.lightpick,
                            size: 50,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          color: Theme.of(context).colorScheme.surface,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Divider(),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: AppColors.white,
                                  backgroundColor: AppColors.lightbrown,

                                  fixedSize: Size(300, 50),
                                ),
                                onPressed: () async {
                                  await handler.fetchLastPurchase();
                                  box.write("storeId", '111');
                                  box.write(
                                    "storeName",
                                    handler.loginStore.first.store_name,
                                  );
                                  box.write(
                                    'purchaseNum',
                                    handler.purchaseNum.value,
                                  );
                                  Get.to(() => CustomerProductsList());
                                },
                                child: Text(
                                  '주문 하기',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(height: 25),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

class TabPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final handler = Get.find<VmHandlerTemp>();

  TabPersistentHeaderDelegate();

  @override
  double get minExtent => 110;

  @override
  double get maxExtent => 110;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
                  child: Text(
                    handler.loginStore.first.store_name,
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // TabBar
            TabBar(
              controller: handler.storeInfoController,
              tabs: [
                Tab(
                  child: Text(
                    '가게 정보',
                    style: TextStyle(color: AppColors.black),
                  ),
                ),
                Tab(
                  child: Text('리뷰', style: TextStyle(color: AppColors.black)),
                ),
              ],
              onTap: (value) {
                handler.infoReivewTabIndex.value = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
