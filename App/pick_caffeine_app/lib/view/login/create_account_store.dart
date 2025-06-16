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

import 'package:pick_caffeine_app/vm/Eunjun/vm_handler_temp.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';

import 'package:pick_caffeine_app/widget_class/utility/button_light_brown.dart';

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
      backgroundColor: AppColors.lightpick,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.white,
        title: Text("매장 회원가입", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Row(
  children: [
    Expanded(child: _buildTextField("Id", idcontroller)),
    SizedBox(width: 8),
    Flexible(
      flex: 0,
      child: ButtonLightBrown(text: '아이디 중복 확인',
        onPressed: () async {
          final id = idcontroller.text.trim();
          if (id.isEmpty) {
            Get.snackbar("경고", "아이디를 입력하세요");
            return;
            }
          final exists = await vm.checkstoreid(id);
          if (exists) {
            Get.snackbar("중복", "이미 사용 중인 아이디입니다.",backgroundColor: AppColors.red,colorText: AppColors.white);
            vm.storeidChecked.value = false;
          } else {
            Get.snackbar("확인", "사용 가능한 아이디입니다.",backgroundColor: AppColors.black,colorText: AppColors.white);
            vm.storeidChecked.value = true;
          }},
      ),),],
      ),
          
        Row(
  children: [
    Expanded(child: _buildTextField("매장명", namecontroller)),
    SizedBox(width: 8),
    Flexible(
      flex: 0,
      child: ButtonLightBrown(
        text: '매장명 중복 확인',
        onPressed: () async {
          final name = namecontroller.text.trim();
          if (name.isEmpty) {
            Get.snackbar("경고", "매장명을 입력하세요");
            return;
          }
          final exists = await vm.checkstorename(name);
          if (exists) {
            Get.snackbar("중복", "이미 사용 중인 매장명입니다.", backgroundColor: AppColors.red, colorText: AppColors.white);
            vm.storenameChecked.value = false;
          } else {
            Get.snackbar("확인", "사용 가능한 매장명입니다.", backgroundColor: AppColors.black, colorText: AppColors.white);
            vm.storenameChecked.value = true;
          }
        },
      ),
    ),
  ],
),
          SizedBox(height: 20),

                      _buildTextField("pw", passwordcontroller, obscureText: true),
                      _buildTextField("전화번호", phonecontroller, keyboardType: TextInputType.phone),
                      _buildTextField("사업자번호", businessnumcontroller, keyboardType: TextInputType.number),
                      _buildTextField("주소", addresscontroller),
                      _buildTextField("상세주소", addressdetailcontroller),
            SizedBox(height: 20),
            ButtonLightBrown( 
              text: "매장등록", 
                onPressed: () {
                            if (!vm.storeidChecked.value) {
                          Get.snackbar("확인필요", "아이디 중복 확인하세요");
                            return;
                            }
                          if (!vm.storenameChecked.value) {
                            Get.snackbar("확인필요", "매장명 중복 확인하세요");
                          return;
                                    }
                              _createstore(context);
                              },
              )
          ],
        ),

    ),
  ),
);
    
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

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
      store_created_date: DateTime.now().toIso8601String(),
    );



      final result = await vm.createStore(store);
      if (result == 'OK') {

      
        vm.currentStore.value = StoreHome(
        store_id: idcontroller.text,
        store_password: passwordcontroller.text,
        store_name: namecontroller.text,
        store_phone: phonecontroller.text,
        store_business_num: int.parse(businessnumcontroller.text),
        store_address: addresscontroller.text,
        store_address_detail: addressdetailcontroller.text,
        store_latitude: 0.0,
        store_longitude: 0.0,
        store_content: "",
        store_state: 0 ,
        store_regular_holiday: "",
        store_temporary_holiday: "",
        store_business_hour: "",
        store_created_date: DateTime.now().toIso8601String(),
      );



      
      
      Get.defaultDialog(
        title: "가입 완료",
        middleText: "매장이 등록 되었습니다.",
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            } ,
            child: Text("확인"),
      ),
    ],
  );
  }else{
    Get.snackbar("오류", result); 
  }
}}