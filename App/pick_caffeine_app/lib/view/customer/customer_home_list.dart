// 홈 페이지 (고객, list)
/*
// ----------------------------------------------------------------- //
  - title         : List Home Page (Customer)
  - Description   : 고객 회원이 처음 로그인 했을 때 나타나는 페이지로 
  -               : 현재 위치를 기준으로 거리 가까운 순, 리뷰 많은 순, 찜 많은 순 매장 들이 나타난다.
  - Author        : Lee ChangJun
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.11
  - package       : GetX

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.06 v1.0.0  : 매장 들의 list 를 vm 과 model 을 연결하여 화면에 출력

  - 2025.06.09 v1.0.1  : 전반적인 디자인 재구성 및 tabbar, 매장의 영업 상태 추가

  - 2025.06.11 v1.0.2  : 팀원들의 file 을 merge 한 뒤 data 연결 확인 및  전반적인 디자인 개선
// ----------------------------------------------------------------- //
*/
// ----------------------------------------------------------------- //
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/model/changjun/model/stores.dart';
import 'package:pick_caffeine_app/view/customer/customer_store_detail.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
import 'package:pick_caffeine_app/vm/changjun/store_list_handler.dart';
// ----------------------------------------------------------------- //
class CustomerHomeList extends StatelessWidget {
  CustomerHomeList({super.key});
  final searchController = TextEditingController();
  final StoreHandler storeHandler = Get.find<JunTemp>();
// ----------------------------------------------------------------- //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightpick,
      body: Obx(() {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildText('나와 가까운 매장'),
                SizedBox(height: 5),
                _listView(storeHandler.sortedByDistance),
                SizedBox(height: 50),
                _buildText('리뷰가 많은 매장'),
                SizedBox(height: 5),
                _listView(storeHandler.sortedByReview),
                SizedBox(height: 50),
                _buildText('찜이 많은 매장'),
                SizedBox(height: 5),
                _listView(storeHandler.sortedByZzim),
                SizedBox(height: 350)
              ],
            ),
          ),
        );
      }),
    );
  } // build
// --------------------------------- Widget ------------------------------------- //
  Widget _listView(List<Stores> storeList) {
    return SizedBox(
      width: double.infinity,
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: storeList.length > 6 ? 6 : storeList.length,
        itemBuilder: (context, index) {
          final store = storeList[index];
          Uint8List? imageBytes = store.storeImage.isNotEmpty
          ? base64Decode(store.storeImage)
          : null;
          return GestureDetector(
            onTap: () async {
              await storeHandler.box.write('storeId', store.storeId);
              Get.to(()=>CustomerStoreDetail());
            },
            child: Card(
              color: AppColors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
// Text : store_state
                    Text(
                      store.storeState == -1
                      ? "영업 종료"
                      : store.storeState == 0
                      ? "영업 중"
                      : "준비 중",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
// Image : store_image
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: 
                      imageBytes != null
                      ? Image.memory(imageBytes, width: 150, height: 150, fit: BoxFit.fill)
                      :Icon(Icons.image_not_supported, size:100),
                    ),
                    SizedBox(height: 5),
// Text : store_name
                    Text(
                      store.storeName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
// Text : store_mypick & store_review - total count
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '찜 : ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(store.myStoreCount.toString()),
                        SizedBox(width: 20),
                        Text(
                          '리뷰 : ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(store.reviewCount.toString()),
                      ],
                    ),
// Text : store_distance - from user
                    Row(
                      children: [
                        Text(
                          '거리 : ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text('${store.distance} km'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }// build
// ------------------------------- Widget -------------------------------------- //
  // 매장 리스트 상단 표시 글자 위젯
  Widget _buildText(String content) {
    return Container(
      width: 190,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.lightbrown,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          content,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
// ------------------------------------------------------------------------------ //
}// class