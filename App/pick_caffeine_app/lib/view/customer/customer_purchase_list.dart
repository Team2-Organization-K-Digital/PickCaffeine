// 고객 주문내역 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Purchase List Page (Customer)
  - Description   :
  - Author        : Jeong seoyun
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.05
  - package       :

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  :
// ----------------------------------------------------------------- //
*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/model/seoyun/purchase_model.dart';
import 'package:pick_caffeine_app/view/customer/customer_purchase_detail.dart';
import 'package:pick_caffeine_app/vm/seoyun/vm_handler.dart';
import 'package:pick_caffeine_app/vm/seoyun/vm_image_handler.dart';

class CustomerPurchaseList extends StatelessWidget {
  CustomerPurchaseList({super.key});
  final box = GetStorage();
  final TextEditingController reviewController = TextEditingController();
  final RxMap<int, bool> isReviewVisible = <int, bool>{}.obs; //후기 유무

  @override
  Widget build(BuildContext context) {
    final Order order = Get.find<Order>();

    order.fetchPurchase(box.read('loginId'));
    order.fetchStore(box.read('loginId'));
    order.fetchReview(box.read('loginId'));
    order.fetchMenu(box.read('loginId'));

    // order.fetchPurchase('11');
    // order.fetchStore('11');
    // order.fetchReview('11');
    // order.fetchMenu('11');

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        title: Text('주문내역', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),),
        backgroundColor: AppColors.white,
        ),
      body: Column(
        children: [
          Obx(() {
            return Expanded(
              child:
                  order.index.value < 0
                      ? Center(child: CircularProgressIndicator())
                      : order.purchase.isEmpty
                      ? Text('주문내역이 없습니다.')
                      : ListView.builder(
                        itemCount: order.purchase.length,
                        itemBuilder: (context, index) {
                          final Purchase purchaseList = order.purchase[index];
                          final state = int.parse(purchaseList.purchase_state);
                          final purchaseNum = purchaseList.purchase_num;
                          // 매 카드마다 해당 주문번호에 맞는 매장 정보를 가져옴
                          final storeInfo =
                              order.storeMap
                                  .where((s) => s[2] == purchaseList.store_id)
                                  .toList()
                                  .first;
                          final List menu =
                              order.menu
                                  .where((m) => m[1] == purchaseNum)
                                  .toList();
                          // print(menu);

                          return Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.brown,
                                  width: 2.0,
                                ),
                                color: AppColors.white,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                          20,
                                          10,
                                          10,
                                          0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              purchaseList.purchase_date
                                                  .substring(0, 10),
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Color.fromARGB(
                                                  255,
                                                  73,
                                                  73,
                                                  73,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              storeInfo != null
                                                  ? "${storeInfo[0]} "
                                                  : "매장 정보 불러오는 중...",
                                              style: TextStyle(
                                                fontSize: 23,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              order.menu.isNotEmpty
                                                  ? menu[0][0].toString()
                                                  : '메뉴 정보 없음',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Get.to(
                                                  () =>
                                                      CustomerPurchaseDetail(),
                                                  arguments: [
                                                    purchaseList.purchase_num,
                                                    purchaseList.purchase_date,
                                                    storeInfo[0],
                                                    storeInfo[1],
                                                    purchaseList
                                                        .purchase_request,
                                                    menu[0][3],
                                                  ],
                                                );
                                              },
                                              child: Text(
                                                '주문 상세정보 보기 ▶︎',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: AppColors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              order.menu.isNotEmpty
                                                  ? '${menu[0][3]}원'
                                                  : '메뉴 정보 없음',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                          0,
                                          0,
                                          20,
                                          70,
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 13,
                                                vertical: 7,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    AppColors
                                                        .lightbrownopac, // 배경색
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      15,
                                                    ), // 모서리 둥글게
                                              ),
                                              child: Text(
                                                state == -1
                                                    ? '주문취소'
                                                    : state == 0
                                                    ? '주문확인 중'
                                                    : state == 1
                                                    ? '제조 중'
                                                    : state == 2
                                                    ? '제조완료'
                                                    : '수령완료',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.brown[800],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      order.review.contains(purchaseNum)
                                          ? ElevatedButton(
                                            onPressed: () {
                                              Get.defaultDialog(
                                                title: "알림",
                                                titleStyle: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                backgroundColor: Colors.white,
                                                radius: 20,
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                      18,
                                                      10,
                                                      18,
                                                      0,
                                                    ),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch, // 여기 중요!
                                                  children: [
                                                    Text(
                                                      "리뷰가 이미 작성되었습니다!",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    SizedBox(height: 20),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
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
                                                                vertical: 12,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          "확인",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.lightbrown,
                                              minimumSize: Size(320, 45),
                                            ),
                                            child: Text(
                                              '작성완료',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          )
                                          : ElevatedButton(
                                            onPressed: () {
                                              if (state >= 3) {
                                                isReviewVisible[purchaseNum] =
                                                    true;
                                              } else {
                                                Get.defaultDialog(
                                                  title: "알림",
                                                  titleStyle: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  backgroundColor: Colors.white,
                                                  radius: 20,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                        18,
                                                        10,
                                                        18,
                                                        0,
                                                      ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch, // 여기 중요!
                                                    children: [
                                                      Text(
                                                        "수령완료된 주문 건만 리뷰 작성이 가능합니다!",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      SizedBox(height: 20),
                                                      SizedBox(
                                                        width: double.infinity,
                                                        child: ElevatedButton(
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
                                                                  vertical: 12,
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            "확인",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.brown,
                                              minimumSize: Size(320, 45),
                                            ),
                                            child: Text(
                                              '리뷰 작성하기',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                    ],
                                  ),
                                  Obx(() {
                                    if (isReviewVisible[purchaseNum] == true &&
                                        !order.review.contains(purchaseNum)) {
                                      return buildReviewForm(
                                        context,
                                        purchaseNum,
                                        order,
                                      );
                                    }
                                    return SizedBox.shrink();
                                  }),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            );
          }),
        ],
      ),
    );
  }

  // 후기 입력 폼
  Widget buildReviewForm(BuildContext context, int purchaseNum, Order order) {
    final vm = Get.find<VmImageHandler>();

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  isReviewVisible[purchaseNum] = false;
                },
                child: Icon(
                  Icons.cancel_outlined,
                  size: 25,
                  color: AppColors.brown,
                ),
              ),
            ],
          ),
          buildImagePicker(context),
          SizedBox(height: 10),
          TextField(
            controller: reviewController,
            decoration: InputDecoration(
              labelText: '리뷰 내용',
              labelStyle: TextStyle(color: AppColors.brown),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.brown, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.brown, width: 2),
              ),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final reviewText = reviewController.text.trim();
              final imageFile = vm.imageFile.value;

              if (reviewText.isEmpty) {
                Get.snackbar(
                  '오류',
                  '후기 내용을 입력해주세요.',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              try {
                await order.saveReview(
                  purchaseNum: purchaseNum,
                  reviewText: reviewText,
                  imageFile: imageFile != null ? File(imageFile.path) : null,
                );

                // 🎯 여기서 서버에서 다시 리뷰 불러오기
                await order.fetchReview(box.read('loginId'));
                // await order.fetchReview('11');
                order.index.value++;

                Get.snackbar(
                  // '성공',
                  // '후기가 저장되었습니다.☺',
                  '',
                  '',
                  titleText: Text(
                    '리뷰 작성 완료',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  messageText: Text(
                    '리뷰가 성공적으로 작성되었습니다.',
                    style: TextStyle(color: Colors.black87),
                  ),
                  backgroundColor: Colors.white,
                  borderRadius: 12,
                  snackPosition: SnackPosition.TOP,
                );

                // UI 상태 갱신
                isReviewVisible[purchaseNum] = false;
                reviewController.clear();
              } catch (e) {
                Get.snackbar(
                  '오류',
                  '후기 저장에 실패했습니다.',
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
              backgroundColor: AppColors.lightbrown,
              minimumSize: Size(320, 45),
            ),
            child: Text(
              '작성 완료',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 이미지 선택 위젯
  Widget buildImagePicker(BuildContext context) {
    final vm = Get.find<VmImageHandler>();

    return Obx(
      () => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => vm.getImagefromGallery(ImageSource.gallery),
                style: TextButton.styleFrom(minimumSize: Size(130, 40)),
                child: Row(
                  children: [
                    Icon(Icons.photo, size: 30, color: AppColors.brown),
                    Text(
                      '  갤러리',
                      style: TextStyle(
                        color: AppColors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              TextButton(
                onPressed: () => vm.getImagefromGallery(ImageSource.camera),
                style: TextButton.styleFrom(minimumSize: Size(130, 40)),
                child: Row(
                  children: [
                    Icon(Icons.photo_camera, size: 30, color: AppColors.brown),
                    Text(
                      '  카메라',
                      style: TextStyle(
                        color: AppColors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),

          Container(
            width: double.infinity,
            height: 200,
            color: AppColors.greyopac,
            child:
                vm.imageFile.value == null
                    ? Center(
                      child: Text(
                        '이미지를 선택해 주세요',
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : Image.file(File(vm.imageFile.value!.path)),
          ),
        ],
      ),
    );
  }
}
