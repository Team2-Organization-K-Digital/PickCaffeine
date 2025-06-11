// 문의 리스트 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Inquiry List Page
  - Description   : 관리자 문의내역 페이지(탭바 사용으로 한 곳에 코드 구현)
  - Author        : Lee KwonHyoung
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.11
  - package       : get: ^4.7.2, flutter_slidable: ^4.0.0

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.1  : 관리자 문의내역 첫 작성
// ----------------------------------------------------------------- //
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pick_caffeine_app/widget_class/utility/admin_tabbar.dart'; 


import 'package:pick_caffeine_app/vm/kwonhyoung/kwonhyoung_controller.dart'; 

// 관리자 문의내역역 페이지 (25.06.10. 수정된 버전)
class InquiryReport extends StatelessWidget {
  InquiryReport({super.key});

  final InquiryController controller = Get.find<InquiryController>();

  // 현재 탭 상태를 나타내는 Rx 변수 (0: 문의내역, 1: 답변내역)
  final RxInt tabIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildTopImageWithText(),     // 상단 이미지 + 제목 텍스트
          _buildTabBar(),               // 탭 버튼 (문의내역 / 답변내역)
          Expanded(                     // 실제 콘텐츠 영역
            child: Obx(() =>
              tabIndex.value == 0
                ? _buildInquiryList()   // 문의내역 탭일 때
                : _buildAnswerList()    // 답변내역 탭일 때
            ),
          ),
          BottomTabbar(selectedIndex: 1), // 하단 네비게이션 탭바 (문의 관리 강조)
        ],
      ),
    );
  }

  // 상단 이미지 + 제목 텍스트
  Widget _buildTopImageWithText() {
    return Column(
      children: [
        Image.asset(
          'images/cafe.png',
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 300,
              color: Color(0xFF8B4513),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, 
                         color: Colors.white, size: 60),
                    SizedBox(height: 8),
                    Text('이미지를 불러올 수 없습니다',
                         style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            );
          },
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Obx(() => Text(
            tabIndex.value == 0 ? '문의내역' : '답변내역',
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF8B4513)
            ),
          )),
        )
      ],
    );
  }

  // 탭 버튼 영역 (문의내역 / 답변내역)
  Widget _buildTabBar() {
    return Obx(() => Row(
      children: [
        // 문의내역 탭 버튼
        Expanded(
          child: TextButton(
            onPressed: () => tabIndex.value = 0,
            style: TextButton.styleFrom(
              backgroundColor: tabIndex.value == 0 ? Color(0xFF8B4513) : Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              '문의내역',
              style: TextStyle(
                color: tabIndex.value == 0 ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        // 답변내역 탭 버튼
        Expanded(
          child: TextButton(
            onPressed: () => tabIndex.value = 1,
            style: TextButton.styleFrom(
              backgroundColor: tabIndex.value == 1 ? Color(0xFF8B4513) : Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              '답변내역',
              style: TextStyle(
                color: tabIndex.value == 1 ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    ));
  }

  // 문의 내역 리스트 렌더링 (답변 처리 + 반려 처리 포함)
  Widget _buildInquiryList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
              ),
              SizedBox(height: 16),
              Text(
                '문의 목록을 불러오는 중...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }

      // 에러 메시지 표시
      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red),
              SizedBox(height: 16),
              Text(
                '오류가 발생했습니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.fetchInquiries(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8B4513),
                ),
                child: Text('다시 시도', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }

      // 미답변 문의만 필터링 (답변이 없는 것들)
      final unansweredInquiries = controller.inquiryList
          .where((inquiry) => inquiry.response == null || inquiry.response!.isEmpty)
          .toList();

      if (unansweredInquiries.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                '새로운 문의가 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              Text(
                '모든 문의에 답변이 완료되었습니다.',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.fetchInquiries(),
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
        onRefresh: () async => controller.fetchInquiries(),
        color: Color(0xFF8B4513),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: unansweredInquiries.length,
          itemBuilder: (context, index) {
            final inquiry = unansweredInquiries[index];

            return Slidable(
              key: ValueKey(inquiry.inquiryNum), // 고유 키 지정
              endActionPane: ActionPane(
                motion: ScrollMotion(),
                extentRatio: 0.25,
                children: [
                  // 슬라이드 시 반려 버튼 노출
                  SlidableAction(
                    onPressed: (_) => _showRejectConfirmDialog(inquiry.inquiryNum),
                    backgroundColor: Colors.red[400]!,
                    foregroundColor: Colors.white,
                    icon: Icons.close,
                    label: '반려',
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
              child: Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF8F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF8B4513).withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 문의 상태 배지
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: inquiry.inquiryState == '답변완료' 
                              ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          inquiry.inquiryState,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      
                      // 문의 내용
                      Text(
                        inquiry.inquiryContent,
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      
                      // ID + 닉네임 + 작성일 표시
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID: ${inquiry.userId}',
                              style: TextStyle(
                                color: Colors.grey[700], 
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '닉네임: ${inquiry.userNickname}',
                              style: TextStyle(
                                color: Colors.grey[700], 
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '작성일: ${_formatDate(inquiry.inquiryDate)}',
                              style: TextStyle(
                                color: Colors.grey[600], 
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // 답변 처리 버튼
                  trailing: ElevatedButton(
                    onPressed: () => _showAnswerDialog(inquiry.inquiryNum),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF8B4513),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      '답변 처리',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // 답변 내역 리스트 (response가 null이 아닌 항목만 표시) - 수정된 버전
  Widget _buildAnswerList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
          ),
        );
      }

      // 답변 완료된 문의만 필터링
      final answeredInquiries = controller.inquiryList
          .where((inquiry) => inquiry.response != null && inquiry.response!.isNotEmpty)
          .toList();

      if (answeredInquiries.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.question_answer_outlined, size: 80, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                '답변 완료된 내역이 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => controller.fetchInquiries(),
        color: Color(0xFF8B4513),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: answeredInquiries.length,
          itemBuilder: (context, index) {
            final inquiry = answeredInquiries[index];

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Color(0xFFF0F8F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
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
                        // 답변 완료 배지
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '답변완료',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // 답변일 (responseDate가 있으면 사용, 없으면 현재 날짜)
                        Text(
                          '답변일: ${inquiry.responseDate != null ? _formatDate(inquiry.responseDate!) : _formatDate(DateTime.now())}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    
                    // 사용자 정보
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            'ID: ${inquiry.userId} | 닉네임: ${inquiry.userNickname}',
                            style: TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),

                    // 문의 내용
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.help_outline, size: 16, color: Colors.blue[700]),
                              SizedBox(width: 4),
                              Text(
                                '문의 내용',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            inquiry.inquiryContent,
                            style: TextStyle(
                              fontSize: 14, 
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    
                    // 답변 내용
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.reply, size: 16, color: Colors.green[700]),
                              SizedBox(width: 4),
                              Text(
                                '답변 내용',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            inquiry.response ?? '',
                            style: TextStyle(
                              fontSize: 14, 
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // 반려 확인 다이얼로그
  void _showRejectConfirmDialog(int inquiryNum) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              '문의 반려',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          '이 문의를 반려하시겠습니까?\n반려된 문의는 복구할 수 없습니다.',
          style: TextStyle(fontSize: 14),
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
              await controller.deleteInquiry(inquiryNum);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              '반려하기',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 답변 처리 다이얼로그 팝업 (개선된 버전)
  void _showAnswerDialog(int inquiryNum) {
    final TextEditingController responseController = TextEditingController();
    final inquiry = controller.inquiryList.firstWhere((e) => e.inquiryNum == inquiryNum);

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.reply, color: Color(0xFF8B4513)),
            SizedBox(width: 8),
            Text(
              '답변 등록',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B4513),
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
              // 문의 내용 표시
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
                      '문의 내용:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      inquiry.inquiryContent,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              
              // 답변 입력 필드
              Text(
                '답변 내용:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: responseController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '고객에게 전달할 답변을 입력해주세요...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.all(12),
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
              if (responseController.text.trim().isEmpty) {
                Get.snackbar(
                  '알림',
                  '답변 내용을 입력해주세요.',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              }

              await controller.updateResponse(
                inquiryNum,
                responseController.text.trim(),
                DateTime.now(),
              );
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B4513),
            ),
            child: Text(
              '답변 등록',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 날짜 포맷: YYYY-MM-DD (intl 없이 구현)
  String _formatDate(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
