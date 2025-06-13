// import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';

// class VmReview extends VmStoreUpdate{
  
  
// }
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pick_caffeine_app/model/gamseong/user_information.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_review.dart';

class VmInformation extends VmReview{
final baseUrl = "http://127.0.0.1:8000/seong";        
  final RxInt nicknameCheck = 0.obs;
  final RxBool nickReadOnly = false.obs;


  final user = <String, dynamic>{}.obs;




Future<void> information()async{
try{
  final res = await http.get(Uri.parse("$baseUrl/user/information"));
  final decoded = json.decode(utf8.decode(res.bodyBytes));
  if (decoded['result'] == 'OK') {
      user.value = decoded['data'][0];
  }
} catch(e) {
  print("오류 : $e");
}
  
}

// 내정보 업데이트
Future<String> updateUserInformation(UserInformation info) async {
  final response = await http.put(
    Uri.parse("$baseUrl/update/user/information"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(info.toMap()),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (data['result'] == 'OK') {
      return '성공';
    } else {
      return '실패: ${data['detail']}';
    }
  } else {
    return '서버 오류';
  }
}

  //닉네임 중복체크
  Future<dynamic> usernicknamecheck(String nickname)async{
  nicknameCheck.value = 0;
  final res = await http.get(Uri.parse("$baseUrl/myinformation/checknickname/$nickname"));
  final data = json.decode(utf8.decode(res.bodyBytes))['data'];
  return nicknameCheck.value = int.parse(data[0]['count'].toString());
}

}
  
