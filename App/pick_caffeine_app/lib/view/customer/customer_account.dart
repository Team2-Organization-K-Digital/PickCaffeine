// // // 내 정보 페이지
// // /*
// // // ----------------------------------------------------------------- //
// //   - title         : My Account Page
// //   - Description   :
// //   - Author        : Gam Seong
// //   - Created Date  : 2025.06.05
// //   - Last Modified : 2025.06.05
// //   - package       :

// // // ----------------------------------------------------------------- //
// //   [Changelog]
// //   - 2025.06.05 v1.0.0  :
// // // ----------------------------------------------------------------- //
// //* 
// import 'dart:convert';

// import 'package:flutter/material.dart';

// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';
// import 'package:pick_caffeine_app/widget_class/utility/button_light_brown.dart';

// class CustomerAccount extends StatelessWidget {
//   CustomerAccount({super.key});
//   final vm = Get.find<Vmgamseong>();
//   final box = GetStorage();

//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final id = box.read('loginId');
//       if (id != null && vm.user.isEmpty) {
//         vm.getInformation();
//         vm.getMyReviews(id);
//       }
//     });

//     return Scaffold(
//       appBar: AppBar(title: Text('내 정보 & 리뷰')),
//       body: Obx(() {
//         if (vm.user.isEmpty) {
//           return Center(child: CircularProgressIndicator());
//         }

//         final user = vm.user;

//         return Column(
//           children: [
//             Row(
//               children: [
//                 user['user_image'] != null && user['user_image'] != ''
//                     ? ClipOval(
//                         child: Image.memory(
//                           base64Decode(user['user_image']),
//                           width: 80,
//                           height: 80,
//                           fit: BoxFit.cover,
//                         ),
//                       )
//                     : Icon(Icons.person, size: 80),
//                 ButtonLightBrown(
//                   text: "내정보수정",
//                   onPressed: () => Get.to(() => CustomerAccount()),
//                 ),
//                 SizedBox(width: 20),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("👤 닉네임: ${user['user_nickname'] ?? ''}"),
//                     Text("📞 연락처: ${user['user_phone'] ?? ''}"),
//                     Text("📧 이메일: ${user['user_email'] ?? ''}"),
//                   ],
//                 ),
//               ],
//             ),
//             Expanded(
//               child: Obx(() {
//                 if (vm.myreviews.isEmpty) {
//                   return Center(child: Text("작성한 리뷰가 없습니다."));
//                 }
//                 return ListView.builder(
//                   itemCount: vm.myreviews.length,
//                   itemBuilder: (context, index) {
//                     final review = vm.myreviews[index];
//                     return Card(
//                       margin: EdgeInsets.all(10),
//                       child: ListTile(
//                         leading: review['user_image'] != null &&
//                                 review['user_image'] != ''
//                             ? Image.memory(
//                                 base64Decode(review['user_image']),
//                                 width: 50,
//                                 height: 50,
//                                 fit: BoxFit.cover,
//                               )
//                             : Icon(Icons.person),
//                         title: Text(review['user_nickname'] ?? ''),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("내용: ${review['review_content']}"),
//                             Text("작성일: ${review['review_date']}"),
//                             Text("상태: ${review['review_state']}"),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               }),
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }