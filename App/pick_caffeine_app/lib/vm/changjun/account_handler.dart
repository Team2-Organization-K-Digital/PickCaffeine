import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/view/admin/admin_report_list.dart';
import 'package:pick_caffeine_app/view/customer/customer_bottom_tabbar.dart';
import 'package:pick_caffeine_app/view/store/store_main_bottom_tabbar.dart';

class AccountHandler extends GetxController{
  final String baseUrl = "http://127.0.0.1:8000/changjun";
// 회원가입 아이디 중복 확인
  final RxInt doubleCheck = 0.obs;
  final RxBool idReadOnly = false.obs;
// 회원가입 닉네임 중복 확인
  final RxInt nickDoubleCheck = 0.obs;
  final RxBool nickReadOnly = false.obs;
// 로그인 확인 int : 0 = 일치 하는 값 없음, 1 = 일치하는 값 있음
  final RxInt loginCheck = 0.obs;
  final box = GetStorage();
  final RxList<String> genderList = ['남성','여성'].obs;
  final RxString selectedgender = '남성'.obs;
// ---------------------------------------------------------------------------------- //
// 1. 사용자가 입력한 값을 database 에 insert 함 으로써 계정을 생성하는 함수
Future<void> createAccount(
  String userId,
  String userNickname,
  String userPW,
  String userPhone,
  String userEmail,
)async{
  var request = http.MultipartRequest(
    'POST', 
    Uri.parse("$baseUrl/insertUserAccount")
  );
  request.fields['userid'] = userId;
  request.fields['nickname'] = userNickname;
  request.fields['userPw'] = userPW;
  request.fields['phone'] = userPhone;
  request.fields['userEmail'] = userEmail;
  request.fields['userState'] = 0.toString();
  request.fields['createDate'] = (DateTime.now()).toString();
  request.fields['gender'] = selectedgender.value;

  var response = await request.send();
  if (response.statusCode == 200) {
    // print("회원가입 성공");
  } else {
    // print("회원가입 실패: ${response.statusCode}");
  }
}
// ---------------------------------------------------------------------------------- //
// 2. 고객 회원가입 시 입력한 id 값이 database 에 존재하는지 확인하는 함수
Future<dynamic> userIdDoubleCheck(String id)async{
  doubleCheck.value = 0;
  final res = await http.get(Uri.parse("$baseUrl/select/userid/doubleCheck/$id"));
  final data = json.decode(utf8.decode(res.bodyBytes))['results'];
  return doubleCheck.value = int.parse(data[0]['count'].toString());
}
// ---------------------------------------------------------------------------------- //
// 3. 고객 회원가입 시 입력한 nickname 값이 database 에 존재하는지 확인하는 함수
Future<dynamic> usernicknameDoubleCheck(String nickname)async{
  doubleCheck.value = 0;
  final res = await http.get(Uri.parse("$baseUrl/select/userid/doubleCheck/$nickname"));
  final data = json.decode(utf8.decode(res.bodyBytes))['results'];
  return doubleCheck.value = int.parse(data[0]['count'].toString());
}
// ---------------------------------------------------------------------------------- //
// 4. 로그인 시 사용자가 입력한 id 와 password 값이 일치하는 data 가 database (users, store, admin) 에 존재하는지 확인하는 함수
Future<dynamic> userLoginCheck(String id, String pw)async{
// users 테이블 대조
  box.write('loginId', id);
  loginCheck.value = 0;
  final resUser = await http.get(Uri.parse("$baseUrl/select/loginUser/$id/$pw"));
  final dataUser = json.decode(utf8.decode(resUser.bodyBytes))['results'];
  loginCheck.value = int.parse(dataUser[0]['count'].toString());
  if (loginCheck.value == 1) {
    return Get.to(()=>CustomerBottomTabbar());
  }
// store 테이블 대조
  loginCheck.value = 0;
  final resStore = await http.get(Uri.parse("$baseUrl/select/loginStore/$id/$pw"));
  final dataStore = json.decode(utf8.decode(resStore.bodyBytes))['results'];
  loginCheck.value = int.parse(dataStore[0]['count'].toString());
  if (loginCheck.value == 1) {
    return Get.to(()=>StoreMainBottomTabbar());
  }
// admin 테이블 대조
  // loginCheck.value = 0;
  // final resAdmin = await http.get(Uri.parse("$baseUrl/select/loginStore/$id/$pw"));
  // final dataAdmin = json.decode(utf8.decode(resAdmin.bodyBytes))['results'];
  // loginCheck.value = int.parse(dataAdmin[0]['count'].toString());
  // if (loginCheck.value == 1) {
  //   return Get.to(()=>AdminReportScreen());
  // }
// 일치하는 값이 없는 경우
  return Get.snackbar('로그인 실패', 'id 혹은 pw 값이 틀렸습니다.', backgroundColor: AppColors.red, colorText: AppColors.white);
}
// ---------------------------------------------------------------------------------- //
}