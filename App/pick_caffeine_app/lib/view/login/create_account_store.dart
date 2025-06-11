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
import 'package:pick_caffeine_app/model/gamseong/create_store.dart';
import 'package:pick_caffeine_app/model/gamseong/store_home.dart';
import 'package:pick_caffeine_app/view/store/store_home_info.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';

class CreateAccountStore extends StatelessWidget {
  CreateAccountStore({super.key});

  final idcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final namecontroller = TextEditingController();
  final phonecontroller = TextEditingController();
  final businessnumcontroller = TextEditingController();
  final addresscontroller = TextEditingController();
  final addressdetailcontroller = TextEditingController();

  final createProvider = Get.find<VmStoreUpdate>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("매장 점주등록"),
      backgroundColor: const Color.fromARGB(255, 134, 69, 46),),
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
      child: ElevatedButton(
        onPressed: () async {
          final id = idcontroller.text.trim();
          if (id.isEmpty) {
            Get.snackbar("경고", "아이디를 입력하세요");
            return;
          }
          final exists = await createProvider.checkstoreid(id);
          if (exists) {
            Get.snackbar("중복", "이미 사용 중인 아이디입니다.");
            createProvider.storeidChecked.value = false;
          } else {
            Get.snackbar("확인", "사용 가능한 아이디입니다.");
            createProvider.storeidChecked.value = true;
          }
        },
        child: Text("중복확인"),
      ),
    ),
  ],
),
        Padding(
          padding: const EdgeInsets.all(20.100),
          child: Column(
            children: [
              _buildTextField("pw", passwordcontroller, obscureText: true),
              _buildTextField("매장명", namecontroller),
              _buildTextField("전화번호", phonecontroller, keyboadrdType: TextInputType.phone),
              _buildTextField("사업자번호", businessnumcontroller, keyboadrdType: TextInputType.number),
              _buildTextField("주소", addresscontroller),
              _buildTextField("상세주소", addressdetailcontroller),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (!createProvider.storeidChecked.value) {
              Get.snackbar("확인필요", "아이디 중복 확인하세요");
              return;
            }
            _createstore(context);
          },
          child: Text("등록"),
        ),
      ],
    ),
  ),
),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboadrdType,
    int maxLines = 1,
    int? maxLength,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboadrdType,
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
    );

      final result = await createProvider.createStore(store);
      if (result == 'OK') {
      
        createProvider.currentStore.value = StoreHome(
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
        store_state: false,
        store_regular_holiday: "",
        store_temporary_holiday: "",
        store_business_hour: "",
      );
      Get.defaultDialog(
        title: "가입 완료",
        middleText: "가입이 등록 되었습니다.",
        actions: [
          TextButton(
            onPressed: () => Get.to(()),
            child: Text("확인"),
      ),
    ],
  );
  }else{
    Get.snackbar("오류", result); 
  }
}}