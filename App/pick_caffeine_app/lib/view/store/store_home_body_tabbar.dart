// 홈 페이지 (매장, tabbar)
/*
// ----------------------------------------------------------------- //
  - title         : Information Home Page (Store)
  - Description   : 매장 홈페이지 화면구성 (tabbar)
  - Author        : Kim Eunjun
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.05
  - package       : Getx, GetStorage

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  : 사진과 리뷰 제외 화면 구성 완료, 버튼 연결 스위치 연결
// ----------------------------------------------------------------- //
*/
// ----------------------------------------------------------------- //
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/view/customer/customer_store_review.dart';
import 'package:pick_caffeine_app/view/store/store_home_info.dart';
import 'package:pick_caffeine_app/view/store/store_home_review.dart';
import 'package:pick_caffeine_app/view/store/store_products_list.dart';
import 'package:pick_caffeine_app/vm/eunjun/vm_handler_temp.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// ----------------------------------------------------------------- //
class StoreHomeBodyTabbar extends StatelessWidget {
  StoreHomeBodyTabbar({super.key});
  final handler = Get.find<VmHandlerTemp>();
  final box = GetStorage();
  // ----------------------------------------------------------------- //
  @override
  Widget build(BuildContext context) {
    final storeId = box.read("loginId");
    handler.fetchStore(storeId);

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
                                      height: 350,
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
                                                        height: 350,
                                                        // height 와 viewportFraction 을 기준으로 이미지의 크기가 설정됨.
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
                                      //       child: Image.memory(
                                      //         base64Decode(
                                      //           handler
                                      //               .storeImages[index],
                                      //         ),
                                      //         fit: BoxFit.cover,
                                      //       ),
                                      //     );
                                      //   },
                                      // ),
                                    ),
                                    SizedBox(height: 20),
                                    Obx(
                                      () => Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 400,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Transform.scale(
                                                        scale: 1.3,
                                                        child: Switch(
                                                          value:
                                                              handler
                                                                  .openCloseValue
                                                                  .value,
                                                          onChanged: (value) {
                                                            if (handler
                                                                .closeForeverValue
                                                                .value) {
                                                              if (value) {
                                                                handler
                                                                    .updateStoreState(
                                                                      storeId,
                                                                      1,
                                                                    );
                                                              } else {
                                                                handler
                                                                    .updateStoreState(
                                                                      storeId,
                                                                      0,
                                                                    );
                                                              }
                                                              handler
                                                                  .openCloseValue
                                                                  .value = value;
                                                            } else {
                                                              handler
                                                                  .openCloseValue
                                                                  .value = false;
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              left: 15,
                                                            ),
                                                        child: Text(
                                                          handler
                                                                  .openCloseValue
                                                                  .value
                                                              ? "판매 중"
                                                              : "준비 중",
                                                          style: TextStyle(
                                                            fontSize: 30,
                                                            color:
                                                                AppColors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Transform.scale(
                                                        scale: 1.3,
                                                        child: Switch(
                                                          value:
                                                              handler
                                                                  .closeForeverValue
                                                                  .value,
                                                          onChanged: (value) {
                                                            if (value) {
                                                              handler
                                                                  .updateStoreState(
                                                                    storeId,
                                                                    0,
                                                                  );
                                                            } else {
                                                              handler
                                                                  .updateStoreState(
                                                                    storeId,
                                                                    -1,
                                                                  );
                                                              handler
                                                                  .openCloseValue
                                                                  .value = value;
                                                            }
                                                            handler
                                                                .closeForeverValue
                                                                .value = value;
                                                          },
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              left: 15,
                                                            ),
                                                        child: Text(
                                                          handler
                                                                  .closeForeverValue
                                                                  .value
                                                              ? "영업 중   "
                                                              : "영업 종료",

                                                          style: TextStyle(
                                                            fontSize: 30,
                                                            color:
                                                                AppColors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                right: 20,
                                              ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  fixedSize: Size(180, 45),
                                                ),
                                                onPressed: () {},
                                                child: Text(
                                                  '회원정보 수정',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
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
                        body: IndexedStack(
                          index: handler.infoReivewTabIndex.value,
                          children: [StoreHomeInfo(), CustomerStoreReview()],
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

                                  fixedSize: Size(300, 65),
                                ),
                                onPressed: () {
                                  box.write("storeId", '111');
                                  box.write(
                                    "storeName",
                                    handler.loginStore.first.store_name,
                                  );
                                  Get.to(() => StoreProductsList());
                                },
                                child: Text(
                                  '메뉴 보기',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
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
  double get minExtent => 150;

  @override
  double get maxExtent => 150;

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
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    handler.loginStore.first.store_name,
                    style: TextStyle(fontSize: 60),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(fixedSize: Size(210, 50)),
                      onPressed: () {
                        //
                      },
                      child: Text("가게 정보 수정", style: TextStyle(fontSize: 22)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            // TabBar
            TabBar(
              controller: handler.storeInfoController,
              tabs: [
                Tab(
                  child: Text(
                    '가게 정보',
                    style: TextStyle(fontSize: 30, color: AppColors.black),
                  ),
                ),
                Tab(
                  child: Text(
                    '리뷰',
                    style: TextStyle(fontSize: 30, color: AppColors.black),
                  ),
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
