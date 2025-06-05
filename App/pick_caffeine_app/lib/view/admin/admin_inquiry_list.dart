// 문의 리스트 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Inquiry List Page
  - Description   : 관리자 문의내역 페이지(탭바 사용으로 한 곳에 코드 구현)
  - Author        : Lee KwonHyoung
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.05
  - package       : get: ^4.7.2, flutter_slidable: ^4.0.0

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  : 관리자 문의내역 첫 작성
// ----------------------------------------------------------------- //
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; 
import 'package:pick_caffein/vm/getx_controller.dart'; 
import 'package:pick_caffein/view/widgets/admin_bottom_tab.dart'; 

class InquiryReport extends StatelessWidget {
  InquiryReport({super.key});
  final InquiryController controller = Get.put(InquiryController());

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
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Obx(() => Text(
            tabIndex.value == 0 ? '문의내역' : '답변내역',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
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
            ),
            child: Text(
              '문의내역',
              style: TextStyle(
                color: tabIndex.value == 0 ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
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
            ),
            child: Text(
              '답변내역',
              style: TextStyle(
                color: tabIndex.value == 1 ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
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
        return Center(child: CircularProgressIndicator());
      }

      if (controller.inquiryList.isEmpty) {
        return Center(child: Text('문의 내역이 없습니다.'));
      }

      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: controller.inquiryList.length,
        itemBuilder: (context, index) {
          final inquiry = controller.inquiryList[index];

          return Slidable(
            key: ValueKey(inquiry.inquiryNum), // 고유 키 지정
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              extentRatio: 0.25,
              children: [
                // 슬라이드 시 반려 버튼 노출
                SlidableAction(
                  onPressed: (_) => controller.deleteInquiry(inquiry.inquiryNum),
                  backgroundColor: Colors.red[300]!,
                  foregroundColor: Colors.white,
                  icon: Icons.close,
                  label: '반려',
                ),
              ],
            ),
            child: Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Color(0xFFFFF1EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 문의 내용
                    Text(
                      inquiry.inquiryContent,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    // ID + 작성일 표시
                    Text(
                      'ID/닉네임: ${inquiry.userId}/${inquiry.userNickname} \n작성일: ${_formatDate(inquiry.inquiryDate)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                // 답변 처리 버튼
                trailing: ElevatedButton(
                  onPressed: () => _showAnswerDialog(inquiry.inquiryNum),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF8B4513),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Color(0xFF8B4513)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('답변 처리'),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  // 답변 내역 리스트 (answerContent가 null이 아닌 항목만 표시)
  Widget _buildAnswerList() {
  return Obx(() {
    final answers = controller.inquiryList.where((e) => e.response != null).toList();

    if (answers.isEmpty) {
      return Center(child: Text('답변 완료된 내역이 없습니다.'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: answers.length,
      itemBuilder: (context, index) {
        final inquiry = answers[index];

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Color(0xFFFFF1EC),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ID, 닉네임, 답변일자 표시
                Text(
                  '등록일: ${_formatDate((inquiry.response is DateTime ? inquiry.response as DateTime : DateTime.now()))}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  'ID/닉네임: ${inquiry.userId} / ${inquiry.userNickname}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),

                // 문의 및 답변 내용
                Text('문의: ${inquiry.inquiryContent}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text('답변: ${inquiry.response}',
                    style: TextStyle(fontSize: 14, color: Colors.black87)),
              ],
            ),
          ),
        );
      },
    );
  });
}


  // 답변 처리 다이얼로그 팝업
  void _showAnswerDialog(int inquiryNum) {
    final TextEditingController responseController = TextEditingController();
    controller.inquiryList.firstWhere((e) => e.inquiryNum == inquiryNum);

    Get.dialog(
      AlertDialog(
        title: Text('답변 등록'),
        content: TextField(
          controller: responseController,
          maxLines: 4,
          decoration: InputDecoration(labelText: '답변 입력'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('취소')),
          ElevatedButton(
            onPressed: () async {
              await controller.updateResponse(
                inquiryNum,
                responseController.text,
                DateTime.now(),
              );
              Get.back();
            },
            child: Text('등록'),
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
