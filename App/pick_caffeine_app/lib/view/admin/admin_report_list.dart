/*
// ----------------------------------------------------------------- //
- title : Report List Page
- Description : 관리자 신고 관리 페이지
- Author : Lee KwonHyoung
- Created Date : 2025.06.05
- Last Modified : 2025.06.12
- package : get: ^4.7.2
// ----------------------------------------------------------------- //

[Changelog]
- 2025.06.05 v1.0.0 : 구현된 페이지 첫 작성
- 2025.06.11 v1.1.0 : 매장 기능 전면 개편
- 2025.06.12 v1.2.0 : 색상 통일 및 리뷰, 리스트, 이미지 문제 해결
// ----------------------------------------------------------------- //
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/model/kwonhyoung/declaration_model.dart';
import 'package:pick_caffeine_app/view/admin/admin_inquiry_list.dart';
import 'dart:convert';
import 'package:pick_caffeine_app/vm/kwonhyoung/kwonhyoung_controller.dart';
import 'package:pick_caffeine_app/widget_class/utility/admin_tabbar.dart';


// 관리자 매장 관리 페이지 (25.06.16. 수정된 버전)
class AdminReportScreen extends StatelessWidget {
  final DeclarationController controller = Get.put(DeclarationController());
  final DateTime adminTodayDate = DateTime.now();
  final box = GetStorage();
  late final String adminId; // 관리자 정보 변수

  AdminReportScreen({super.key}) {
    adminId = box.read('loginId') ?? '__';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyopac,
      body: Column(
        children: [
          _buildTopImageWithText(), // 상단 앱바쪽 이미지
          _buildStoreUserInfo(), // 이미지 밑 매장/회원 수 정보 표시
          _buildTabBar(), // 상단 탭바
          _buildTabBarView(), // 탭바뷰
          BottomTabbar(selectedIndex: 0) // 하단 탭바
        ],
      ),
    );
  }

  // 상단 앱바 이미지
  Widget _buildTopImageWithText() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 150,
          child: Image.asset('images/cafe.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.brown,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported,
                          color: AppColors.white, size: 60),
                      SizedBox(height: 8),
                      Text('이미지를 불러올 수 없습니다',
                          style: TextStyle(color: AppColors.white)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 매장수/회원수 정보 표시
  Widget _buildStoreUserInfo() {
    return Container(
      padding: EdgeInsets.all(15),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Text(
            '매장 수: ${controller.storeCount.value}개',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          )),
          Text(
            '현재날짜: ${adminTodayDate.toString().substring(0, 10)}',
            style: TextStyle(fontSize: 15, color: AppColors.black),
          ),
          Obx(() => Text(
            '회원 수: ${controller.userCount.value}명',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          )),
        ],
      ),
    );
  }

  // 탭바 (매장리스트, 매장 리뷰, 제재 내역)
  Widget _buildTabBar() {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: controller.tabController,
        labelColor: AppColors.brown,
        unselectedLabelColor: AppColors.grey,
        indicatorColor: AppColors.brown,
        indicatorWeight: 3,
        tabs: [
          Tab(child: Text("매장 리스트", style: TextStyle(fontSize: 20))),
          Tab(child: Text("매장 리뷰", style: TextStyle(fontSize: 20))),
          Tab(child: Text("제재 내역", style: TextStyle(fontSize: 20))),
        ],
      ),
    );
  }

  // 탭바 뷰
  Widget _buildTabBarView() {
    return Expanded(
      child: TabBarView(
        controller: controller.tabController,
        children: [
          _buildStoreListTab(),
          _buildReviewListTab(),
          _buildSanctionListTab(),
        ],
      ),
    );
  }

  // 매장리스트 탭 (완전히 수정된 버전)
   // 매장리스트 탭 수정
  Widget _buildStoreListTab() {
    return Obx(() {
      // 초기 로딩과 데이터 로딩을 구분
      final isInitialLoading = controller.isLoading.value && controller.stores.isEmpty;
      final storeList = controller.stores;
      
      if (isInitialLoading) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.brown),
              SizedBox(height: 16),
              Text(
                '매장 목록을 불러오는 중...',
                style: TextStyle(color: AppColors.grey, fontSize: 15),
              ),
            ],
          ),
        );
      }

      if (storeList.isEmpty && !controller.isLoading.value) {
        return _buildEmptyStoreList();
      }

      return RefreshIndicator(
        onRefresh: () async {
          await controller.fetchStores();
        },
        color: AppColors.brown,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: storeList.length,
                itemBuilder: (context, index) {
                  final store = storeList[index];
                  return _buildStoreListItem(store, index);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyStoreList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 80, color: AppColors.grey),
          SizedBox(height: 16),
          Text(
            '등록된 매장이 없습니다.',
            style: TextStyle(fontSize: 16, color: AppColors.grey),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await controller.fetchStores();
            },
            icon: Icon(Icons.refresh),
            label: Text('새로고침'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brown,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // 매장 리스트 아이템 수정 (에러 처리 강화)
  Widget _buildStoreListItem(Map<String, dynamic> store, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.white,
      child: InkWell(
        onTap: () {
          final storeId = store['store_id']?.toString() ?? '';
          if (storeId.isNotEmpty && !storeId.startsWith('error_')) {
            controller.selectStore(storeId);
            controller.tabController.animateTo(1);
          } else {
            Get.snackbar(
              '알림',
              '해당 매장의 정보가 올바르지 않습니다.',
              backgroundColor: AppColors.lightbrown,
              colorText: AppColors.white,
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // 매장 이미지 개선
              GestureDetector(
                onTap: () => _showStoreInfo(store),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.greyopac,
                    border: Border.all(color: AppColors.brown, width: 1),
                  ),
                  child: _buildStoreImageWithErrorHandling(store, index),
                ),
              ),
              SizedBox(width: 16),
              // 매장 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            store['store_name']?.toString() ?? '매장명 없음',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: store['store_id']?.toString().startsWith('error_') == true
                                  ? AppColors.red
                                  : AppColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '사업자번호: ${store['store_business_num']?.toString() ?? '정보 없음'}',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.brown,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      store['store_address']?.toString() ?? '주소 정보 없음',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.brown,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (store['store_phone'] != null && store['store_phone'].toString().isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          '📞 ${store['store_phone']}',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.brown,
                          ),
                        ),
                      ),
                    // 리뷰 수 표시
                    if (store['review_count'] != null)
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          '리뷰 ${store['review_count']}개',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.lightbrown,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // 상태 표시
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStoreStateColor(store['store_state']?.toString()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  store['store_state']?.toString() ?? '연결 안됨',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 매장 상태에 따라 색상 반환
  Color _getStoreStateColor(String? state) {
    switch (state) {
      case '영업중':
        return AppColors.brown;
      case '휴무중':
        return AppColors.red;
      case '준비중':
        return AppColors.lightbrown;
      default:
        return AppColors.grey;
    }
  }

  // 매장 이미지 빌드 메서드 (에러 처리 강화)
  Widget _buildStoreImageWithErrorHandling(Map<String, dynamic> store, int index) {
    try {
      final base64Str = store['store_image_base64'] ?? store['store_image'];
      if (base64Str != null && base64Str.toString().isNotEmpty) {
        try {
          final bytes = base64Decode(base64Str.toString());
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              bytes,
              width: 95,
              height: 95,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultStoreIcon('이미지 오류');
              },
            ),
          );
        } catch (e) {
          return _buildDefaultStoreIcon('디코딩 실패');
        }
      }
      return _buildDefaultStoreIcon('이미지 없음');
    } catch (e) {
      return _buildDefaultStoreIcon('처리 오류');
    }
  }

  // 기본 매장 아이콘 위젯
  Widget _buildDefaultStoreIcon(String reason) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.store, color: AppColors.grey, size: 30),
        SizedBox(height: 4),
        Text(
          reason,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 매장 리뷰 탭 (체크박스 기능 구현 + 개선된 필터링) - 모든 매장 리뷰 버튼 추가
  Widget _buildReviewListTab() {
    return Column(
      children: [
        // 상단 정보
        Container(
          padding: EdgeInsets.all(16),
          color: AppColors.white,
          child: Column(
            children: [
              // 선택된 매장 정보 표시 + 모든 매장 리뷰 버튼
              Row(
                children: [
                  // 선택된 매장 정보 (왼쪽)
                  Expanded(
                    child: Obx(() {
                      if (controller.selectedStoreId.value.isNotEmpty) {
                        final selectedStore = controller.stores.firstWhereOrNull(
                          (store) => store['store_id']?.toString() == controller.selectedStoreId.value,
                        );
                        if (selectedStore != null) {
                          return Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.lightpick,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.lightbrownopac),
                            ),
                            child: Text(
                              '선택된 매장: ${selectedStore['store_name']} (ID: ${selectedStore['store_id']})',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brown,
                              ),
                            ),
                          );
                        }
                      }
                      return Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.greyopac,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.grey),
                        ),
                        child: Text(
                          '매장을 선택하려면 "매장 리스트" 탭에서 매장을 클릭하세요.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                  ),
                  SizedBox(width: 12),
                  // 모든 매장 리뷰 보기 버튼 (오른쪽)
                  ElevatedButton.icon(
                    onPressed: () {
                      // 매장 선택 해제하여 모든 리뷰 표시
                      controller.selectedStoreId.value = '';
                      controller.clearAllReviewSelections();
                      // 전체 리뷰 새로고침
                      controller.fetchReviews();
                    },
                    icon: Icon(
                      Icons.view_list,
                      color: AppColors.white,
                      size: 18,
                    ),
                    label: Text(
                      '모든 매장\n리뷰 보기',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brown,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: Size(80, 50),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // 리뷰 통계
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                    controller.selectedStoreId.value.isEmpty
                        ? '전체 리뷰 수: ${controller.reviews.length}개'
                        : '매장 리뷰 수: ${controller.filteredReviews.length}개',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  )),
                  Obx(() => Text(
                    '선택된 리뷰: ${controller.selectedReviews.length}개',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.red,
                    ),
                  )),
                ],
              ),
            ],
          ),
        ),
        // 리뷰 리스트
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.brown),
                    SizedBox(height: 16),
                    Text(
                      '리뷰를 불러오는 중...',
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            }

            final reviewList = controller.filteredReviews;
            if (reviewList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.rate_review_outlined, size: 80, color: AppColors.grey),
                    SizedBox(height: 16),
                    Text(
                      controller.selectedStoreId.value.isEmpty
                          ? '등록된 리뷰가 없습니다.'
                          : '해당 매장의 리뷰가 없습니다.',
                      style: TextStyle(fontSize: 16, color: AppColors.grey),
                    ),
                    if (controller.selectedStoreId.value.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        '"모든 매장 리뷰 보기" 버튼을 클릭하면\n전체 리뷰를 볼 수 있습니다.',
                        style: TextStyle(fontSize: 14, color: AppColors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await controller.refreshData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brown,
                      ),
                      child: Text('새로고침', style: TextStyle(color: AppColors.white)),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refreshData,
              color: AppColors.brown,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: reviewList.length,
                itemBuilder: (context, index) {
                  final review = reviewList[index];
                  return _buildReviewListItem(review);
                },
              ),
            );
          }),
        ),
        // 하단 제재 버튼
        Container(
          padding: EdgeInsets.all(16),
          color: AppColors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _showSanctionDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '제재하기',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 리뷰 리스트 아이템 (이미지와 체크박스 기능 추가)
  Widget _buildReviewListItem(Map<String, dynamic> review) {
    final reviewNum = review['review_num'] ?? 0;
    return Obx(() {
      final isSelected = controller.selectedReviewNums.contains(reviewNum);
      return Card(
        margin: EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.white,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: AppColors.brown, width: 2) : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 체크박스
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    controller.toggleReviewSelection(reviewNum);
                  },
                  activeColor: AppColors.brown,
                ),
                SizedBox(width: 12),
                // 리뷰 이미지
                GestureDetector(
                  onTap: () => _showImageDialog(review['review_image']),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.greyopac,
                      border: Border.all(color: AppColors.greyopac, width: 1),
                    ),
                    child: (() {
                      final base64Str = review['review_image'];
                      if (base64Str != null && base64Str.toString().isNotEmpty) {
                        try {
                          final bytes = base64Decode(base64Str);
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              bytes,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.broken_image, color: AppColors.grey, size: 20);
                              },
                            ),
                          );
                        } catch (e) {
                          return Icon(Icons.broken_image, color: AppColors.grey, size: 20);
                        }
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, color: AppColors.grey, size: 20),
                          Text(
                            '이미지\n없음',
                            style: TextStyle(
                              fontSize: 8,
                              color: AppColors.grey,
                              height: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }()),
                  ),
                ),
                SizedBox(width: 12),
                // 리뷰 내용
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상단 정보
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${review['user_nickname']?.toString() ?? '익명'} (${review['user_id']?.toString() ?? ''})',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      // 매장 정보
                      Text(
                        '매장: ${review['store_name']?.toString() ?? '알수없는 매장'}',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.brown,
                        ),
                      ),
                      SizedBox(height: 4),
                      // 구매 번호
                      Text(
                        '구매번호: ${review['purchase_num']?.toString() ?? '정보없음'}',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.brown,
                        ),
                      ),
                      SizedBox(height: 8),
                      // 리뷰 내용
                      Text(
                        review['review_content']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      // 작성일
                      Text(
                        '작성일: ${_formatReviewDate(review['review_date'])}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.brown,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // 제재 다이얼로그 (제재 사유 입력 + 1차/2차 제재 선택)
  void _showSanctionDialog() {
    if (controller.selectedReviews.isEmpty) {
      Get.snackbar(
        '알림',
        '제재할 리뷰를 선택해주세요.',
        backgroundColor: AppColors.lightbrown,
        colorText: AppColors.white,
      );
      return;
    }

    final TextEditingController sanctionReasonController = TextEditingController();
    final RxString selectedSanctionLevel = '1차 제재'.obs;
    final List<String> sanctionLevels = ['1차 제재', '2차 제재'];

    Get.dialog(
      AlertDialog(
        title: Text(
          '리뷰 제재',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.brown,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 선택된 리뷰 수 표시
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightpick,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.red),
                  ),
                  child: Text(
                    '선택된 리뷰: ${controller.selectedReviews.length}개',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.red,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // 제재 레벨 선택
                Text(
                  '제재 단계',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Obx(() => DropdownButtonFormField<String>(
                  value: selectedSanctionLevel.value,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: sanctionLevels.map((level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedSanctionLevel.value = value;
                    }
                  },
                )),
                SizedBox(height: 16),
                // 제재 사유 입력
                Text(
                  '제재 사유',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '입력한 제재 사유는 제재 내역에 기록됩니다.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: sanctionReasonController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: '제재 사유를 구체적으로 입력해주세요...\n예: 부적절한 언어 사용, 허위 정보 작성 등',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (sanctionReasonController.text.trim().isEmpty) {
                Get.snackbar(
                  '알림',
                  '제재 사유를 입력해주세요.',
                  backgroundColor: AppColors.lightbrown,
                  colorText: AppColors.white,
                );
                return;
              }

              Get.back(); // 다이얼로그 먼저 닫기

              // 제재 처리
              await controller.sanctionSelectedReviewsWithReason(
                sanctionLevel: selectedSanctionLevel.value,
                sanctionReason: sanctionReasonController.text.trim(),
              );

              // 잠시 대기 후 제재 내역 탭으로 이동
              await Future.delayed(Duration(milliseconds: 500));
              controller.tabController.animateTo(2);

              // 성공 메시지
              Get.snackbar(
                '제재 완료',
                '제재 처리가 완료되었습니다. 제재 내역을 확인하세요.',
                backgroundColor: AppColors.brown,
                colorText: AppColors.white,
                duration: Duration(seconds: 3),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
            ),
            child: Text(
              '제재하기',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 제재 내역 탭
  Widget _buildSanctionListTab() {
    return Column(
      children: [
        // 상단 정보 및 필터
        Container(
          padding: EdgeInsets.all(16),
          color: AppColors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() {
                final filteredCount = controller.filteredSanctionedDeclarations.length;
                final totalCount = controller.declarations
                    .where((d) => d.sanctionContent != null && d.sanctionContent!.isNotEmpty)
                    .length;
                return Text(
                  controller.selectedSanctionType.value == '전체'
                      ? '제재 건수: $totalCount건'
                      : '${controller.selectedSanctionType.value}: $filteredCount건 (전체: $totalCount건)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.red,
                  ),
                );
              }),
              // 필터 드롭다운
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.greyopac),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Obx(() => DropdownButton<String>(
                  value: controller.selectedSanctionType.value,
                  underline: SizedBox(),
                  items: ['전체', '1차 제재', '2차 제재']
                      .map((type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type, style: TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.setSanctionType(value);
                    }
                  },
                )),
              ),
            ],
          ),
        ),
        // 제재 내역 리스트
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.brown),
                    SizedBox(height: 16),
                    Text(
                      '제재 내역을 불러오는 중...',
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            }

            // 필터링된 제재 내역 사용
            final sanctionedDeclarations = controller.filteredSanctionedDeclarations;
            if (sanctionedDeclarations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.policy_outlined, size: 80, color: AppColors.grey),
                    SizedBox(height: 16),
                    Text(
                      controller.selectedSanctionType.value == '전체'
                          ? '제재 내역이 없습니다.'
                          : '${controller.selectedSanctionType.value} 대상자가 없습니다.',
                      style: TextStyle(fontSize: 16, color: AppColors.grey),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await controller.refreshData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brown,
                      ),
                      child: Text('새로고침', style: TextStyle(color: AppColors.white)),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refreshData,
              color: AppColors.brown,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: sanctionedDeclarations.length,
                itemBuilder: (context, index) {
                  final sanction = sanctionedDeclarations[index];
                  return _buildSanctionListItem(sanction);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  // 제재 내역 리스트 아이템 (제재 해제 기능 추가)
  Widget _buildSanctionListItem(Declaration sanction) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.red.withOpacity(0.3), width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 정보 행
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 제재 날짜
                  Text(
                    '제재 날짜: ${sanction.sanctionDate != null ? _formatDate(sanction.sanctionDate!) : "미설정"}',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // 제재 단계 배지
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSanctionTypeColor(sanction.sanctionContent ?? ''),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getSanctionType(sanction.sanctionContent ?? ''),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // 사용자 정보 행
              Row(
                children: [
                  // 사용자 프로필 이미지
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.greyopac,
                    ),
                    child: sanction.userImage != null && sanction.userImage!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              sanction.userImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.person, color: AppColors.grey, size: 20);
                              },
                            ),
                          )
                        : Icon(Icons.person, color: AppColors.grey, size: 20),
                  ),
                  SizedBox(width: 12),
                  // 사용자 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${sanction.userNickname ?? '알수없음'} (${sanction.userId})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          '상태: ${sanction.userState ?? '알수없음'}',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 제재 해제 버튼
                  ElevatedButton(
                    onPressed: () => _showReleaseSanctionDialog(sanction),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brown,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      '해제',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // 제재 내용
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightpick,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '제재 내용:',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      sanction.sanctionContent ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 제재 해제 확인 다이얼로그
  void _showReleaseSanctionDialog(Declaration sanction) {
    Get.dialog(
      AlertDialog(
        title: Text(
          '제재 해제 확인',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.brown,
          ),
        ),
        content: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '다음 사용자의 제재를 해제하시겠습니까?',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.greyopac,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '사용자: ${sanction.userNickname ?? '알수없음'} (${sanction.userId})',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '제재 내용: ${sanction.sanctionContent ?? ''}',
                      style: TextStyle(fontSize: 13, color: AppColors.black),
                    ),
                    Text(
                      '제재 날짜: ${sanction.sanctionDate != null ? _formatDate(sanction.sanctionDate!) : "미설정"}',
                      style: TextStyle(fontSize: 13, color: AppColors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                '제재가 해제되면 해당 사용자는 다시 정상적으로 서비스를 이용할 수 있습니다.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.lightbrown,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // 다이얼로그 닫기
              await controller.releaseSanction(sanction.userId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brown,
            ),
            child: Text(
              '제재 해제',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 하단 네비게이션
  Widget _buildBottomNavigation() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.brown,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Get.to(() => AdminReportScreen());
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store, color: AppColors.white, size: 26),
                  SizedBox(height: 4),
                  Text(
                    '매장 관리',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.white.withOpacity(0.3),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Get.to(() => InquiryReport());
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.question_answer, color: AppColors.white.withOpacity(0.5), size: 26),
                  SizedBox(height: 4),
                  Text(
                    '문의 관리',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.5),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 리뷰 작성일 포맷터
  String _formatReviewDate(dynamic date) {
    if (date == null) return '';
    try {
      if (date is DateTime) {
        return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      }
      // If it's a string, try to parse
      final parsed = DateTime.tryParse(date.toString());
      if (parsed != null) {
        return "${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
      }
      return date.toString();
    } catch (e) {
      return date.toString();
    }
  }

  // 날짜 포맷터 (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // 제재 단계에 따라 색상 반환
  Color _getSanctionTypeColor(String sanctionContent) {
    if (sanctionContent.contains('1차')) {
      return AppColors.lightbrown;
    } else if (sanctionContent.contains('2차')) {
      return AppColors.red;
    } else {
      return AppColors.grey;
    }
  }

  // 제재 단계 텍스트 추출 (예: "1차 제재", "2차 제재" 등)
  String _getSanctionType(String sanctionContent) {
    if (sanctionContent.contains('1차')) {
      return '1차 제재';
    } else if (sanctionContent.contains('2차')) {
      return '2차 제재';
    } else {
      return '기타';
    }
  }

  // =============== 추가 다이얼로그 메서드들 ===============

  // 이미지 확대 다이얼로그
  void _showImageDialog(dynamic imageUrl) {
    if (imageUrl == null || imageUrl.toString().isEmpty) {
      Get.snackbar(
        '알림',
        '표시할 이미지가 없습니다.',
        backgroundColor: AppColors.grey,
        colorText: AppColors.white,
      );
      return;
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Get.back(),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: Get.width * 0.9,
                  maxHeight: Get.height * 0.8,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl.toString(),
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 200,
                        height: 200,
                        color: AppColors.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: AlwaysStoppedAnimation(AppColors.brown),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '이미지 로딩 중...',
                                style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: AppColors.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 50, color: AppColors.grey),
                              SizedBox(height: 16),
                              Text(
                                '이미지를 불러올 수 없습니다.',
                                style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 매장 정보 다이얼로그
 void _showStoreInfo(Map<String, dynamic> store) {
  Get.dialog(
    AlertDialog(
      title: Row(
        children: [
          Icon(Icons.store, color: AppColors.brown),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              store['store_name']?.toString() ?? '매장명 없음',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.brown,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 매장 이미지 (있는 경우)
              if (store['store_image_base64'] != null && store['store_image_base64'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GestureDetector(
                    onTap: () {
                      // 이미지 확대 다이얼로그
                      try {
                        final bytes = base64Decode(store['store_image_base64']);
                        Get.dialog(
                          Dialog(
                            backgroundColor: Colors.transparent,
                            child: GestureDetector(
                              onTap: () => Get.back(),
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    bytes,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.broken_image, size: 80, color: AppColors.grey);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      } catch (_) {}
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        base64Decode(store['store_image_base64']),
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: AppColors.greyopac,
                            child: Center(
                              child: Icon(Icons.store, size: 50, color: AppColors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              if (store['store_image_base64'] == null || store['store_image_base64'].toString().isEmpty)
                if (store['store_image'] != null && store['store_image'].toString().startsWith('http'))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        store['store_image'],
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: AppColors.greyopac,
                            child: Center(
                              child: Icon(Icons.store, size: 50, color: AppColors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              // 이미지가 없을 때
              if ((store['store_image_base64'] == null || store['store_image_base64'].toString().isEmpty) &&
                  (store['store_image'] == null || store['store_image'].toString().isEmpty))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.greyopac,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(Icons.store, size: 50, color: AppColors.grey),
                    ),
                  ),
                ),
              // 매장 정보
              _buildInfoRow('사업자번호', store['store_business_num']?.toString() ?? '정보 없음'),
              _buildInfoRow('주소', store['store_address']?.toString() ?? '주소 정보 없음'),
              _buildInfoRow('전화번호', store['store_phone']?.toString() ?? '전화번호 없음'),
              _buildInfoRow('상태', store['store_state']?.toString() ?? '연결 안됨'),
              // 매장 설명 (있는 경우)
              if (store['store_content'] != null && store['store_content'].toString().isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  '매장 소개',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.greyopac,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    store['store_content'].toString(),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            '닫기',
            style: TextStyle(color: AppColors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            final storeId = store['store_id']?.toString() ?? '';
            controller.selectStore(storeId);
            controller.tabController.animateTo(1);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brown,
          ),
          child: Text(
            '리뷰 보기',
            style: TextStyle(color: AppColors.white),
          ),
        ),
      ],
    ),
  );
}

// 매장 정보 행 위젯
Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    ),
  );
}
}
