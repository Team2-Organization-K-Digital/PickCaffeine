// 관리자 통계 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Statistics Page
  - Description   : 관리자가 로그인 이후 전체 매장의 매출과 거래량을 chart 로 기간 별 확인 할 수 있고
  -                 회원들의 가입 수를 기간 별로 chart 로 확인 할 수 있는 페이지
  - Author        : Lee ChangJun
  - Created Date  : 2025.06.13
  - Last Modified : 2025.06.13
  - package       : GetX, Syncfusion

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  : 전반적인 화면 디자인 및 chart 구현 back_end 와 연결 및 vm 과 연결
// ----------------------------------------------------------------- //
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';

class AdminStatistics extends StatelessWidget {
  AdminStatistics({super.key});
  final chartHandler = Get.find<JunTemp>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () {
          return Center(
            child: Column(
              children: [
                Text('data')
              ],
            ),
          );
        },
      ),
    );
  }
}