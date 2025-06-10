// 회원가입 페이지 (고객)
/*
// ----------------------------------------------------------------- //
  - title         : Create User Account Page
  - Description   : 사용자가 로그인을 하기 위한 계정을 등록하기 위한 회원가입 페이지
  - Author        : Lee ChangJun
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.09
  - package       : GetX

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  :
// ----------------------------------------------------------------- //
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
import 'package:pick_caffeine_app/widget_class/utility/button_brown.dart';
import 'package:pick_caffeine_app/widget_class/utility/button_light_brown.dart';
import 'package:pick_caffeine_app/widget_class/utility/custom_text_field.dart';

class CreateAccountUser extends StatelessWidget {
  CreateAccountUser({super.key});
  final accountHandler = Get.find<JunTemp>();
  final idController = TextEditingController();
  final nickNameController = TextEditingController();
  final pwController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightpick,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.white,
        title: Text("유저 회원가입", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
// ----------------------------------------------------------------- //
      body:Obx(() => 
Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              SizedBox(height: 30),
// id 등록
              CustomTextField(label: "아이디 를 입력 해주세요", controller: idController, readOnly: accountHandler.idReadOnly.value),
              SizedBox(height: 10),
              ButtonLightBrown(text: '아이디 중복 확인', onPressed: () async{
                if (idController.text.trim().isEmpty) {
                  Get.snackbar('오류 발생', '값을 입력 한 뒤 확인 해주세요.', backgroundColor: AppColors.red, colorText: AppColors.white);
                }else{
                  await accountHandler.userIdDoubleCheck(idController.text.trim().toString());
                  accountHandler.doubleCheck.value == 0
                  ? _showIdDialogue('아이디', idController.text.trim())
                  : Get.snackbar('아이디 중복', '다른 아이디를 이용 해주세요.', backgroundColor: AppColors.red,colorText: AppColors.white);
                }
              },
            ),
              SizedBox(height: 20),
// nickname 입력
              CustomTextField(label: "닉네임 을 입력 해주세요", controller: nickNameController),
              SizedBox(height: 10),
              ButtonLightBrown(text: '닉네임 중복 확인', onPressed: () async{
                if (nickNameController.text.trim().isEmpty) {
                  Get.snackbar('오류 발생', '값을 입력 한 뒤 확인 해주세요.', backgroundColor: AppColors.red, colorText: AppColors.white);
                }else{
                  await accountHandler.usernicknameDoubleCheck(nickNameController.text.trim().toString());
                  accountHandler.nickDoubleCheck.value == 0
                  ? _showIdDialogue('닉네임', nickNameController.text.trim())
                  : Get.snackbar('닉네임 중복', '다른 닉네임를 이용 해주세요.');
                }
                
                
              },),
              SizedBox(height: 30),
              CustomTextField(label: "비밀번호 를 입력 해주세요", controller: pwController),
              SizedBox(height: 30),
              CustomTextField(label: "전화번호 를 입력 해주세요", controller: phoneController),
              SizedBox(height: 30),
              CustomTextField(label: "이메일 을 입력 해주세요", controller: emailController),
              SizedBox(height: 30),
              ButtonBrown(
                text: '회원가입', 
                onPressed: () async{
                  if (
                  idController.text.trim().isEmpty||
                  nickNameController.text.trim().isEmpty||
                  pwController.text.trim().isEmpty||
                  phoneController.text.trim().isEmpty||
                  emailController.text.trim().isEmpty
                  ) {
                    Get.snackbar('오류', '입력하지 않은 값이 있습니다.',backgroundColor: AppColors.red,colorText: AppColors.white);
                  } else if(
                    accountHandler.idReadOnly.value == false||
                    accountHandler.nickReadOnly.value == false
                  ){
                    Get.snackbar('오류', '중복 확인을 진행 해주세요.',backgroundColor: AppColors.red,colorText: AppColors.white);
                  } else{
                    await accountHandler.createAccount(
                      idController.text.trim(), 
                      nickNameController.text.trim(), 
                      pwController.text.trim(), 
                      phoneController.text.trim(), 
                      emailController.text.trim()
                    );
                    _showDialogue();
                  }
                },
              )
            ],
          ),
        ),
      ), // center
      ) 
    );
  }
// ----------------------------------------------------------------- //
_showDialogue(){
  Get.defaultDialog(
    title: '가입 완료',
    middleText: '로그인을 진행 해주세요.',
    actions: [
      TextButton(
        onPressed: () {
          Get.back();
          Get.back();
        }, 
        child: Text('돌아가기', style: TextStyle(color: AppColors.brown))
      )
    ]
  );
}
// ----------------------------------------------------------------- //
_showIdDialogue(String type,String input){
  Get.defaultDialog(
    title: '확인 완료',
    middleText: 
    '''
    입력된 $type : $input 입니다.
    입력하신 값을 사용 하시겠습니까?
    ''',
    actions: [
      TextButton(
        onPressed: () => Get.back(), 
        child: Text('돌아가기',style: TextStyle(color: AppColors.brown))
      ),
      TextButton(
        onPressed: () {
          type == '아이디'
          ?accountHandler.idReadOnly.value = true
          :accountHandler.nickReadOnly.value = true;
          Get.back();
        }, 
        child: Text('사용하기',style: TextStyle(color: AppColors.brown))
      ),
    ]
  );
}
// ----------------------------------------------------------------- //
}