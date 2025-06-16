// 회원가입 페이지 (매장)
/*
// ----------------------------------------------------------------- //
  - title         : Create Store Account Page
  - Description   :
  - Author        : Gam Sung
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.05
  - package       :

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  :
// ----------------------------------------------------------------- //
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/model/gamseong/create_store.dart';
import 'package:pick_caffeine_app/model/gamseong/store_home.dart';
import 'package:pick_caffeine_app/view/login/login.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';
import 'package:pick_caffeine_app/widget_class/utility/button_brown.dart';
import 'package:pick_caffeine_app/widget_class/utility/button_light_brown.dart';
import 'package:pick_caffeine_app/widget_class/utility/custom_text_field.dart';

class CreateAccountStore extends StatelessWidget {
  CreateAccountStore({super.key});

  final idcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final namecontroller = TextEditingController();
  final phonecontroller = TextEditingController();
  final businessnumcontroller = TextEditingController();
  final addresscontroller = TextEditingController();
  final addressdetailcontroller = TextEditingController();

  final vm = Get.find<Vmgamseong>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          "매장 점주등록",
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomTextField(label: "Id", controller: idcontroller),
              SizedBox(height: 8),
              Flexible(
                flex: 0,
                child: ButtonLightBrown(
                  onPressed: () async {
                    final id = idcontroller.text.trim();
                    if (id.isEmpty) {
                      Get.snackbar("경고", "아이디를 입력하세요");
                      return;
                    }
                    final exists = await vm.checkstoreid(id);
                    if (exists) {
                      Get.snackbar(
                        "중복",
                        "이미 사용 중인 아이디입니다.",
                        backgroundColor: Colors.red,
                      );
                      vm.storeidChecked.value = false;
                    } else {
                      Get.snackbar(
                        "확인",
                        "사용 가능한 아이디입니다.",
                        backgroundColor: Colors.blue,
                      );
                      vm.storeidChecked.value = true;
                    }
                  },
                  text: "중복확인",
                ),
              ),
              SizedBox(height: 20,),
              Column(
                children: [
                  CustomTextField(
                    label:  "pw",
                    controller: passwordcontroller,
                    obscureText: true,
                  ),
                  SizedBox(height: 10,),
                  CustomTextField(label: "매장명", controller: namecontroller),
                  SizedBox(height: 10,),
                  CustomTextField(
                    label:  "전화번호",
                    controller:  phonecontroller,
                    // keyboadrdType: TextInputType.phone,
                  ),
                  SizedBox(height: 10,),
                  CustomTextField(
                    label:  "사업자번호",
                    controller:  businessnumcontroller,
                    // keyboadrdType: TextInputType.number,
                  ),
                  SizedBox(height: 10,),
                  CustomTextField(label: "주소", controller: addresscontroller),
                  SizedBox(height: 10,),
                  CustomTextField(label:  "상세주소", controller: addressdetailcontroller),
                  SizedBox(height: 10,),
                ],
              ),
              ButtonBrown(
                onPressed: () {
                  if (!vm.storeidChecked.value) {
                    Get.snackbar("확인필요", "아이디 중복 확인하세요");
                    return;
                  }
                  _createstore(context);
                },
                text:  "등록",
              ),
              ButtonBrown(
                onPressed: () => Get.to(Login()),
          
                text:  "로그인",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildTextField(
  //   String label,
  //   TextEditingController controller, {
  //   TextInputType? keyboadrdType,
  //   int maxLines = 1,
  //   int? maxLength,
  //   bool obscureText = false,
  // }) {
  //   return TextField(
  //     controller: controller,
  //     keyboardType: keyboadrdType,
  //     maxLines: maxLines,
  //     maxLength: maxLength,
  //     decoration: InputDecoration(
  //       labelText: label,
  //       border: OutlineInputBorder(),
  //     ),
  //   );
  // }

  Future<void> _createstore(BuildContext context) async {
    int? businessNum;
    try {
      businessNum = int.parse(businessnumcontroller.text.trim());
    } catch (e) {
      Get.snackbar("오류", "사업자번호는 숫자만 입력하세요");

      return;
    }

    final store = CreateStore(
      store_id: idcontroller.text.trim(),
      store_password: passwordcontroller.text.trim(),
      store_name: namecontroller.text.trim(),
      store_phone: phonecontroller.text.trim(),
      store_business_num: businessNum,
      store_address: addresscontroller.text.trim(),
      store_address_detail: addressdetailcontroller.text.trim(),
      store_created_date: DateTime.now().toString(),
    );

    final result = await vm.createStore(store);
    if (result == 'OK') {
      Get.defaultDialog(
        title: "가입 완료",
        middleText: "매장이 등록 되었습니다.",
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: Text("확인"),
          ),
        ],
      );
    } else {
      Get.snackbar("오류", result);
    }
  }
}
