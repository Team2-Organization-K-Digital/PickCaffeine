import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
import 'package:pick_caffeine_app/widget_class/utility/button_brown.dart';

class CustomerSearch extends StatelessWidget {
  CustomerSearch({super.key});
  final storeHandler = Get.find<JunTemp>();
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.brown.shade200,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.brown.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  color: AppColors.brown,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    cursorColor: AppColors.brown,
                                    controller: searchController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '매장을 검색해보세요',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      ButtonBrown(
                        text: '검색', 
                        onPressed: () {
                          searchController.text.trim().isNotEmpty
                          ? storeHandler.fetchSearchStore(searchController.text.trim())
                          : storeHandler.fetchSearchStore('전체');
                        },
                      )
                    ],

      ),
          body: Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Center(
                child: Column(
                  children: [
                    storeHandler.searchStoreData.isEmpty
                    ? Text('검색어를 입력하고 검색 버튼을 눌러주세요.')
                    : SizedBox(
                      width: 600,
                      height: 800,
                      child: ListView.builder(
                        itemCount: storeHandler.searchStoreData.length,
                        itemBuilder: (context, index) {
                          final store = storeHandler.searchStoreData[index];
                          final imageBytes = store.storeImage.isNotEmpty ? store.storeImage : null;
return Container(
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  height: 180,
  child: Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    color: AppColors.white,
    child: Row(
      children: [
        // 왼쪽 이미지
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          child: imageBytes != null
              ? Stack(
                  children: [
                    Image.memory(
                      base64Decode(imageBytes),
                      width: 120,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                    if (store.storeState == 0)
                      Positioned.fill(
                        child: Container(
                          color: AppColors.greyopac,
                          alignment: Alignment.center,
                          child: const Text(
                            '준비중',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : const SizedBox(
                  width: 120,
                  height: 180,
                  child: Icon(Icons.image_not_supported, size: 50),
                ),
        ),
        // 오른쪽 정보
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 매장 이름
                Text(
                  store.storeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                // 찜/리뷰 수
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite, size: 16, color: AppColors.red),
                          const SizedBox(width: 4),
                          Text(
                            '${store.myStoreCount}',
                            style: const TextStyle(fontSize: 14, color: AppColors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.lightpick,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.chat, size: 16, color: AppColors.brown),
                          const SizedBox(width: 4),
                          Text(
                            '${store.reviewCount}',
                            style: const TextStyle(fontSize: 14, color: AppColors.brown),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // 거리
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${store.distance.toStringAsFixed(1)} m',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
);
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      }
  }
