// // 매장 상세 페이지 (리뷰)
// /*
// // ----------------------------------------------------------------- //
//   - title         : Store Detail Page (Review)
//   - Description   :
//   - Author        : gamseong
//   - Created Date  : 2025.06.05
//   - Last Modified : 2025.06.05
//   - package       :

// // ----------------------------------------------------------------- //
//   [Changelog]
//   - 2025.06.05 v1.0.0  :
// // ----------------------------------------------------------------- //
// */import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';

// class CustomerStoreReview extends StatelessWidget {
//   CustomerStoreReview({super.key});

//   final vm = Get.find<Vmgamseong>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Obx(() => Text('에러: ${vm.error.value}')), 
//           Expanded(
//             child: Obx(() {
//               if (vm.myreviews.isEmpty) {
//                 return Center(child: Text('작성한 리뷰가 없습니다.'));
//               }
//               return ListView.builder(
//                 itemCount: vm.myreviews.length,
//                 itemBuilder: (context, index) {
//                   final review = vm.myreviews[index];
//                   return Card(
//                     child: ListTile(
//                       leading: review['user_image'] != null
//                           ? Image.memory(
//                               base64Decode(review['user_image']),
//                               width: 50,
//                               height: 50,
//                               fit: BoxFit.cover,
//                             )
//                           : Icon(Icons.person),
//                       title: Text(review['user_nickname'] ?? ''),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('내용: ${review['review_content']}'),
//                           Text('작성일: ${review['review_date']}'),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }