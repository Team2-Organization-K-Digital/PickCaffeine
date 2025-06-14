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
// import 'package:pick_caffeine_app/view/customer/customer_update_account.dart';
// import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';
// import 'package:pick_caffeine_app/widget_class/utility/button_light_brown.dart';

// class CustomerAccount extends StatelessWidget {
//   CustomerAccount({super.key});
//   final vm = Get.find<Vmgamseong>();
//   final box = GetStorage();
  

  
  
//   @override

// // Widget build(BuildContext context) {
// //   Future.delayed(Duration.zero, () {
// //   });
// //     return Scaffold(
// //       body: Obx(() {
// //         final user = vm.user;
// //         return Column(mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Row(
// //               children: [
// //                 user['user_image'] != null && user['user_image'] != ''
// //                     ? ClipOval(
// //                         child: Image.memory(
// //                           base64Decode(user['user_image']),
// //                           width: 80,
// //                           height: 80,
// //                           fit: BoxFit.cover,
// //                         ),
// //                       )
// //                     : Icon(Icons.person, size: 80),
// //                 ButtonLightBrown(
// //                   text: "내정보수정",
// //                   onPressed: () => Get.to(() => CustomerUpdateAccount(),
// //                   arguments: [
// //                   user['user_id'],
// //                   user['user_password'],
// //                   user['user_nickname'],
// //                   user['user_email'],
// //                   user['user_phone'],
// //                   ],
// //                   ),
// //                 ),
// //                 SizedBox(width: 20),
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text("👤 닉네임: ${user['user_nickname'] ?? ''}"),
// //                     Text("📞 연락처: ${user['user_phone'] ?? ''}"),
// //                     Text("📧 이메일: ${user['user_email'] ?? ''}"),
// //                   ],
// //                 ),
// //               ],
// //             ),

            


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/instance_manager.dart';
import 'package:pick_caffeine_app/view/customer/customer_update_account.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pick_caffeine_app/vm/gamseong/image_vm.dart';

import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';

class CustomerAccount extends StatelessWidget {
  CustomerAccount({super.key});
  final vm = Get.find<Vmgamseong>(); // vm_inforemation.dart에서 정의
  final image = Get.find<ImageModelgamseong>();
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final userId = box.read('loginId');
    vm.informationuserid(userId);
    vm.userreviews();
  

  return Scaffold(
  body: Obx(() {
        final imageBase64 = vm.user['user_image'] ?? '';
        return vm.user.isEmpty
            ? Center(
              child:
              CircularProgressIndicator()
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 프로필 이미지
        ClipOval(
          child: imageBase64.isNotEmpty
            ? Image.memory(
            base64Decode(imageBase64),
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            )
              : Container(
            width: 100,
            height: 100,
            color: Colors.grey[300],
            child: Icon(Icons.person, size: 60),
          ),
  ),

  // 텍스트 정보
  Row(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("닉네임: ${vm.user['user_nickname']}"),
          Text("전화번호: ${vm.user['user_phone']}"),
          Text("이메일: ${vm.user['user_email']}"),
        ],
      ),
    ElevatedButton(
      onPressed: () {
        Get.to(() => CustomerUpdateAccount(),
        arguments: [
          vm.user['user_nickname'],
          vm.user['user_id'],
          vm.user['user_password'],
          vm.user['user_phone'],
          vm.user['user_email'],
          vm.user['user_image'],

        ]
        
        );
      },
      child: Text("정보수정"),)
    ],
  ),

  const SizedBox(height: 10), 

  // 리뷰 카드
  Obx(() {
    if (vm.review.isEmpty) {
      return Text("작성한 리뷰가 없습니다.");
    }
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("스토어 ID: ${vm.review['store_id']}"),
            Text("내용: ${vm.review['review_content']}"),
            Text("날짜: ${vm.review['review_date']}"),
            Text("상태: ${vm.review['review_state']}"),
            const SizedBox(height: 10),
            vm.review['review_image'] != null &&
                    vm.review['review_image'] != ''
                ? Image.memory(

                    base64Decode(vm.review['review_image']),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[200],
                    child: Icon(Icons.image_not_supported),
                  ),
          ],
        ),
      ),
    );
  }),
],

              );
      }),
    );
  }
}
