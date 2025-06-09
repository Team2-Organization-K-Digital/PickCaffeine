// 찜 매장 목록 페이지
/*
// ----------------------------------------------------------------- //
  - title         : My Pick Page
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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/vm/oder_list.dart';

class CustomerMyPick extends StatelessWidget {
  const CustomerMyPick({super.key});

  @override
  Widget build(BuildContext context) {
    final Order order = Get.find<Order>();
    order.fetchMyStore(11.toString());
              order.fetchMyStoreCount('111');
              order.fetchReviewCount('111');

    return Scaffold(
      appBar: AppBar(
        title: Text('찜한 매장'),
      ),
      body: Obx(() {
        if (order.myStore.isEmpty) {
          return Center(child: Text('찜한 매장이 없습니다.'));
        }

        return Padding(
          padding: EdgeInsets.all(8.0),
          child: GridView.builder(
            itemCount: order.myStore.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 두개씩
              crossAxisSpacing: 10, // 사이 간격
              mainAxisSpacing: 10, // 전체 간격 
              childAspectRatio: 3 / 4, // 가로 세로 비율
            ),
            itemBuilder: (context, index) {
              final store = order.myStore[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        child: order.myStore[index]['image_1'] != null && order.myStore[index]['image_1'].toString().isNotEmpty
                            ? Image.memory(
                                base64Decode(order.myStore[index]['image_1']),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
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
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(Icons.star_outlined),
                        Text(order.storeCount.toString()),
                        Icon(Icons.chat_bubble_outline_rounded),
                        Text(order.reviewCount.toString())
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
