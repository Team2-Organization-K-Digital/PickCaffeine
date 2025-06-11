// 홈 페이지 (매장, info)
/*
// ----------------------------------------------------------------- //
  - title         : Information Home Page (Store)
  - Description   : 매장 홈페이지 화면구성 ()
  - Author        : Kim Eunjun
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.05
  - package       : Getx

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  : 
// ----------------------------------------------------------------- //
*/

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/vm/eunjun/vm_handler_temp.dart';
import 'package:pick_caffeine_app/widget_class/utility/menu_utility.dart';

class StoreHomeInfo extends StatelessWidget {
  StoreHomeInfo({super.key});
  final vmHandler = Get.find<VmHandlerTemp>();

  @override
  Widget build(BuildContext context) {
    if (Device.get().isTablet) {
      return Obx(() {
        return vmHandler.loginStore.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 100,
                      child: Text(
                        vmHandler.loginStore.first.store_content,
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                    Row(
                      children: [
                        Text("영업시간 : ", style: TextStyle(fontSize: 30)),
                        Text(
                          vmHandler.loginStore.first.store_business_hour,
                          style: TextStyle(fontSize: 30),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text("정기 휴무 : ", style: TextStyle(fontSize: 30)),
                        Text(
                          vmHandler.loginStore.first.store_regular_hoilday,
                          style: TextStyle(fontSize: 30),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text("임시 휴무 : ", style: TextStyle(fontSize: 30)),
                        Text(
                          vmHandler.loginStore.first.store_temporary_holiday,
                          style: TextStyle(fontSize: 30),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text("전화번호: ", style: TextStyle(fontSize: 30)),
                        Text(
                          vmHandler.loginStore.first.store_phone,
                          style: TextStyle(fontSize: 30),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: SizedBox(
                        height: 700,
                        width: 800,
                        child: MenuUtility().flutterMap(vmHandler),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text("사업자 번호 : ", style: TextStyle(fontSize: 30)),
                        Text(
                          vmHandler.loginStore.first.store_business_num
                              .toString(),
                          style: TextStyle(fontSize: 30),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    SizedBox(height: 100),
                  ],
                ),
              ),
            );
      });
    }

    return Obx(() {
      return vmHandler.loginStore.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100,
                    child: Text(
                      vmHandler.loginStore.first.store_content,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  Row(
                    children: [
                      Text("영업시간 : ", style: TextStyle(fontSize: 15)),
                      Text(
                        vmHandler.loginStore.first.store_business_hour,
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("정기 휴무 : ", style: TextStyle(fontSize: 15)),
                      Text(
                        vmHandler.loginStore.first.store_regular_hoilday,
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("임시 휴무 : ", style: TextStyle(fontSize: 15)),
                      Text(
                        vmHandler.loginStore.first.store_temporary_holiday,
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("전화번호: ", style: TextStyle(fontSize: 15)),
                      Text(
                        vmHandler.loginStore.first.store_phone,
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      height: 500,
                      width: 400,
                      child: MenuUtility().flutterMap(vmHandler),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("사업자 번호 : "),
                      Text(
                        vmHandler.loginStore.first.store_business_num
                            .toString(),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  SizedBox(height: 100),
                ],
              ),
            ),
          );
    });
  }
}
