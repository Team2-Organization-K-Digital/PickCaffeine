// 고객 찜한 매장 리스트 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Customer My Pick Page (Customer)
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/view/customer/customer_store_detail.dart';
import 'package:pick_caffeine_app/vm/changjun/store_list_handler.dart';
import 'package:pick_caffeine_app/vm/seoyun/vm_handler.dart';

class CustomerMyPick extends StatelessWidget {
  CustomerMyPick({super.key});
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final Order order = Get.find<Order>();
    order.fetchMyStore(box.read('loginId'));

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          backgroundColor: AppColors.white,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('내가 저장한 카페', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(width: 8),
              Icon(Icons.smart_toy_rounded, color: AppColors.brown),
            ],
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      body: Obx(() {
        if (order.myStore.isEmpty) {
          return Center(child: Text('찜한 매장이 없습니다.'));
        }

        return Padding(
          padding: EdgeInsets.all(12.0),
          child: GridView.builder(
            itemCount: order.myStore.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 두개씩
              crossAxisSpacing: 10, // 사이 간격
              mainAxisSpacing: 10, // 전체 간격 아마도..?
              childAspectRatio: 3 / 4, // 가로 세로 비율
            ),
            
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  await box.write('storeId', order.myStore[index]['store_id']);
                  Get.to(() => CustomerStoreDetail());
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: AppColors.white,
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child:
                              order.myStore[index]['image_1'] != null &&
                                      order.myStore[index]['image_1']
                                          .toString()
                                          .isNotEmpty
                                  ? Image.memory(
                                    base64Decode(
                                      order.myStore[index]['image_1'],
                                    ),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Icon(Icons.error),
                                  )
                                  : Container(
                                    color: Colors.grey[200],
                                    child: Icon(Icons.store, size: 40),
                                  ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          order.myStore[index]['store_name'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 30, 10),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween, // 공간 균등 분배
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100, // 배경색 지정
                                borderRadius: BorderRadius.circular(
                                  6,
                                ), // 둥근 모서리
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    size: 18,
                                    color: AppColors.red,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '찜 ${order.myStore[index]['store_like_count']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightbrownopac,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.chat,
                                    size: 18,
                                    color: AppColors.brown,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '리뷰 ${order.myStore[index]['review_count']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.brown,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
