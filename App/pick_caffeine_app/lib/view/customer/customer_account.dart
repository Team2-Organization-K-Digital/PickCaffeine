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
import 'package:pick_caffeine_app/widget_class/utility/button_light_brown.dart';

class CustomerAccount extends StatelessWidget {
  final vm = Get.find<Vmgamseong>();
  final image = Get.find<ImageModelgamseong>();
  final box = GetStorage();
  final order = Get.find<Order>();
  final inquiryController = TextEditingController();

  CustomerAccount({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = box.read('loginId');
    vm.informationuserid(userId);
    vm.userreviews();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final user = vm.user;
          if (user.isEmpty) return Center(child: CircularProgressIndicator());

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: user['user_image'] != null && user['user_image'] != ''
                          ? Image.memory(
                              base64Decode(user['user_image']),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.person, size: 80),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoText('닉네임', user['user_nickname']),
                          _infoText('전화번호', user['user_phone']),
                          _infoText('이메일', user['user_email']),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Get.defaultDialog(
                              backgroundColor: AppColors.white,
                              title: '문의작성',
                              content: Column(
                                children: [
                                  TextField(
                                    controller: inquiryController,
                                    decoration: InputDecoration(
                                      labelText: '문의내용',
                                      labelStyle: TextStyle(color: AppColors.brown),
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: AppColors.brown, width: 2),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: AppColors.brown, width: 2),
                                      ),
                                    ),
                                    maxLines: 4,
                                  ),
                                ],
                              ),
                              confirm: ElevatedButton(
                                onPressed: () async {
                                  final inquiry_content = inquiryController.text.trim();
                                  final inquiry_state = '접수';

                                  Get.back();

                                  if (inquiry_content.isEmpty) {
                                    Get.snackbar(
                                      '오류',
                                      '문의 내용을 입력해주세요.',
                                      backgroundColor: AppColors.red,
                                      colorText: AppColors.white,
                                    );
                                    return;
                                  }

                                  try {
                                    await order.saveInquiry(
                                      user_id: userId,
                                      inquiry_content: inquiry_content,
                                      inquiry_state: inquiry_state,
                                    );

                                    Get.snackbar(
                                      '성공',
                                      '문의가 접수되었습니다.☺',
                                      backgroundColor: Colors.white,
                                      borderRadius: 12,
                                      snackPosition: SnackPosition.TOP,
                                    );

                                    inquiryController.clear();
                                  } catch (e) {
                                    Get.snackbar(
                                      '오류',
                                      '문의 접수에 실패했습니다.',
                                      backgroundColor: AppColors.white,
                                      colorText: AppColors.black,
                                      snackPosition: SnackPosition.TOP,
                                      borderRadius: 15,
                                      margin: EdgeInsets.all(16),
                                      icon: Icon(Icons.check_circle, color: AppColors.brown),
                                      shouldIconPulse: false,
                                      duration: Duration(seconds: 3),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text('완료'),
                              ),
                              cancel: ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text('취소'),
                              ),
                            );
                          },
                          child: Text('문의하기', style: TextStyle(fontSize: 14)),
                        ),
                        SizedBox(height: 10),
                        ButtonLightBrown(
                          text: "정보수정",
                          onPressed: () {
                            image.clearImage();
                            Get.to(() => CustomerUpdateAccount(), arguments: [
                              user['user_nickname'],
                              user['user_id'],
                              user['user_password'],
                              user['user_phone'],
                              user['user_email'],
                              user['user_image'],
                            ])?.then((_) => vm.informationuserid(userId));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Divider(color: Colors.brown[100], thickness: 2),
                Text("내 후기 리스트", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                SizedBox(height: 10),
                Obx(() {
                  if (vm.userReviews.isEmpty) return Text("작성한 리뷰가 없습니다.");
                  return Column(
                    children: vm.userReviews.map((r) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipOval(
                                    child: user['user_image'] != null && user['user_image'] != ''
                                        ? Image.memory(
                                            base64Decode(user['user_image']),
                                            width: 32,
                                            height: 32,
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(Icons.person, size: 32),
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user['user_nickname']),
                                      Text(r['review_date'], style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(r['review_content']),
                              SizedBox(height: 10),
                              r['review_image'] != ''
                                  ? Image.memory(base64Decode(r['review_image']))
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value))
        ],
      ),
    );
  }
}