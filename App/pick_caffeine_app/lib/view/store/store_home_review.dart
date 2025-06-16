// 홈 페이지 (매장, review)
/*
// ----------------------------------------------------------------- //
  - title         : Review Home Page (Store)
  - Description   :
  - Author        : Gam Sung
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
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';

// 기존 구조와 충돌 없이 작동되게 storeId를 내부에서 읽음
class StoreHomeReview extends StatelessWidget {
  StoreHomeReview({super.key});
  final vm = Get.find<Vmgamseong>();
  final box = GetStorage(); // GetStorage 사용 추가

  @override
  Widget build(BuildContext context) {
    final storeId = box.read("loginId"); // 여기서 직접 storeId를 읽음
    vm.storereviews(storeId);

    return Obx(() {
      if (vm.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (vm.myreviews.isEmpty) {
        return Center(child: Text("리뷰가 없습니다."));
      }

      return ListView.builder(
        itemCount: vm.myreviews.length,
        itemBuilder: (context, index) {
          final r = vm.myreviews[index];
          final image = r['review_image'];

          return Card(
            margin: EdgeInsets.all(12),
            child: ListTile(
              title: Text(r['review_content']),
              subtitle:
                  Text("날짜: ${r['review_date']} / 상태: ${r['review_state']}"),
              leading: image != null && image != ''
                  ? Image.memory(
                      base64Decode(image),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.image_not_supported),
            ),
          );
        },
      );
    });
  }
}
