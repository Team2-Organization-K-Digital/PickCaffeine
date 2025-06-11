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
import 'package:pick_caffeine_app/vm/seoyun/vm_handler.dart';

class CustomerMyPick extends StatelessWidget {
  const CustomerMyPick({super.key});

  @override
  Widget build(BuildContext context) {
    final Order order = Get.find<Order>();
    order.fetchMyStore(box.read('login_Id'));

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
              // final store = order.myStore[index];
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border_outlined),
                        Text(order.myStore[index]['store_like_count'].toString()),
                        SizedBox(width: 60,),
                        Icon(Icons.chat_bubble_outline_rounded),
                        Text(order.myStore[index]['review_count'].toString())
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
