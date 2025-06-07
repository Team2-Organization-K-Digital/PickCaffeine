// 홈 페이지 (매장, info)
/*
// ----------------------------------------------------------------- //
  - title         : Information Home Page (Store)
  - Description   : 매장 홈페이지 화면구성 ()
  - Author        : Kim Eunjun
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.05
  - package       :

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  : 
// ----------------------------------------------------------------- //
*/

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/vm/Eunjun/vm_handler_temp.dart';

class StoreHomeInfo extends StatelessWidget {
  StoreHomeInfo({super.key});
  final vmHandler = Get.find<VmHandlerTemp>();

  @override
  Widget build(BuildContext context) {
    vmHandler.fetchLoginStore(111.toString());

    return Obx(() {
      return Scaffold(
        body:
            vmHandler.loginStore.isEmpty
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 100,
                          child: Text(vmHandler.loginStore.first.store_content),
                        ),
                        Row(
                          children: [
                            Text("영업시간 : "),
                            Text(
                              vmHandler.loginStore.first.store_business_hour,
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Text("정기 휴무 : "),
                            Text(
                              vmHandler.loginStore.first.store_regular_hoilday,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text("임시 휴무 : "),
                            Text(
                              vmHandler
                                  .loginStore
                                  .first
                                  .store_temporary_holiday,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text("전화번호: "),
                            Text(vmHandler.loginStore.first.store_phone),
                          ],
                        ),
                        SizedBox(height: 800, width: 200, child: Text('지도')),
                        Text("ddsfas"),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
      );
    });
  }
}
