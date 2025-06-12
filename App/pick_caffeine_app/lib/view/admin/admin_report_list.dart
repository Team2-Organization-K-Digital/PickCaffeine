// 신고 리스트 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Report List Page
  - Description   : 관리자 신고관리 페이지
  - Author        : Lee KwonHyoung
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.11
  - package       : get: ^4.7.2

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  : 구현된 페이지 첫 작성
  - 2025.06.11 v1.0.1  : 탭바 기능 변경(매장 리스트, 매장 리뷰, 제재 내역), 겟스토리지
// ----------------------------------------------------------------- //
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pick_caffeine_app/model/kwonhyoung/declaration_model.dart';
import 'package:pick_caffeine_app/view/admin/admin_inquiry_list.dart';
import 'package:pick_caffeine_app/vm/kwonhyoung/admin_controller.dart';

// 관리자 매장 관리 페이지 (25.06.11. 수정된 버전2)
class AdminReportScreen extends StatelessWidget {
  AdminReportScreen({super.key});
  final DeclarationController controller = Get.put(DeclarationController());
  final DateTime adminTodayDate = DateTime.now();
  final box = GetStorage();

  late final String adminId; // 관리자 정보 변수

  AdminReportScree({Key? key}) {
    adminId = box.read('loginId') ?? '__';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildTopImageWithText(), // 상단 앱바쪽 이미지
          _buildStoreUserInfo(), // 이미지 밑 매장/회원 수 정보 표시
          _buildTabBar(), // 상단 탭바
          _buildTabBarView(), // 탭바뷰
          _buildBottomNavigation(), // 하단 탭바
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
          ),
        ),
      ],
    );
  }

  // 매장수/회원수 정보 표시 
  Widget _buildStoreUserInfo() {
    return Container(
      padding: EdgeInsets.all(15),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Text(
            '매장 수: ${controller.storeCount.value}개',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          )),
          Text(
            '현재날짜: ${adminTodayDate.toString().substring(0, 10)}',
            style: TextStyle(fontSize: 15),
            ),
          Obx(() => Text(
            '회원 수: ${controller.userCount.value}명',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          )),
        ],
      ),
    );
  }

  // 탭바 (매장리스트, 매장 리뷰, 제재 내역)
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller.tabController,
        labelColor: Color(0xFF8B4513),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Color(0xFF8B4513),
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

  // 매장리스트 탭
  Widget _buildStoreListTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: Color(0xFF8B4513)),
        );
      }

      final storeList = controller.stores;

      if (storeList.isEmpty) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_outlined, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  '등록된 매장이 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await controller.refreshData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B4513),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('새로고침', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshData,
        color: Color(0xFF8B4513),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: storeList.length,
          itemBuilder: (context, index) {
            final store = storeList[index];
            return _buildStoreListItem(store);
          },
        ),
      );
    });
  }

  // 매장 리스트 아이템 (클릭 기능 추가)
  Widget _buildStoreListItem(Map<String, dynamic> store) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // 매장 선택하고 해당 매장의 리뷰 필터링
          controller.selectedStoreId.value = store['store_id']?.toString() ?? '';
          controller.selectedReviewNums.clear(); // 선택된 리뷰 초기화
          // 매장 리뷰 탭으로 이동
          controller.tabController.animateTo(1);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // 매장 이미지 (개선된 버전)
              GestureDetector(
                onTap: () => _showStoreInfo(store),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[300],
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: store['store_image'] != null && store['store_image'].toString().isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            store['store_image'],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.store, color: Colors.grey[600], size: 30);
                            },
                          ),
                        )
                      : Icon(Icons.store, color: Colors.grey[600], size: 30),
                ),
              ),
              SizedBox(width: 16),
              
              // 매장 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store['store_name']?.toString() ?? '매장명 없음',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '사업자번호: ${store['store_business_num']?.toString() ?? '정보 없음'}',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      store['store_address']?.toString() ?? '주소 정보 없음',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (store['store_phone'] != null)
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          '📞 ${store['store_phone']}',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[500],
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
                  color: _getStoreStatusColor(store['store_state']?.toString()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  store['store_state']?.toString() ?? '연결 안됨',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
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

  // 매장 리뷰 탭 (체크박스 기능 구현)
  Widget _buildReviewListTab() {
    return Column(
      children: [
        // 상단 정보
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              // 선택된 매장 정보 표시
              Obx(() {
                if (controller.selectedStoreId.value.isNotEmpty) {
                  final selectedStore = controller.stores.firstWhereOrNull(
                    (store) => store['store_id'] == controller.selectedStoreId.value,
                  );
                  if (selectedStore != null) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFF8B4513).withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFF8B4513).withAlpha(20)),
                      ),
                      child: Text(
                        '선택된 매장: ${selectedStore['store_name']}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B4513),
                        ),
                      ),
                    );
                  }
                }
                return Container();
              }),
              
              // 리뷰 통계
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                    '리뷰 수: ${controller.filteredReviews.length}개',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                  Obx(() => Text(
                    '선택된 리뷰: ${controller.selectedReviews.length}개',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
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
                child: CircularProgressIndicator(color: Color(0xFF8B4513)),
              );
            }

            final reviewList = controller.filteredReviews;

            if (reviewList.isEmpty) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        controller.selectedStoreId.value.isEmpty 
                          ? '매장을 선택해주세요.' 
                          : '해당 매장의 리뷰가 없습니다.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refreshData,
              color: Color(0xFF8B4513),
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
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _showSanctionDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '제재하기',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: Color(0xFF8B4513), width: 2) : null,
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
                  activeColor: Color(0xFF8B4513),
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
                      color: Colors.grey[300],
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: review['review_image'] != null && review['review_image'].toString().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                Image.network(
                                  review['review_image'],
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / 
                                                  loadingProgress.expectedTotalBytes!
                                                : null,
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Icon(Icons.broken_image, color: Colors.grey[500], size: 20),
                                    );
                                  },
                                ),
                                // 확대 표시 아이콘
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(20),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.zoom_in,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, color: Colors.grey[500], size: 20),
                              Text(
                                '이미지\n없음',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.grey[500],
                                  height: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
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
                          Text(
                            '${review['user_nickname']?.toString() ?? '익명'} (${review['user_id']?.toString() ?? ''})',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Container(
                          //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          //   decoration: BoxDecoration(
                          //     color: _getReviewStateColor(review['review_state']?.toString()),
                          //     borderRadius: BorderRadius.circular(10),
                          //   ),
                          //   child: Text(
                          //     review['review_state']?.toString() ?? '상태없음',
                          //     style: TextStyle(
                          //       fontSize: 15,
                          //       color: Colors.white,
                          //       fontWeight: FontWeight.w500,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(height: 4),
                      
                      // 매장 정보
                      Text(
                        '매장: ${review['store_name']?.toString() ?? '알수없는 매장'}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      
                      // 구매 번호
                      Text(
                        '구매번호: ${review['purchase_num']?.toString() ?? '정보없음'}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(height: 8),
                      
                      // 리뷰 내용
                      Text(
                        review['review_content']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[800],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      
                      // 작성일
                      Text(
                        '작성일: ${_formatReviewDate(review['review_date'])}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[500],
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
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        
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
            color: Color(0xFF8B4513),
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
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    '선택된 리뷰: ${controller.selectedReviews.length}개',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
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
                    return DropdownMenuItem(
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
                    color: Colors.grey[600],
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
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (sanctionReasonController.text.trim().isEmpty) {
                Get.snackbar(
                  '알림',
                  '제재 사유를 입력해주세요.',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
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
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: Duration(seconds: 3),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
            ),
            child: Text(
              '제재하기',
              style: TextStyle(color: Colors.white),
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
          color: Colors.white,
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
                    color: Colors.red[700],
                  ),
                );
              }),
              
              // 필터 드롭다운
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Obx(() => DropdownButton<String>(
                  value: controller.selectedSanctionType.value,
                  underline: SizedBox(),
                  items: ['전체', '1차 제재', '2차 제재']
                      .map((type) => DropdownMenuItem(
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
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF8B4513)),
                      SizedBox(height: 16),
                      Text(
                        '제재 내역을 불러오는 중...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
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
                    Icon(Icons.policy_outlined, size: 80, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      controller.selectedSanctionType.value == '전체' 
                        ? '제재 내역이 없습니다.'
                        : '${controller.selectedSanctionType.value} 대상자가 없습니다.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await controller.refreshData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B4513),
                      ),
                      child: Text('새로고침', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refreshData,
              color: Color(0xFF8B4513),
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[200]!, width: 1),
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
                      color: Colors.grey[600],
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
                        color: Colors.white,
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
                      color: Colors.grey[300],
                    ),
                    child: sanction.userImage != null && sanction.userImage!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              sanction.userImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.person, color: Colors.grey[600], size: 20);
                              },
                            ),
                          )
                        : Icon(Icons.person, color: Colors.grey[600], size: 20),
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
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '상태: ${sanction.userState ?? '알수없음'}',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 제재 해제 버튼
                  ElevatedButton(
                    onPressed: () => _showReleaseSanctionDialog(sanction),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      '해제',
                      style: TextStyle(
                        color: Colors.white,
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
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '제재 내용:',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      sanction.sanctionContent ?? '',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.red[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // // 제재 사유 표시 (declarationContent)
              // if (sanction.declarationContent.isNotEmpty) ...[
              //   SizedBox(height: 8),
              //   Container(
              //     width: double.infinity,
              //     padding: EdgeInsets.all(8),
              //     decoration: BoxDecoration(
              //       color: Colors.orange[50],
              //       borderRadius: BorderRadius.circular(6),
              //       border: Border.all(color: Colors.orange[200]!),
              //     ),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           '제재 사유:',
              //           style: TextStyle(
              //             fontSize: 11,
              //             color: Colors.orange[700],
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //         SizedBox(height: 2),
              //         Text(
              //           sanction.declarationContent,
              //           style: TextStyle(
              //             fontSize: 13,
              //             color: Colors.orange[800],
              //             fontWeight: FontWeight.w500,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ],
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
            color: Color(0xFF8B4513),
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
                  color: Colors.grey[100],
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
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                    Text(
                      '제재 날짜: ${sanction.sanctionDate != null ? _formatDate(sanction.sanctionDate!) : "미설정"}',
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                '제재가 해제되면 해당 사용자는 다시 정상적으로 서비스를 이용할 수 있습니다.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange[700],
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
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // 다이얼로그 닫기
              await controller.releaseSanction(sanction.userId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
            ),
            child: Text(
              '제재 해제',
              style: TextStyle(color: Colors.white),
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
        color: Color(0xFF8B4513),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
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
               Get.to(()=> AdminReportScreen() );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store, color: Colors.white, size: 26),
                  SizedBox(height: 4),
                  Text(
                    '매장 관리',
                    style: TextStyle(
                      color: Colors.white,
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
            color: Colors.white.withAlpha(25),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Get.to(()=>InquiryReport());
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.question_answer, color: Colors.white.withAlpha(25), size: 26),
                  SizedBox(height: 4),
                  Text(
                    '문의 관리',
                    style: TextStyle(
                      color: Colors.white.withAlpha(25),
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

  // =============== 추가 다이얼로그 메서드들 ===============

  // 이미지 확대 다이얼로그
  void _showImageDialog(dynamic imageUrl) {
    if (imageUrl == null || imageUrl.toString().isEmpty) {
      Get.snackbar(
        '알림',
        '표시할 이미지가 없습니다.',
        backgroundColor: Colors.grey[600],
        colorText: Colors.white,
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
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / 
                                      loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '이미지 로딩 중...',
                                style: TextStyle(
                                  color: Colors.grey[600],
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
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
                              SizedBox(height: 16),
                              Text(
                                '이미지를 불러올 수 없습니다.',
                                style: TextStyle(
                                  color: Colors.grey[600],
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
            Icon(Icons.store, color: Color(0xFF8B4513)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                store['store_name']?.toString() ?? '매장명 없음',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B4513),
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 매장 이미지 (있는 경우)
              if (store['store_image'] != null && store['store_image'].toString().isNotEmpty) ...[
                GestureDetector(
                  onTap: () => _showImageDialog(store['store_image']),
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        store['store_image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(Icons.store, size: 50, color: Colors.grey[400]),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
              
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
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    store['store_content'].toString(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.amber[700],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              '닫기',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // 다이얼로그 닫기
              // 매장 선택하고 리뷰 탭으로 이동
              controller.selectedStoreId.value = store['store_id']?.toString() ?? '';
              controller.selectedReviewNums.clear(); // 선택된 리뷰 초기화
              controller.tabController.animateTo(1);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B4513),
            ),
            child: Text(
              '리뷰 보기',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 정보 행 위젯 (매장 정보용)
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
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 매장 상태별 색상
  Color _getStoreStatusColor(String? status) {
    switch (status) {
      case '운영중':
        return Colors.green;
      case '휴업':
        return Colors.orange;
      case '폐업':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 리뷰 상태별 색상
  Color _getReviewStateColor(String? state) {
    switch (state) {
      case '정상':
      case '승인':
        return Colors.green;
      case '대기':
      case '검토중':
        return Colors.orange;
      case '삭제':
      case '제재':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 제재 유형 추출
  String _getSanctionType(String sanctionContent) {
    if (sanctionContent.contains('1차')) return '1차 제재';
    if (sanctionContent.contains('2차')) return '2차 제재';
    return '1차 제재';
  }

  // 제재 유형별 색상
  Color _getSanctionTypeColor(String sanctionContent) {
    if (sanctionContent.contains('1차')) return Colors.orange;
    if (sanctionContent.contains('2차')) return Colors.red;
    return Colors.orange;
  }

  // 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 리뷰 날짜 포맷팅
  String _formatReviewDate(dynamic dateValue) {
    if (dateValue == null) return '';
    try {
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return dateValue.toString();
      }
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateValue.toString();
    }
  }
}
