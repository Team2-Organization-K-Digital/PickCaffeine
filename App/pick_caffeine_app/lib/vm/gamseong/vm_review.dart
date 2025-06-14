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

  Future<void> userreviews() async {
    final userId = box.read('loginId'); // 저장된 사용자 ID
    try {
      final res = await http.get(Uri.parse("$baseUrl/user/reviews/$userId"));
      final decoded = json.decode(utf8.decode(res.bodyBytes));
      print("🔍 서버 응답: $decoded");

      if (decoded['result'] == 'OK' && decoded['data'].isNotEmpty) {
        final raw = decoded['data'][0]; // 첫 번째 리뷰만 사용
        review.value = {
          'review_num': raw[0],
          'review_content': raw[1],
          'review_image': raw[2],
          'review_date': raw[3],
          'review_state': raw[4],
          'store_id': raw[5],
        };
      }
    } catch (e) {
      print("❗ 오류 발생: $e");
    }
  }
}
