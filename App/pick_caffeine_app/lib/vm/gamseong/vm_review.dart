import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class VmReview extends GetxController {
  final baseUrl = "http://127.0.0.1:8000/seong";


  final myreviews = <Map<String, dynamic>>[].obs;
  final error = ''.obs;
  final isLoading = false.obs;


  Future<void> informationreview(String userId) async {
    if (userId.isEmpty) return;

    Map<String, dynamic>? map;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/informationreview?user_id=$userId'),
      );
      map = json.decode(utf8.decode(response.bodyBytes));
    } catch (e) {
      error.value = e.toString();
    } finally {
      if (map != null && map['result'] == 'OK') {
        myreviews.value = List<Map<String, dynamic>>.from(map['data']);
      }
    }
  }
}
