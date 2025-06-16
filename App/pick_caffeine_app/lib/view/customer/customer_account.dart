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
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/view/customer/customer_update_account.dart';
import 'package:pick_caffeine_app/vm/gamseong/image_vm.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';
import 'package:pick_caffeine_app/widget_class/utility/button_light_brown.dart';

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
      backgroundColor: AppColors.lightpick,
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
                    Container(
  padding: EdgeInsets.all(10),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey, width: 1),
    borderRadius: BorderRadius.circular(10), 
    color: AppColors.grey, 
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("닉네임: ${user['user_nickname']}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("전화번호: ${user['user_phone']}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("이메일: ${user['user_email']}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ],
  ),
),
                          ButtonLightBrown(text: "정보수정",onPressed: () {
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
                      },)
                  ],
                ),
    
            
                SizedBox(height: 20),
            
                // 리뷰 카드
  // 리뷰 카드
Obx(() {
  if (vm.userReviews.isEmpty) {
    return Text("작성한 리뷰가 없습니다.");
  }

  return GridView.count(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(), // 스크롤 중복 방지
    crossAxisCount: 2, // 한 줄에 2개
    childAspectRatio: 0.8, // 카드 세로 비율 조정 (너비:높이)
    padding: EdgeInsets.all(8),
    children: vm.userReviews.map((r) {
      final reviewImg = r['review_image'] ?? '';
      return Card(
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r['store_id'] ?? '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(r['review_date'] ?? ''),
              SizedBox(height: 8),
              Text(r['review_content'] ?? ''),
              SizedBox(height: 10),
              reviewImg != ''
                  ? Image.memory(
                      base64Decode(reviewImg),
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 100,
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported),
                    ),
            ],
          ),
        ),
      );
    }).toList(),
  );
})



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
