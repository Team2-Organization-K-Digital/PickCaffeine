// // 내 정보 수정 페이지
// /*
// // ----------------------------------------------------------------- //
//   - title         : Update Account Page
//   - Description   :
//   - Author        : Gam Sung
//   - Created Date  : 2025.06.05
//   - Last Modified : 2025.06.05
//   - package       :

// // ----------------------------------------------------------------- //
//   [Changelog]
//   - 2025.06.05 v1.0.0  :
// // ----------------------------------------------------------------- //
// */
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pick_caffeine_app/app_colors.dart';
// import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';
// import 'package:pick_caffeine_app/widget_class/utility/button_light_brown.dart';
// import 'package:pick_caffeine_app/widget_class/utility/custom_text_field.dart';
// class CustomerUpdateAccount extends StatelessWidget {
//   CustomerUpdateAccount({super.key});

//   final vm = Get.put(Vmgamseong());

//   final nicknamecontroller = TextEditingController();
//   final idcontroller = TextEditingController();
//   final pwcontroller = TextEditingController();
//   final checkpwcontroller = TextEditingController();
//   final phonecontroller = TextEditingController();
//   final emailcontroller = TextEditingController();
  

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Obx(() => 
//       Center(
//         child: Column(
//           children: [
//             Container(
//               height: 200,
//               width: 200,
//             ),
//             CustomTextField(
//               label: '닉네임', 
//               controller: nicknamecontroller),
//               SizedBox(height: 10,),
//               ButtonLightBrown(
//                 text: '닉네임 중복확인', onPressed: () async {
//                   if (nicknamecontroller.text.trim().isEmpty) {
//                   Get.snackbar('오류 발생', '값을 입력 한 뒤 확인 해주세요.', backgroundColor: AppColors.red, colorText: AppColors.white);
//                 }else{
//                   await vm.usernicknamecheck(nicknamecontroller.text.trim().toString());
//                   vm.nicknameCheck.value == 0
//                   ? _shownicknameDialogue('닉네임', nicknamecontroller.text.trim())
//                   : Get.snackbar('닉네임 중복', '다른 닉네임를 이용 해주세요.');
//                 }
//               },),
//               SizedBox(height: 30),
//               CustomTextField(label: "비밀번호를입력해주세요", controller: pwcontroller),
              
//               SizedBox(height: 30),
//               CustomTextField(label: "비밀번호를확안해주세요", controller: checkpwcontroller),
//               SizedBox(height: 10,),
//               ButtonLightBrown(text: "비밀번호확인", onPressed: () async{
//                 if(pwcontroller.text.trim() == checkpwcontroller.text.trim()){
//                   Get.snackbar("성공", "비밀번호가 일치합니다.",backgroundColor: AppColors.red, colorText: AppColors.white);

//                 }else{
//                   Get.snackbar("불일치", "비밀번호가 일치하지 않습니다.", backgroundColor: AppColors.red, colorText: AppColors.white);
                  
//                 }
//               },)

//           ],
//         ),

//       )  
//       )

//     );
    

    
//   }

// _shownicknameDialogue(String type,String input){
//   Get.defaultDialog(
//     title: '확인 완료',
//     middleText: 
//     '''
//     입력된 $type : $input 입니다.
//     입력하신 값을 사용 하시겠습니까?
//     ''',
//     actions: [
//       TextButton(
//         onPressed: () => Get.back(), 
//         child: Text('돌아가기',style: TextStyle(color: AppColors.brown))
//       ),
//       TextButton(
//         onPressed: () {
//           vm.nickReadOnly.value = true;
//           Get.back();
//         }, 
//         child: Text('사용하기',style: TextStyle(color: AppColors.brown))
//       ),
//     ]
//   );
// }

// }