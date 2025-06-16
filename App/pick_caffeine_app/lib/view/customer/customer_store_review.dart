// 매장 상세 페이지 (리뷰)
/*
// ----------------------------------------------------------------- //
  - title         : Store Detail Page (Review)
  - Description   :
  - Author        : gamseong
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

class CustomerStoreReview extends StatelessWidget {
  CustomerStoreReview({super.key});

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

    Widget imageWidget;
    try {
      if (image != null && image.isNotEmpty) {
        imageWidget = Image.memory(
          base64Decode(image),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        );
      } else {
        imageWidget = Icon(Icons.image_not_supported, size: 50);
      }
    } catch (e) {
      imageWidget = Icon(Icons.broken_image, size: 50);
    }

return Card(
  margin: EdgeInsets.all(12),
  child: ListTile(
    contentPadding: EdgeInsets.all(12),
    leading: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageWidget,
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          r['user_nickname'] ?? '익명 사용자',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 4),
        Text(
          r['review_content'] ?? '내용 없음',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
    subtitle: Text(
      "날짜: ${r['review_date'] ?? '-'}\n상태: ${r['review_state'] ?? '-'}",
    ),
  ),
);

  },
);
    },);}}