// 관리자 페이지 바텀 탭바 (25.06.11)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/view/admin/admin_inquiry_list.dart';
import 'package:pick_caffeine_app/view/admin/admin_report_list.dart';


// 관리자 하단 네비게이션 위젯
class BottomTabbar extends StatelessWidget {
  final int selectedIndex;

  const BottomTabbar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
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
          // 매장 관리 탭
          Expanded(
            child: InkWell(
              onTap: () {
                if (selectedIndex != 0) {
                  Get.off(() => AdminReportScreen
                  ());
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store, 
                    color: selectedIndex == 0 
                        ? Colors.white 
                        : Colors.white.withAlpha(150), 
                    size: 26
                  ),
                  SizedBox(height: 4),
                  Text(
                    '매장 관리',
                    style: TextStyle(
                      color: selectedIndex == 0 
                          ? Colors.white 
                          : Colors.white.withAlpha(150),
                      fontSize: 12,
                      fontWeight: selectedIndex == 0 
                          ? FontWeight.w600 
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 구분선
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withAlpha(25),
          ),
          
          // 문의 관리 탭
          Expanded(
            child: InkWell(
              onTap: () {
                if (selectedIndex != 1) {
                  Get.off(() => InquiryReport());
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.question_answer, 
                    color: selectedIndex == 1 
                        ? Colors.white 
                        : Colors.white.withAlpha(150), 
                    size: 26
                  ),
                  SizedBox(height: 4),
                  Text(
                    '문의 관리',
                    style: TextStyle(
                      color: selectedIndex == 1 
                          ? Colors.white 
                          : Colors.white.withAlpha(150),
                      fontSize: 12,
                      fontWeight: selectedIndex == 1 
                          ? FontWeight.w600 
                          : FontWeight.w400,
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
