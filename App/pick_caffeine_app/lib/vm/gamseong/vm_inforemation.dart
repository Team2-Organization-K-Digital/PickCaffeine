// import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';

// class VmReview extends VmStoreUpdate{
  
  
// }
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class VmInformation extends GetxController{

final baseUrl = "http://127.0.0.1:8000/seong";
var user = {}.obs;            
  var myreviews = [].obs;      
  var error = ''.obs;
  var isLoading = false.obs;


// 내정보에 리뷰 불러오기
Future<void> informationreview(String userId)async{
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
      myreviews.value = map['data'];
    }
  }
}

// 내정보확인 
  Future<void> information(String userId)async{
    Map<String, dynamic>? data;
try {
    final response = await http.get(
    Uri.parse('$baseUrl/users/information?user_id=$userId'),
    );
    data = json.decode(utf8.decode(response.bodyBytes));
  } catch (e) {
    error.value = e.toString();
  } finally {
    if (data != null && data['result'] == 'OK') {
      myreviews.value = data['data'];
    }
  }
  }

}
  
