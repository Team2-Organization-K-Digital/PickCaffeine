// 매장 주문 리스트 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Store Purchase List Page
  - Description   :
  - Author        : Jeong SeoYun
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
import 'package:pick_caffeine_app/model/purchase.dart';
import 'package:pick_caffeine_app/view/store/store_purchase_detail.dart';
import 'package:pick_caffeine_app/vm/oder_list.dart';

class StorePurchaseList extends StatelessWidget {
  const StorePurchaseList({super.key});

  @override
  Widget build(BuildContext context) {
    final Order order = Get.find<Order>();
    order.fetchPurchase(11.toString());
    order.fetchReview(11.toString());
    order.fetchStore(11.toString(), 111.toString());
    order.fetchMenu(11.toString(), 10.toString());
    order.fetchUser(10.toString());

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 100),
          Obx(() {
            return Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(0),
                shrinkWrap: true,
                itemCount: order.purchase.length,
                itemBuilder: (context, index) {
                  final Purchase purchaseList = order.purchase[index];
                  final state = int.parse(purchaseList.purchase_state);
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
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
                                      fontSize: 13,
                                      color: const Color.fromARGB(
                                        255,
                                        73,
                                        73,
                                        73,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${order.userNickname}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ), // 매장이름
                                  Text(
                                    order.menu[0]['name'].toString(),
                                    style: TextStyle(fontSize: 15),
                                  ), // 메뉴이름
                                  GestureDetector(
                                    onTap: () {
                                      // 주문 상세페이지로 감
                                      Get.to(
                                        () => StorePurchaseDetail(),
                                        arguments: [
                                          purchaseList.purchase_num,
                                          purchaseList.purchase_date,
                                          purchaseList.purchase_request,
                                          order.menu[0]['total'],
                                        ],
                                      );
                                    },
                                    child: Text(
                                      '주문 상세정보 보기',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${order.menu[0]['total'].toString()}원',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ), // 메뉴가격
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
                                      fontSize: 40,
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              state == -1
                                  ? Text('취소된 주문입니다.')
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
                                          order.fetchPurchase(11.toString());
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            237,
                                            61,
                                            61,
                                          ),
                                        ),
                                        child: Text(
                                          '주문취소',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      //주문확인 -> 제조완료 -> 수령완료 ->1->2->3
                                      // 상태에 따라 버튼 UI를 바꾼다
                                      // SizedBox(width: 30,),
                                      state == 0
                                          ? ElevatedButton(
                                            onPressed: () async {
                                              await order.updateState(
                                                1,
                                                purchaseList.purchase_num
                                                    .toString(),
                                              );
                                              await order.fetchPurchase(
                                                11.toString(),
                                              );
                                              Get.back();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFFE9C268,
                                              ),
                                            ),
                                            child: Text('주문접수'),
                                          )
                                          : state == 1
                                          ? ElevatedButton(
                                            onPressed: () async {
                                              await order.updateState(
                                                2,
                                                purchaseList.purchase_num
                                                    .toString(),
                                              );
                                              await order.fetchPurchase(
                                                11.toString(),
                                              );
                                              Get.back();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFFE9C268,
                                              ),
                                            ),
                                            child: Text('제조완료'),
                                          )
                                          : state == 2
                                          ? ElevatedButton(
                                            onPressed: () async {
                                              await order.updateState(
                                                3,
                                                purchaseList.purchase_num
                                                    .toString(),
                                              );
                                              await order.fetchPurchase(
                                                11.toString(),
                                              );
                                              Get.back();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFFE9C268,
                                              ),
                                            ),
                                            child: Text('수령완료'),
                                          )
                                          : Text(''),
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
