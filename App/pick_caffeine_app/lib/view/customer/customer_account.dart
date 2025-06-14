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
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pick_caffeine_app/view/customer/customer_update_account.dart';
import 'package:pick_caffeine_app/vm/gamseong/image_vm.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';

class CustomerAccount extends StatelessWidget {
  CustomerAccount({super.key});

  final vm = Get.find<Vmgamseong>(); // 사용자 정보 ViewModel
  final image = Get.find<ImageModelgamseong>(); // 이미지 처리용 VM
  final box = GetStorage(); // 로컬 저장소 (loginId)

  @override
  Widget build(BuildContext context) {
    final userId = box.read('loginId');
    vm.informationuserid(userId); // 유저 정보 불러오기
    vm.userreviews(); // 리뷰 불러오기

    return Scaffold(
      body: Obx(() {
        final user = vm.user;
        if (user.isEmpty) return Center(child: CircularProgressIndicator());

        final imageBase64 = user['user_image'] ?? '';
        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 이미지
                Center(child: _buildProfileImage(imageBase64)),
                SizedBox(height: 20),
            
                // 텍스트 정보
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("닉네임: ${user['user_nickname']}",
                          style: TextStyle(fontWeight: FontWeight.bold),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("전화번호: ${user['user_phone']}",
                          style: TextStyle(fontWeight: FontWeight.bold),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("이메일: ${user['user_email']}",
                          style: TextStyle(fontWeight: FontWeight.bold),),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        image.clearImage(); // 이미지 초기화
                        Get.to(() => CustomerUpdateAccount(), arguments: [
                          user['user_nickname'],
                          user['user_id'],
                          user['user_password'],
                          user['user_phone'],
                          user['user_email'],
                          user['user_image'],
                        ])?.then((_) {
                          final id = box.read('loginId');
                          vm.informationuserid(userId); 
                        });
                      },
                      child: Text("정보수정"),
                    ),
                  ],
                ),
            
                SizedBox(height: 20),
            
                // 리뷰 카드
                Obx(() {
                  if (vm.review.isEmpty) {
                    return Text("작성한 리뷰가 없습니다.");
                  }
                  final review = vm.review;
                  final reviewImg = review['review_image'] ?? '';
                  return Card(
                    margin: EdgeInsets.all(16),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("스토어 ID: ${review['store_id']}"),
                          Text("내용: ${review['review_content']}"),
                          Text("날짜: ${review['review_date']}"),
                          Text("상태: ${review['review_state']}"),
                          SizedBox(height: 10),
                          reviewImg != ''
                              ? Image.memory(
                                  base64Decode(reviewImg),
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
            ),
          ),
        );
      }),
    );
  }

  // 이미지 위젯 생성 함수
  Widget _buildProfileImage(String? base64String) {
    if (base64String != null && base64String.isNotEmpty) {
      try {
        final bytes = base64Decode(base64String);
        return ClipOval(
          child: Image.memory(
            bytes,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        print("❗ base64 디코딩 오류: $e");
      }
    }

    // 기본 이미지
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: 60),
    );
  }
}
