import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class VmReview extends GetxController {
  final baseUrl = "http://127.0.0.1:8000/seong";


  final myreviews = <Map<String, dynamic>>[].obs;
  final error = ''.obs;
  final box = GetStorage();
  final isLoading = false.obs;
  final review = <String, dynamic>{}.obs;
  final userReviews = <Map<String, dynamic>>[].obs;


Future<void> userreviews() async {
  final userId = box.read('loginId');
  try {
    final res = await http.get(Uri.parse("$baseUrl/user/reviews/$userId"));
    final decoded = json.decode(utf8.decode(res.bodyBytes));
    print("🔍 서버 응답: $decoded");

  if (decoded['result'] == 'OK') {
userReviews.value = List<Map<String, dynamic>>.from(decoded['data'].map((e) => {
  'review_num': e['review_num'],
  'review_content': e['review_content'],
  'review_image': e['review_image'],
  'review_date': e['review_date'],
  'review_state': e['review_state'],
  'store_id': e['store_id'],
      'user_nickname': e['user_nickname'], 
    'user_image': e['user_image'],       
}));
    }
  } catch (e) {
    error.value = "유저 리뷰 로딩 실패: $e";
  }
}


Future<void> storereviews(String storeId) async {
  try {
    isLoading.value = true;
    final res = await http.get(Uri.parse("$baseUrl/stores/reviews?store_id=$storeId"));
    final decoded = json.decode(utf8.decode(res.bodyBytes));

    if (decoded['result'] == 'OK') {
      myreviews.value = List<Map<String, dynamic>>.from(decoded['data']);
    } else {
      error.value = "리뷰 로딩 실패: 서버 응답 오류";
    }
  } catch (e) {
    error.value = "리뷰 로딩 실패: $e";
  } finally {
    isLoading.value = false;
  }
}


}
