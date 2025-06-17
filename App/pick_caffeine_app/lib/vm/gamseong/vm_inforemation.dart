// import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';

// class VmReview extends VmStoreUpdate{

// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:pick_caffeine_app/vm/gamseong/vm_review.dart';

class VmInformation extends VmReview {
  final baseUrl = "http://127.0.0.1:8000/seong";
  final RxInt nicknameCheck = 0.obs;
  final RxBool nickReadOnly = false.obs;
  final user = <String, dynamic>{}.obs;

  // 유저들의 개인정보
  Future<void> information() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/user/information"));
      final decoded = json.decode(utf8.decode(res.bodyBytes));
      if (decoded['result'] == 'OK') {
        user.value = decoded['data'][0];
      }
    } catch (e) {
      print("오류 : $e");
    }
  }

  Future<void> informationuserid(String userId) async {
    // 로그인 시 저장된 아이디
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/user/information/$userId"),
      );
      final decoded = json.decode(utf8.decode(res.bodyBytes));
      print("🔍 서버 응답: $decoded");

      if (decoded['result'] == 'OK') {
        final raw = decoded['data'][0];
        user.value = {
          'user_id': raw[0],
          'user_nickname': raw[1],
          'user_password': raw[2],
          'user_phone': raw[3],
          'user_email': raw[4],
          'user_state': raw[5],
          'user_create_date': raw[6],
          'user_image': raw[7],
        };
      }
    } catch (e) {
      print("❗ 오류 발생: $e");
    }
  }

  //

  //닉네임 중복체크
  Future<dynamic> usernicknamecheck(String nickname) async {
    nicknameCheck.value = 0;
    final res = await http.get(
      Uri.parse("$baseUrl/myinformation/checknickname/$nickname"),
    );
    final data = json.decode(utf8.decode(res.bodyBytes))['data'];
    return nicknameCheck.value = int.parse(data[0]['count'].toString());
  }

  Future<void> fetchUserInfo(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/information/$userId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] == 'OK') {
        user.value = data['data'][0]; // 단일 유저
      }
    }
  }

  Future<void> updateUserInfo(Map<String, dynamic> updateData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update/user/information'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updateData),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] == 'OK') {
        Get.snackbar("완료", "정보가 수정되었습니다");
        Get.back();
      } else {
        Get.snackbar("오류", data['detail'] ?? "알 수 없는 오류");
      }
      Get.defaultDialog(
        title: "수정 완료",
        middleText: "정보가 수정 되엇습니다.",
        actions: [TextButton(onPressed: () => Get.back(), child: Text("확인"))],
      ).then((_) => Get.back());
    }
  }

  // 내정보 업데이트
  // Future<String> updateUserInformation(UserInformation info) async {
  //   final response = await http.put(
  //     Uri.parse("$baseUrl/update/user/information"),
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode(info.toMap()),
  //   );
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(utf8.decode(response.bodyBytes));
  //     if (data['result'] == 'OK') {
  //       return '성공';
  //     } else {
  //       return '실패: ${data['detail']}';
  //     }
  //   } else {
  //     return '서버 오류';
  //   }
  // }






}
