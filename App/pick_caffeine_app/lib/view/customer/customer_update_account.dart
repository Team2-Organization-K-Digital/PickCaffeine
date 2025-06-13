// 내 정보 수정 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Update Account Page
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
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';


class CustomerUpdateAccount extends StatelessWidget {
  CustomerUpdateAccount({super.key});
  final vm = Get.find<Vmgamseong>();
  final box = GetStorage();

  final nicknameController = TextEditingController();
  final idController = TextEditingController();
  final pwController = TextEditingController();
  final checkPwController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();





        
      

  @override
  Widget build(BuildContext context) {

  final args = Get.arguments;
  nicknameController.text = args[0];
  idController.text = args[1];
  pwController.text = args[2];
  phoneController.text = args[3];
  emailController.text = args[4];

    vm.informationuserid(); 

    return Scaffold(
      body: Obx(() {
        final user = vm.user;
        if (user.isEmpty) return Center(child: CircularProgressIndicator());
        nicknameController.text = user['user_nickname'] ?? '';
        idController.text = user['user_id'] ?? '';
        phoneController.text = user['user_phone'] ?? '';
        emailController.text = user['user_email'] ?? '';

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Get.back(),
              ),
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(user['user_image'] ?? 'https://via.placeholder.com/150'),
              ),
              SizedBox(height: 20),
              _buildField("닉네임", nicknameController),
              _buildField("ID", idController, readOnly: true),
              _buildField("PW", pwController, obscure: true),
              _buildField("PW확인", checkPwController, obscure: true),
              _buildField("전화번호", phoneController),
              _buildField("이메일", emailController),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                onPressed: () {
                  if (pwController.text != checkPwController.text) {
                    Get.snackbar("오류", "비밀번호가 일치하지 않습니다");
                    return;
                  }
                  vm.updateUserInfo({
                    "user_id": idController.text,
                    "user_nickname": nicknameController.text,
                    "user_password": pwController.text,
                    "user_phone": phoneController.text,
                    "user_email": emailController.text,
                    "user_image": user['user_image']
                  });
                },
                child: Text("정보수정"),
              ),
            ],
          ),
        );
      }),
    );

    
  }

  

  Widget _buildField(String label, TextEditingController controller, {bool readOnly = false, bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextField(
          controller: controller,
          obscureText: obscure,
          readOnly: readOnly,
          decoration: InputDecoration(border: OutlineInputBorder()),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  

  
}
