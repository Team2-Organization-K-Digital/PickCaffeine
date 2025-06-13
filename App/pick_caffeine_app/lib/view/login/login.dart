// 로그인 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Login Page
  - Description   : 사용자가 앱을 처음 실행 시켰을 때 나타나는 페이지이며
  -               : 아이디와 비밀번호를 입력하여 로그인을 할 수 있고
  -               : 회원가입 버튼을 눌러 고객 또는 매장 회원 가입을 진행 할 수 있다.
  - Author        : Lee ChangJun
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.09
  - package       : GetX

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  : 로그인에 필요한 textfield 와 회원 가입에 필요한 버튼 추가

  - 2025.06.09 v1.0.1  : vm 과의 연결을 통해 입력한 값을 database 에 비교하여 로그인을 하는 기능 추가
  -                    : 일치하는 값이 있는 경우 - 고객 페이지로 로그인
  -                    : 일치하는 값이 없는 경우 - 로그인 실패 snackbar
// ----------------------------------------------------------------- //
*/
// ----------------------------------------------------------------- //
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/view/login/create_account_store.dart';
import 'package:pick_caffeine_app/view/login/create_account_user.dart';
import 'package:pick_caffeine_app/vm/changjun/account_handler.dart';
import 'package:pick_caffeine_app/vm/changjun/jun_temp.dart';
import 'package:pick_caffeine_app/widget_class/utility/button_brown.dart';
import 'package:pick_caffeine_app/widget_class/utility/custom_text_field.dart';
// ----------------------------------------------------------------- //
class Login extends StatelessWidget {
  Login({super.key});
  final idController = TextEditingController();
  final pwController = TextEditingController();
  final AccountHandler accountHandler = Get.find<JunTemp>();
// ----------------------------------------------------------------- //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightpick,
      appBar: AppBar(
        toolbarHeight: 180,
        backgroundColor: AppColors.brown,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Pick',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40, color: AppColors.white)),
            Text('Caffeine',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40, color: AppColors.white)),
          ],
        )
      ),
// ----------------------------------------------------------------- //
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
// textfield : id
              SizedBox(height: 100),
              SizedBox(width: 300, child: CustomTextField(label: "ID", controller: idController)),
              SizedBox(height: 20,),
// textfield : pw
              SizedBox(width: 300, child: CustomTextField(label: "PW", controller: pwController, obscureText: true,)),
              SizedBox(height: 20,),
// button : login
              ButtonBrown(text: '로그인',  
              onPressed: () async{
                if (
                  idController.text.trim().isEmpty||
                  pwController.text.trim().isEmpty
                  )
                  
                  {
                  Get.snackbar('에러 발생', 'id 혹은 pw 값을 입력 해주세요.', backgroundColor: AppColors.red, colorText: AppColors.white);
                } else{
                  print("👉 로그인 시도 중");
                  await accountHandler.userLoginCheck(
                    idController.text.trim(), 
                    pwController.text.trim()
                    
                  );


                }
              }
            ),
// create account
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 200, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('계정이 없으신가요?',
                    style: TextStyle(
                      fontSize: 12
                    ),
                  ),
                    SizedBox(
                      width: 5,
                    ),
// button : show create account dialogue
                    TextButton(
                      onPressed: () {
                        _showDialogue();
                      }, 
                      child: Text("회원가입",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.brown
                      ),)
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
// ------------------------------- Functions ------------------------------------ //
// 고객 및 매장 회원가입 페이지로 이동하기 위한 button 이 나타날 dialogue
_showDialogue(){
  Get.defaultDialog(
    title: '회원가입',
    content: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
          child: Text('가입 유형을 선택 해주세요.'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
// button : go to create account user page
          SizedBox(height: 35, child: ButtonBrown(text: '고객 가입', onPressed: () {
            Get.back();
            Get.to(()=> CreateAccountUser());
            
          },)),
// button : go to create account store page
          SizedBox(width: 20),
          SizedBox(height: 35, child: ButtonBrown(text: '매장 가입', onPressed: () {
            Get.back();
            Get.to(()=> CreateAccountStore());
          },)),
          ],
        )
      ],
    ),
// button : go back
    actions: [
      TextButton(onPressed: () => Get.back(), child: Text('돌아가기',style: TextStyle(color: AppColors.brown),))
    ],
    barrierDismissible: false
  );
}
// ----------------------------------------------------------------------------- //
}