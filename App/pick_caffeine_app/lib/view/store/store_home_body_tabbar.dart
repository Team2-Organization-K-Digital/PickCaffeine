import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/view/store/store_home_info.dart';
import 'package:pick_caffeine_app/view/store/store_home_review.dart';
import 'package:pick_caffeine_app/vm/Eunjun/vm_handler_temp.dart';

class StoreHomeBodyTabbar extends StatelessWidget {
  StoreHomeBodyTabbar({super.key});
  final handler = Get.find<VmHandlerTemp>();

  @override
  Widget build(BuildContext context) {
    handler.fetchLoginStore(111.toString());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                                    SizedBox(height: 360),
                                    // Switch + 버튼 영역
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Switch(
                                          value: handler.openCloseValue.value,
                                          onChanged: (value) {
                                            handler.openCloseValue.value =
                                                value;
                                          },
                                        ),
                                        Text(
                                          handler.openCloseValue.value
                                              ? "판매 중"
                                              : "준비 중",
                                        ),
                                        Switch(
                                          value:
                                              handler.closeForeverValue.value,
                                          onChanged: (value) {
                                            handler.closeForeverValue.value =
                                                value;
                                          },
                                        ),
                                        Text(
                                          handler.closeForeverValue.value
                                              ? "영업 중   "
                                              : "영업 종료",
                                        ),
                                        ElevatedButton(
                                          onPressed: () {},
                                          child: Text('회원정보 수정'),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    // 가게 이름 + 수정 버튼
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          handler.loginStore.first.store_name,
                                          style: TextStyle(fontSize: 30),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            //
                                          },
                                          child: Text("가게 정보 수정"),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    // TabBar
                                    TabBar(
                                      controller: handler.storeInfoController,
                                      tabs: [Tab(text: '정보'), Tab(text: '리뷰')],
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                          ];
                        },
                        body: IndexedStack(
                          index: handler.storeInfoController.index,
                          children: [StoreHomeInfo(), StoreHomeReview()],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          color: Theme.of(context).colorScheme.surface,
                          child: Column(
                            children: [
                              Divider(),
                              ElevatedButton(
                                onPressed: () {},
                                child: Text('메뉴 보기'),
                              ),
                              SizedBox(height: 20),
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
