import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pick_caffeine_app/model/gamseong/store_home.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_create_store.dart';

class Vmgamseong extends VmCreateStore {
  var error = ''.obs;
  var isLoading = false.obs;
  var stores = <StoreHome>[].obs;
var user = <String, dynamic>{}.obs;   
var myreviews = <Map<String, dynamic>>[].obs; 

 Future<void> getInformation() async {
  try {
    final res = await http.get(Uri.parse('$baseUrl/user/information'));
    final data = json.decode(utf8.decode(res.bodyBytes));

    if (data['data'] != null && data['data'].isNotEmpty) {
      user.value = data['data'][0];
    } else {
      user.value = {}; // 💥 null 또는 빈 리스트일 때 안전 처리
    }
  } catch (e) {
    error.value = '유저 정보 오류: $e';
  }
}
Future<void> getMyReviews(String userId) async {
  try {
    final res = await http.get(Uri.parse('$baseUrl/users/informationreview?user_id=$userId'));
    final data = json.decode(utf8.decode(res.bodyBytes));

    if (data['data'] != null && data['data'] is List) {
      myreviews.value = List<Map<String, dynamic>>.from(data['data']);
      print('👉 getMyReviews 응답 데이터: ${data['data']}');
    } else {
      myreviews.value = []; // 💥 null일 때 예외 방지
    }
  } catch (e) {
    error.value = '리뷰 정보 오류: $e';
    
  }
}


  
  
  


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


Future<String> updateStorelist(StoreHome updated) async {
  try {
    final url = Uri.parse('$baseUrl/updatestore'); 
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updated.toMap()), 
    );

    final decoded = json.decode(utf8.decode(response.bodyBytes));
    final result = decoded['result'] ?? 'Error: 서버 응답에 result 없음';

    await createstorelist(); 
    return result;
  } catch (e) {
    return 'Error: $e';
  }
}




}




