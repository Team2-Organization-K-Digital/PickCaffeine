// 신고 리스트 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Report List Page
  - Description   : 관리자 신고관리 페이지
                    (피그마상 3페이지인데 탭바 이동이라 여기에
                    신고 관련 페이지를 모두 작성함)
  - Author        : Lee KwonHyoung
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.05
  - package       : get: ^4.7.2

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  : 구현된 페이지 첫 작성
// ----------------------------------------------------------------- //
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/admin_model.dart';

import 'package:pick_caffeine_app/kwonhyoung_controller.dart';
import 'package:pick_caffeine_app/view/admin/admin_inquiry_list.dart';

// 관리자 첫페이지(유저 신고관리)
class AdminReportScreen extends StatelessWidget {
  AdminReportScreen({super.key});
  final DeclarationController controller = Get.put(DeclarationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildTopImageWithText(),
          _buildUserStoreInfo(), // 유저수/매장수 정보 고정 표시
          _buildTabBar(),
          _buildTabBarView(),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  // 최상단 이미지(이미지 에셋으로 작성)
  Widget _buildTopImageWithText() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 150,
          child: Image.asset('images/cafe.png', fit: BoxFit.cover),
        ),
      ],
    );
  }

  // 유저수/매장수 정보 (고정)
  Widget _buildUserStoreInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Text(
              '유저 수: ${controller.userCount.value}명',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Obx(
            () => Text(
              '매장 수: ${controller.storeCount.value}개',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // 탭바 (순서 변경: 제재 등록 -> 신고접수 관리 -> 제재 유저 목록)
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller.tabController,
        labelColor: Color(0xFF8B4513),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Color(0xFF8B4513),
        indicatorWeight: 3,
        tabs: [Tab(text: "제재 등록"), Tab(text: "신고접수 관리"), Tab(text: "제재 유저 목록")],
      ),
    );
  }

  // 탭바 뷰 (순서 변경)
  Widget _buildTabBarView() {
    return Expanded(
      child: TabBarView(
        controller: controller.tabController,
        children: [
          _buildSanctionRegistrationTab(), // 제재 등록
          _buildReportManagementTab(), // 신고접수 관리
          _buildSanctionedUsersTab(), // 제재 유저 목록
        ],
      ),
    );
  }

  // 제재 등록 탭
  Widget _buildSanctionRegistrationTab() {
    return Obx(() {
      if (controller.selectedDeclaration.value == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                '제재 처리할 신고를 선택해주세요',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.tabController.index = 1,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8B4513),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '신고 목록으로 이동',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }

      final declaration = controller.selectedDeclaration.value!;

      return SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 신고 정보 카드
            _buildSanctionInfoCard(declaration),
            SizedBox(height: 20),

            // 제재 옵션 선택
            _buildSanctionOptionsCard(),
            SizedBox(height: 20),

            // 제재 등록 버튼
            _buildSanctionActionButtons(),
          ],
        ),
      );
    });
  }

  // 신고 정보 카드
  Widget _buildSanctionInfoCard(Declaration declaration) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '신고접수내역',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B4513),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: controller.getStatusColor(
                      declaration.declarationState,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    declaration.declarationState,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // 날짜 정보
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Date: ${_formatDate(declaration.declarationDate)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 12),

            // 신고 내용
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '신고 접수 내용',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    declaration.declarationContent,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 제재 옵션 카드
  Widget _buildSanctionOptionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '제재내역',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
              ),
            ),
            SizedBox(height: 20),

            // 제재 구분 드롭다운
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dropdown',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Obx(
                    () => DropdownButton<String>(
                      value: controller.selectedSanctionType.value,
                      isExpanded: true,
                      underline: SizedBox(),
                      items:
                          ['1차 제재', '2차 제재']
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.setSanctionType(value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // 제재 기간 드롭다운
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Obx(
                () => DropdownButton<String>(
                  value: controller.selectedSanctionPeriod.value,
                  isExpanded: true,
                  underline: SizedBox(),
                  items:
                      ['1일', '3일', '7일', '30일', '영구정지']
                          .map(
                            (period) => DropdownMenuItem(
                              value: period,
                              child: Text(period),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.setSanctionPeriod(value);
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20),

            // 제재 적용일
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.pink[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '제재 적용일: ${_formatDate(DateTime.now())}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),
                  Obx(
                    () => Text(
                      '선택된 제재: ${controller.generateSanctionContent()}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 제재 액션 버튼
  Widget _buildSanctionActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            controller.selectedDeclaration.value = null;
            controller.tabController.index = 1;
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600],
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            '취소',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            final declaration = controller.selectedDeclaration.value!;
            controller.updateDeclaration(
              reviewNum: declaration.reviewNum,
              userId: declaration.userId,
              declarationDate:
                  declaration.declarationDate.toIso8601String().split('T')[0],
              declarationContent: declaration.declarationContent,
              declarationState: '처리완료',
              sanctionContent: controller.generateSanctionContent(),
              sanctionDate: DateTime.now().toIso8601String().split('T')[0],
            );
            controller.selectedDeclaration.value = null;
            controller.tabController.index = 2;
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            '제재 등록',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // 신고접수 관리 탭 (유저수/매장수 정보 제거)
  Widget _buildReportManagementTab() {
    return Column(
      children: [
        // 신고 리스트
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(color: Color(0xFF8B4513)),
              );
            }

            final pendingDeclarations =
                controller.declarations
                    .where((d) => d.sanctionContent == null)
                    .toList();

            if (pendingDeclarations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: Colors.green[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      '처리 대기중인 신고가 없습니다.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
                itemCount: pendingDeclarations.length,
                itemBuilder: (context, index) {
                  final declaration = pendingDeclarations[index];
                  return _buildReportListItem(declaration);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  // 신고 리스트 아이템
  Widget _buildReportListItem(Declaration declaration) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          controller.selectedDeclaration.value = declaration;
          controller.tabController.index = 0;
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            declaration.userId,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'ID: ${declaration.userId}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: controller.getStatusColor(
                        declaration.declarationState,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      declaration.declarationState,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Date: ${_formatDate(declaration.declarationDate)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(width: 16),
                  Icon(
                    Icons.report_outlined,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4),
                  Text(
                    '리뷰번호: ${declaration.reviewNum}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                declaration.declarationContent,
                style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.selectedDeclaration.value = declaration;
                      controller.tabController.index = 0;
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFF8B4513).withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      '제재내역',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B4513),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 제재 유저 목록 탭
  Widget _buildSanctionedUsersTab() {
    return Column(
      children: [
        // 상단 정보 바
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  '제재 유저 수: ${controller.sanctionedUserCount.value}명',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                ),
              ),
              IconButton(
                onPressed: controller.refreshData,
                icon: Icon(Icons.refresh, color: Color(0xFF8B4513)),
              ),
            ],
          ),
        ),

        // 제재 유저 리스트
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(color: Color(0xFF8B4513)),
              );
            }

            // 제재된 유저들 (sanctionContent가 있는 경우)
            final sanctionedDeclarations =
                controller.declarations
                    .where(
                      (d) =>
                          d.sanctionContent != null &&
                          d.sanctionContent!.isNotEmpty,
                    )
                    .toList();

            if (sanctionedDeclarations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      '제재중인 유저가 없습니다.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
                  return _buildSanctionedUserItem(sanction);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  // 제재 유저 리스트 아이템
  Widget _buildSanctionedUserItem(Declaration sanction) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red[100],
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sanction.userId,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'ID: ${sanction.userId}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '제재중',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // 제재 정보
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '제재 내용:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '제재일: ${sanction.sanctionDate != null ? _formatDate(sanction.sanctionDate!) : ""}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      sanction.sanctionContent ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '신고 사유: ${sanction.declarationContent}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),

              // 액션 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showReleaseSanctionDialog(sanction),
                    icon: Icon(
                      Icons.lock_open,
                      size: 16,
                      color: Colors.green[700],
                    ),
                    label: Text(
                      '제재 해제',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 제재 해제 다이얼로그
  void _showReleaseSanctionDialog(Declaration sanction) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.lock_open, color: Colors.green[700]),
            SizedBox(width: 8),
            Text('제재 해제'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('다음 사용자의 제재를 해제하시겠습니까?', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
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
                    '사용자: ${sanction.userId}',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('ID: ${sanction.userId}'),
                  SizedBox(height: 8),
                  Text(
                    '제재 내용: ${sanction.sanctionContent}',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('취소', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await controller.releaseSanction(sanction.userId);

                // 로컬 데이터에서도 해당 Declaration의 sanctionContent를 null로 설정
                final index = controller.declarations.indexWhere(
                  (d) =>
                      d.userId == sanction.userId &&
                      d.reviewNum == sanction.reviewNum,
                );

                if (index != -1) {
                  // 기존 Declaration 객체를 복사하여 sanctionContent를 null로 설정
                  final updatedDeclaration = Declaration(
                    reviewNum: controller.declarations[index].reviewNum,
                    userId: controller.declarations[index].userId,
                    declarationDate:
                        controller.declarations[index].declarationDate,
                    declarationContent:
                        controller.declarations[index].declarationContent,
                    declarationState: '처리완료', // 상태는 처리완료로 유지
                    sanctionContent: null, // 제재 내용을 null로 설정
                    sanctionDate: controller.declarations[index].sanctionDate,
                  );

                  // 리스트에서 해당 항목 업데이트
                  controller.declarations[index] = updatedDeclaration;
                }

                // 성공 메시지
                Get.snackbar(
                  '완료',
                  '제재가 해제되었습니다.',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: Duration(seconds: 2),
                );

                Get.back();
              } catch (e) {
                // 에러 발생 시에도 다이얼로그 닫기
                Get.back();

                // 에러 메시지 표시
                Get.snackbar(
                  '오류',
                  '제재 해제 중 오류가 발생했습니다: ${e.toString()}',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: Duration(seconds: 3),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('제재 해제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
                // 현재 페이지
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber, color: Colors.white, size: 26),
                  SizedBox(height: 4),
                  Text(
                    '신고 관리',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white.withAlpha(25)),
          Expanded(
            child: InkWell(
              onTap: () {
                // 문의 관리 페이지로 이동
                Get.to(() => InquiryReport());
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.question_answer,
                    color: Colors.white.withAlpha(25),
                    size: 26,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '문의 관리',
                    style: TextStyle(
                      color: Colors.white.withAlpha(25),
                      fontSize: 12,
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
}
