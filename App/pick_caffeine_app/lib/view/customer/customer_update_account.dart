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

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pick_caffeine_app/vm/gamseong/image_vm.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';
import 'package:pick_caffeine_app/widget_class/utility/button_light_brown.dart';

class CustomerUpdateAccount extends StatelessWidget {
  CustomerUpdateAccount({super.key});

  final vm = Get.find<Vmgamseong>();
  final image = Get.find<Vmgamseong>();
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

    // base64 이미지 처리
    Uint8List originalImage = Uint8List(0);
    if (args[5] != null && args[5] != '') {
      try {
        originalImage = base64Decode(args[5]);
      } catch (e) {
        print("!base64 디코딩 오류: $e");
      }
    }

    // 초기 텍스트 입력값 설정
    nicknameController.text = args[0] ?? '';
    idController.text = args[1] ?? '';
    pwController.text = args[2] ?? '';
    checkPwController.text = args[2] ?? '';
    phoneController.text = args[3] ?? '';
    emailController.text = args[4] ?? '';

    final userId = box.read('loginId');
    vm.informationuserid(userId); // 최신 정보 갱신

    return Scaffold(
      body: Obx(() {
        final user = vm.user;
        if (user.isEmpty) return Center(child: CircularProgressIndicator());

        return SafeArea(
  child: SingleChildScrollView(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    child: Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        SizedBox(height: 10),
        // 중앙 원형 이미지
        GestureDetector(onTap: () async{
          await image.getImageFromGallery(ImageSource.gallery);
        },
          child: ClipOval(
            child: image.imageFile.value != null
                ? Image.file(File(image.imageFile.value!.path), width: 120, height: 120, fit: BoxFit.cover)
                : originalImage.isNotEmpty
                    ? Image.memory(originalImage, width: 120, height: 120, fit: BoxFit.cover)
                    : Icon(Icons.person, size: 120),
          ),
        ),
        SizedBox(height: 20,),
        
        SizedBox(height: 20),
        _buildField("닉네임", nicknameController),
        SizedBox(height: 10),
        Divider(thickness: 2, color: Colors.brown[100]),
        SizedBox(height: 10),
        _buildField("ID", idController, readOnly: true),
        _buildField("PW", pwController, obscure: true),
        _buildField("PW확인", checkPwController, obscure: true),
        _buildField("전화번호", phoneController),
        _buildField("이메일", emailController),
        SizedBox(height: 20),
        ButtonLightBrown(text: "정보수정", onPressed: () async {
                    if (pwController.text != checkPwController.text) {
                      Get.snackbar("오류", "비밀번호가 일치하지 않습니다");
                      return;
                    }
                    String imageBase64 = user['user_image'] ?? '';
                    if (image.imageFile.value != null) {
                      final imageBytes =
                          await File(image.imageFile.value!.path).readAsBytes();
                      imageBase64 = base64Encode(imageBytes);
                    }
          
                    vm.updateUserInfo({
                      "user_id": idController.text,
                      "user_nickname": nicknameController.text,
                      "user_password": pwController.text,
                      "user_phone": phoneController.text,
                      "user_email": emailController.text,
                      "user_image": imageBase64,
                    });
                  },
              )

              
              ],
            ),
          ),
        );
      }),
    );
  }

  // 텍스트 필드 생성 위젯
  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    bool obscure = false,
  }) {
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

  // 이미지 선택 위젯
  Widget _buildImagePicker(BuildContext context, Uint8List originalImage) {
    final imageFile = image.imageFile;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => image.getImageFromGallery(ImageSource.gallery),
              child: Text("갤러리"),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => image.getImageFromGallery(ImageSource.camera),
              child: Text("카메라"),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          height: 200,
          color: Colors.grey[300],
          child:
              imageFile.value != null
                  ? Image.file(File(imageFile.value!.path), fit: BoxFit.cover)
                  : (originalImage.isNotEmpty
                      ? Image.memory(originalImage, fit: BoxFit.cover)
                      : Icon(Icons.image_not_supported)),
        ),
      ],
    );
  }
}


