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
import 'package:pick_caffeine_app/vm/seoyun/vm_handler.dart';

class CustomerAccount extends StatelessWidget {
  CustomerAccount({super.key});

  final vm = Get.find<Vmgamseong>(); // 사용자 정보 ViewModel
  final image = Get.find<Vmgamseong>(); // 이미지 처리용 VM
  final box = GetStorage(); // 로컬 저장소 (loginId)
  final order = Get.find<Order>();
  final TextEditingController inquiryController = TextEditingController();

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
                          child: Text(
                            "닉네임: ${user['user_nickname']}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "전화번호: ${user['user_phone']}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "이메일: ${user['user_email']}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            image.clearImage(); // 이미지 초기화
                            Get.to(
                              () => CustomerUpdateAccount(),
                              arguments: [
                                user['user_nickname'],
                                user['user_id'],
                                user['user_password'],
                                user['user_phone'],
                                user['user_email'],
                                user['user_image'],
                              ],
                            )?.then((_) {
                              final id = box.read('loginId');
                              vm.informationuserid(userId);
                            });
                          },
                          child: Text("정보수정"),
                        ),
                //////////////////////// 문의 작성하기 /////////////////////////////
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                right: 20,
                                              ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  fixedSize: Size(100, 30),
                                                ),
                                                onPressed: () {
                                                  Get.defaultDialog(
                                                    backgroundColor:
                                                        AppColors.white,
                                                    title: '문의작성',
                                                    content: Column(
                                                      children: [
                                                        TextField(
                                                          controller:
                                                              inquiryController,
                                                          decoration: InputDecoration(
                                                            labelText: '문의내용',
                                                            labelStyle:
                                                                TextStyle(
                                                                  color:
                                                                      AppColors
                                                                          .brown,
                                                                ),
                                                            border:
                                                                OutlineInputBorder(),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                    color:
                                                                        AppColors
                                                                            .brown,
                                                                    width: 2,
                                                                  ),
                                                                ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                    color:
                                                                        AppColors
                                                                            .brown,
                                                                    width: 2,
                                                                  ),
                                                                ),
                                                          ),
                                                          maxLines: 4,
                                                        ),
                                                      ],
                                                    ),
                                                    confirm: ElevatedButton(
                                                      onPressed: () async {
                                                        final inquiry_content =
                                                            inquiryController
                                                                .text
                                                                .trim();
                                                        final inquiry_state =
                                                            '접수';

                                                            Get.back();

                                                        if (inquiry_content
                                                            .isEmpty) {
                                                          Get.snackbar(
                                                            '오류',
                                                            '문의 내용을 입력해주세요.',
                                                            backgroundColor: AppColors.red,
                                                            colorText: AppColors.white
                                                          );
                                                          return;
                                                        }

                                                        try {
                                                          await order.saveInquiry(
                                                            user_id: userId,
                                                            inquiry_content:
                                                                inquiry_content,
                                                            inquiry_state:
                                                                inquiry_state,
                                                          );

                                                          Get.snackbar(
                                                            '성공',
                                                            '문의가 접수되었습니다.☺',
                                                            backgroundColor:
                                                                Colors.white,
                                                            borderRadius: 12,
                                                            snackPosition:
                                                                SnackPosition
                                                                    .TOP,
                                                          );
                                                          

                                                          // UI 상태 갱신
                                                          inquiryController
                                                              .clear();
                                                              
                                                        } catch (e) {
                                                          Get.snackbar(
                                                            '오류',
                                                            '문의 접수에 실패했습니다.',
                                                            backgroundColor:
                                                                AppColors.white,
                                                            colorText:
                                                                AppColors.black,
                                                            snackPosition:
                                                                SnackPosition
                                                                    .TOP,
                                                            borderRadius: 15,
                                                            margin:
                                                                EdgeInsets.all(
                                                                  16,
                                                                ),
                                                            icon: Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color:
                                                                  AppColors
                                                                      .brown,
                                                            ),
                                                            shouldIconPulse:
                                                                false,
                                                            duration: Duration(
                                                              seconds: 3,
                                                            ),
                                                          );
                                                        }
                                                      
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.brown,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 10,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Text('완료'),
                                                    ),

                                                    cancel: ElevatedButton(
                                                      onPressed: () {
                                                        Get.back();
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.brown,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 10,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Text('취소'),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  '문의하기',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                  ]
                ),
////////////////////////////////////////////////////////////////문의하기
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
