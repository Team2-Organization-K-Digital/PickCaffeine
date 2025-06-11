import 'dart:convert';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/model/gamseong/create_store.dart';
import 'package:http/http.dart' as http;
import 'package:pick_caffeine_app/model/gamseong/store_home.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_gps_handller.dart';

class VmCreateStore extends VmGpsHandller{
  final baseUrl = "http://127.0.0.1:8000/seong";
  final RxBool storeidChecked = false.obs;
  Rxn<StoreHome> currentStore = Rxn<StoreHome>();
  void setStore(StoreHome storehome){
    currentStore.value = storehome;
  }
  StoreHome? get getStorehome => currentStore.value;



Future<String> createStore(CreateStore store) async { // db에스토어넣기
  final url = Uri.parse("$baseUrl/createstore");
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(store.toMap()),
    );

    final decoded = json.decode(utf8.decode(response.bodyBytes));
    final result = decoded['result'];
    if (result is String) {
      return result;
    } else {
      return "Error: result is not string";
    }
  } catch (e) {
    
      return "Error: $e";
  }
}

  Future<bool> checkstoreid(String id)async{// 아이디중복체크
    final url = Uri.parse("$baseUrl/checkid/$id");
    final response = await http.get(url);
    final result = jsonDecode(utf8.decode(response.bodyBytes))['exists'];
    storeidChecked.value = !(result == false);
    return result == true;
  }

  Future<void> fetchStoreById(String id) async {
  final url = Uri.parse("$baseUrl/getstore/$id");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    currentStore.value = StoreHome.fromMap(decoded);
  } else {
    Get.snackbar("오류", "매장 정보를 불러오지 못했습니다");
  }
}

}
//회원가입 매장인데 이내용을 db에 추가 