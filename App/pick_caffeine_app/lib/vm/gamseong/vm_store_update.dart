import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pick_caffeine_app/model/gamseong/store_home.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_create_store.dart';

class Vmgamseong extends VmCreateStore {
  var error = ''.obs;
  var isLoading = false.obs;
  var stores = <StoreHome>[].obs;
  var myreviews = <Map<String, dynamic>>[].obs; 

  


  Future<void> createstorelist() async {
    isLoading.value = true;
    try {
      final res = await http.get(Uri.parse('$baseUrl/selectstore'));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final result = (data['results'] as List)
        .map((d) {
          return StoreHome.fromMap(d);
        })
        .toList();
      stores.value = result;
    for (var store in stores) {
    }
  } catch (e) {
    error.value = e.toString();
  } finally {
    isLoading.value = false;
  }
  }

//스토어 업데이트를 내 매장에 업데이트.

Future<void> updatestore(Map<String, dynamic> updatestore) async {
  final storeId = updatestore['store_id'];
  final response = await http.put(
    Uri.parse('$baseUrl/update/store/updatestore/$storeId'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(updatestore),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['result'] == 'ok') {
      Get.defaultDialog(
        title: "수정 완료",
        middleText: "정보가 수정되었습니다.",
        confirm: TextButton(
          onPressed: () {
            Get.back(); // 닫기
            Get.back(); // 페이지 뒤로
          },
          child: Text("확인"),
        ),
      );
    } else {
      Get.snackbar("오류", data['detail'] ?? "알 수 없는 오류");
    }
  } else {
    Get.snackbar("오류", "서버 오류가 발생했습니다. (${response.statusCode})");
  }
}


Future<void> updatestoreImage(String storeId, String imageBase64) async {
  final response = await http.put(
    Uri.parse('$baseUrl/update/storeImage/$storeId'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "store_image": imageBase64,
    }),
  );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] == 'ok') {
        Get.snackbar("완료", "이미지가 업데이트되었습니다");
      } else {
        Get.snackbar("오류", data['detail'] ?? "알 수 없는 오류");
      }
    } else {
      Get.snackbar("서버 오류", "이미지 상태 코드: ${response.statusCode}");
    }
  }

  
}











