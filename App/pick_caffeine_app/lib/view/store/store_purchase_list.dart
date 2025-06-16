// 매장 주문내역 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Purchase List Page (Store)
  - Description   :
  - Author        : Jeong seoyun
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.05
  - package       : 

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  :
// ----------------------------------------------------------------- //
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pick_caffeine_app/model/seoyun/purchase_model.dart';
import 'package:pick_caffeine_app/view/store/store_purchase_detail.dart';
import 'package:pick_caffeine_app/vm/seoyun/vm_handler.dart';

class StorePurchaseList extends StatelessWidget {
  StorePurchaseList({super.key});

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final Order order = Get.find<Order>();
    // order.fetchPurchaseStore(box.read('loginId'));
    // order.fetchUserDetail(box.read('loginId'));
    // order.fetchMenuStore(box.read('loginId'));

    // order.fetchPurchaseStore('111');
    // order.fetchUserDetail('111');
    // order.fetchMenuStore('111');

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 100),
          Obx(() {
            // 최신 주문이 위로 오도록 정렬
            order.purchase.sort(
              (a, b) => b.purchase_date.compareTo(a.purchase_date),
            );
            return Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(0),
                shrinkWrap: true,
                itemCount: order.purchase.length,
                itemBuilder: (context, index) {
                  final Purchase purchaseList = order.purchase[index];
                  final state = BigInt.parse(purchaseList.purchase_state);
                  final purchaseNum = purchaseList.purchase_num;

                  final userInfo = order.userMap[index];

                  final List menu_store =
                      order.menuStore
                          .where((m) => m[1] == purchaseNum)
                          .toList();

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    purchaseList.purchase_date.substring(
                                      11,
                                      16,
                                    ),
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: const Color.fromARGB(
                                        255,
                                        73,
                                        73,
                                        73,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${userInfo[0]} 님',
                                    style: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ), // 고객이름
                                  Text(
                                    menu_store[0][0].toString(),
                                    style: TextStyle(fontSize: 25),
                                  ), // 메뉴이름
                                  Text(
                                    '${menu_store[0][3]}원',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ), // 메뉴가격
                                  GestureDetector(
                                    onTap: () {
                                      // 주문 상세페이지로 감
                                      Get.to(
                                        () => StorePurchaseDetail(),
                                        arguments: [
                                          purchaseList.purchase_num,
                                          purchaseList.purchase_date,
                                          userInfo[0],
                                          userInfo[1],
                                          purchaseList.purchase_request,
                                          menu_store[0][3],
                                        ],
                                      );
                                    },
                                    child: Text(
                                      '주문 상세정보 보기 ▶︎',
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 30, 40),
                              child: Column(
                                children: [
                                  Text(
                                    purchaseList.purchase_num.toString(),
                                    style: TextStyle(
                                      fontSize: 50,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    state == -1
                                        ? '주문취소'
                                        : state == 0
                                        ? '주문확인 중'
                                        : state == 1
                                        ? '제조 중'
                                        : state == 2
                                        ? '제조완료'
                                        : '수령완료',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              state == 3
                                  ? Text(
                                    '수령완료된 주문입니다.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  )
                                  : state == -1
                                  ? Text(
                                    '취소된 주문입니다.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  )
                                  : Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          // 상태를 -1로 바꿔야함
                                          order.updateState(
                                            -1,
                                            purchaseList.purchase_num
                                                .toString(),
                                          );
                                          order.fetchPurchaseStore(
                                            box.read('loginId'),
                                          );
                                          // order.fetchPurchaseStore('111');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            237,
                                            61,
                                            61,
                                          ),
                                          minimumSize: Size(300, 70),
                                        ),
                                        child: Text(
                                          '주문취소',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,
                                          ),
                                        ),
                                      ),
                                      //주문확인 -> 제조완료 -> 수령완료 ->1->2->3
                                      // 상태에 따라 버튼 UI를 바꾼다
                                      SizedBox(width: 200),
                                      state == 0
                                          ? ElevatedButton(
                                            onPressed: () async {
                                              await order.updateState(
                                                1,
                                                purchaseList.purchase_num
                                                    .toString(),
                                              );
                                              await order.fetchPurchaseStore(
                                                box.read('loginId'),
                                              );
                                              // await order.fetchPurchaseStore(
                                              //   '111'
                                              // );
                                              // Get.back();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFFE9C268,
                                              ),
                                              minimumSize: Size(300, 70),
                                            ),
                                            child: Text(
                                              '주문접수',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 30,
                                              ),
                                            ),
                                          )
                                          : state == 1
                                          ? ElevatedButton(
                                            onPressed: () async {
                                              await order.updateState(
                                                2,
                                                purchaseList.purchase_num
                                                    .toString(),
                                              );
                                              await order.fetchPurchaseStore(
                                                box.read('loginId'),
                                              );
                                              // await order.fetchPurchaseStore(
                                              //   '111'
                                              // );
                                              // Get.back();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFFE9C268,
                                              ),
                                              minimumSize: Size(300, 70),
                                            ),
                                            child: Text(
                                              '제조완료',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 30,
                                              ),
                                            ),
                                          )
                                          : state == 2
                                          ? ElevatedButton(
                                            onPressed: () async {
                                              await order.updateState(
                                                3,
                                                purchaseList.purchase_num
                                                    .toString(),
                                              );
                                              await order.fetchPurchaseStore(
                                                box.read('loginId'),
                                              );
                                              // await order.fetchPurchaseStore(
                                              //   '111'
                                              // );
                                              // Get.back();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFFE9C268,
                                              ),
                                              minimumSize: Size(300, 70),
                                            ),
                                            child: Text(
                                              '수령완료',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 30,
                                              ),
                                            ),
                                          )
                                          : Text(
                                            '수령 완료됨',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30,
                                            ),
                                          ),
                                    ],
                                  ),
                            ],
                          ),
                        ),
                        Divider(thickness: 4),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
