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
import 'dart:math';
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
      backgroundColor: AppColors.white,
      body: Obx(() {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildText('나와 가까운 매장'),
                // SizedBox(height: 0),
                _listView(storeHandler.sortedByDistance),
                SizedBox(height: 25),
                _buildText('리뷰가 많은 매장'),
                // SizedBox(height: 5),
                _listView(storeHandler.sortedByReview),
                SizedBox(height: 25),
                _buildText('찜이 많은 매장'),
                // SizedBox(height: 5),
                _listView(storeHandler.sortedByZzim),
                SizedBox(height: 350),
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
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: storeList.length > 6 ? 6 : storeList.length,
        itemBuilder: (context, index) {
          final store = storeList[index];
          final imageBytes =
              store.storeImage!.isNotEmpty ? store.storeImage! : null;
          return GestureDetector(
            onTap: () async {
              await storeHandler.box.write('storeId', store.storeId);
              Get.to(() => CustomerStoreDetail());
            },
            child: Container(
              width: 200,
              margin: EdgeInsets.only(right: 12),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                color: AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Text : store_states
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
                              ? Image.memory(
                                base64Decode(imageBytes),
                                width: 150,
                                height: 150,
                                fit: BoxFit.fill,
                              )
                              : Icon(Icons.image_not_supported, size: 100),
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
                        child:
                            imageBytes != null
                                ? Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.memory(
                                        base64Decode(imageBytes),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    if (store.storeState == 0)
                                      Positioned.fill(
                                        child: Container(
                                          color: AppColors.greyopac,
                                          alignment: Alignment.center,
                                          child: Text(
                                            '준비중 ',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      right: 8,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.favorite,
                                                  size: 18,
                                                  color: AppColors.red,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  '${store.myStoreCount}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.red
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.lightpick,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.chat,
                                                  size: 18,
                                                  color: AppColors.brown,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  '${store.reviewCount}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.brown
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                                : Icon(Icons.image_not_supported, size: 100),
                      ),
                    ),
                    // Text : store_distance - from user
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: Text(
                            store.storeName,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${store.distance.toStringAsFixed(1)} km',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
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
  } // build

  // ------------------------------- Widget -------------------------------------- //
  // 매장 리스트 상단 표시 글자 위젯
  Widget _buildText(String content) {
    return SizedBox(
      // width: 170,
      // height: 40,
      
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children : [ 
        Padding(
          padding: const EdgeInsets.fromLTRB(10,10,0,5),
          child: Text(
            content,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 23,
              color: AppColors.black,
            ),
          ),
        ),
        ]
      ),
    );
  }

  // ------------------------------------------------------------------------------ //
}// class