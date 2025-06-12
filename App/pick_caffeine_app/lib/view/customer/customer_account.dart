// 내 정보 페이지
/*
// ----------------------------------------------------------------- //
  - title         : My Account Page
  - Description   :
  - Author        : Gam Seong
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.05
  - package       :

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  :
// ----------------------------------------------------------------- //
*/import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';

class CustomerAccount extends StatelessWidget {
  CustomerAccount({super.key});

  final vm = Get.put(Vmgamseong());

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    String? userId = box.read('user_id');

    if (userId != null && vm.user.isEmpty) {
      vm.information(userId);
      vm.informationreview(userId);
    }

    return Scaffold(
      appBar: AppBar(title: Text('내 정보 & 리뷰')),
      body: Obx(() {
        if (vm.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (vm.user.isEmpty) {
          return Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
        }

        final user = vm.user;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  user['user_image'] != null
                      ? ClipOval(
                          child: Image.memory(
                            base64Decode(user['user_image']),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(Icons.person, size: 80),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("🆔 ID: ${user['user_id']}"),
                      Text("👤 닉네임: ${user['user_name']}"),
                      Text("📞 연락처: ${user['phone']}"),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: Obx(() {
                if (vm.myreviews.isEmpty) {
                  return Center(child: Text('작성한 리뷰가 없습니다.'));
                }

                return ListView.builder(
                  itemCount: vm.myreviews.length,
                  itemBuilder: (context, index) {
                    final review = vm.myreviews[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: review['user_image'] != null
                            ? Image.memory(
                                base64Decode(review['user_image']),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.image),
                        title: Text(review['user_nickname'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('내용: ${review['review_content']}'),
                            Text('구매일: ${review['purchase_date'] ?? '정보 없음'}'),
                            Text('작성일: ${review['review_date']}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}
