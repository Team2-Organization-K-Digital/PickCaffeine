import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/model/seoyun/purchase_model.dart';
import 'package:pick_caffeine_app/model/seoyun/store_model.dart';
import 'package:http/http.dart' as http;

class Order extends GetxController {

  final index = 0.obs;
  // 백엔드 서버 주소
  final String baseUrl = "http://127.0.0.1:8000/seoyun";

  // 구매 내역 리스트
  final RxList<Purchase> purchase = <Purchase>[].obs;

  // 매장 전체 
  final RxList<Store> store =  <Store>[].obs;

  final RxList storeMap = [].obs;

  final RxList userMap = [].obs;

  // 리뷰 여부 (구매 번호 리스트)
  final RxList<int> review = <int>[].obs;

  // 상세 메뉴 정보 리스트 - 고객
  final RxList detailMenu = [].obs;

  // 상세 메뉴 정보 리스트 - 매장
  final RxList detailMenuStore = [].obs;

  // 메뉴 정보 리스트 - 고객 
  final RxList menu = [].obs;

  // 메뉴 정보 리스트 - 매장
  final RxList menuStore = [].obs;

  // 찜한 매장 리스트
  final RxList myStore = [].obs;


  /// 해당 유저의 구매 내역 불러오기 - 고객
  Future<void> fetchPurchase(String id) async {
    await _fetchPurchaseData('$baseUrl/select/purchase_list/$id');
  }

  /// 매장 사장님 입장에서 구매 내역 불러오기 - 매장
  Future<void> fetchPurchaseStore(String id) async {
    await _fetchPurchaseData('$baseUrl/select/purchase_list_store/$id');
  }

  /// 공통 구매 내역 불러오기 함수 (내부 사용용)
  Future<void> _fetchPurchaseData(String url) async {
    try {
      purchase.clear();
      final res = await http.get(Uri.parse(url));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];

      purchase.value = results.map((data) {
        return Purchase(
          purchase_num: data[0],
          user_id: data[1],
          store_id: data[2],
          purchase_date: data[3],
          purchase_request: data[4] ?? '__', // 요청사항 없을 경우 기본값
          purchase_state: data[5],
        );
      }).toList();
    } catch (e) {
      Get.snackbar('에러', '불러오기 실패');
    }
  }

  /// 매장 전체 정보 (내부 사용용)
  Future<void> fetchStoreData(String id) async {
    try {
      store.clear();
      final res = await http.get(Uri.parse(id));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];

      store.value = results.map((data) {
        return Store(
          store_id: data[0], 
          store_password: data[1], 
          store_name: data[2], 
          store_phone: data[3], 
          store_address: data[4], 
          store_addressdetail: data[5], 
          store_latitude: data[6], 
          store_longitude: data[7], 
          store_content: data[8], 
          store_state: data[9], 
          store_business_num: data[10], 
          store_regular_hoilday: data[11], 
          store_temporary_holiday: data[12], 
          store_business_hour: data[13], 
          store_created_date: data[14]
        );
        }).toList();
    } catch (e) {
      Get.snackbar('에러', '불러오기 실패');
    }
  }

  /// 구매 내역에 해당하는 매장 정보 불러오기 - 고객
  Future<void> fetchStore(String id) async {
  try {
    final res = await http.get(Uri.parse("$baseUrl/select/purchase_list/storeinfo/$id"));
    final data = json.decode(utf8.decode(res.bodyBytes));
    final List results = data['results'];
    storeMap.value = results;
    // print(storeMap);
  } catch (e) {
    Get.snackbar('에러', '매장 정보 불러오기 실패'); 
  }
}

  /// 주문 내역에 해당하는 유저 정보 불러오기 - 매장
  Future<void> fetchUserDetail(String id) async {
  try {
    final res = await http.get(Uri.parse("$baseUrl/select/purchase_list/userinfo/$id"));
    final data = json.decode(utf8.decode(res.bodyBytes));
    final List results = data['results'];
    userMap.value = results;
    // print(userMap);
  } catch (e) {
    Get.snackbar('에러', '유저 정보 불러오기 실패'); 
  }
}

  /// 특정 주문의 상세 메뉴 불러오기 (메뉴 + 옵션 + 가격 + 수량) - 고객
  Future<void> fetchDetailMenu(String id, String num) async {
    try {
      detailMenu.clear();
      final res = await http.get(Uri.parse("$baseUrl/select/detail_menu/$id/$num"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];

      for (var item in results) {
        detailMenu.add({'menu': item[0], 'option': item[1], 'price': item[2], 'quantity': item[3]});
      }
    } catch (e) {
      Get.snackbar('에러', '상세메뉴 불러오기 실패');
    }
  }

  /// 특정 주문의 상세 메뉴 불러오기 (메뉴 + 옵션 + 가격 + 수량) - 매장
  Future<void> fetchDetailMenuStore(String id, String num) async {
    try {
      detailMenuStore.clear();
      final res = await http.get(Uri.parse("$baseUrl/select/detail_menu/store/$id/$num"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];

      for (var item in results) {
        detailMenuStore.add({'menu': item[0], 'option': item[1], 'price': item[2], 'quantity': item[3]});
      }
    } catch (e) {
      Get.snackbar('에러', '상세메뉴 불러오기 실패');
    }
  }

  /// 메뉴 정보만 가져오기 (첫 번째 메뉴만) - 고객
  Future<void> fetchMenu(String id) async {
  try {
    menu.clear(); // menu는 List<Map> 이라고 가정
    final res = await http.get(Uri.parse("$baseUrl/select/menu/$id"));
    final data = json.decode(utf8.decode(res.bodyBytes));
    final List results = data['results'];
    menu.value = results;
  
  } catch (e) {
    Get.snackbar('에러', '메뉴 불러오기 실패');
  }
}

  /// 메뉴 정보만 가져오기 (첫 번째 메뉴만) - 매장
  Future<void> fetchMenuStore(String id) async {
  try {
    menuStore.clear(); // menu는 List<Map> 이라고 가정
    final res = await http.get(Uri.parse("$baseUrl/select/menu/store/$id"));
    final data = json.decode(utf8.decode(res.bodyBytes));
    final List results = data['results'];
    menuStore.value = results;
  
  } catch (e) {
    Get.snackbar('에러', '메뉴 불러오기 실패');
  }
}









  /// 특정 유저가 작성한 리뷰 구매 번호 리스트 불러오기
  Future<void> fetchReview(String id) async {
  try {
    final res = await http.get(Uri.parse("$baseUrl/select/review/$id"));
    final data = json.decode(utf8.decode(res.bodyBytes));
    final List results = data['results'];
    print(results);

    List<int> reviewList = [];
    for (var i in results) {
      reviewList.add(i[0]);
    }

    review.assignAll(reviewList); 

    update();
  } catch (i) {
    Get.snackbar('에러', '리뷰 정보 불러오기 실패');
  }
}

  /// 주문 상태 업데이트 (0: 대기, 1: 진행중, 2: 완료 등)
  Future<String> updateState(int state, String num) async {
    try {
      final uri = Uri.parse('$baseUrl/update/state/$state/$num');
      final res = await http.post(uri);
      final result = json.decode(utf8.decode(res.bodyBytes))['result'];
      print(result);
      return result;
    } catch (e) {
      Get.snackbar('에러', '주문 상태 업데이트 실패');
      return 'FAIL';
    }
  }


  /// 리뷰 저장하기 (텍스트와 이미지 함께 업로드)
  Future<void> saveReview({
    required int purchaseNum,
    required String reviewText,
    File? imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/insert/review');
    final request = http.MultipartRequest('POST', uri);

    // 필드 추가
    request.fields['purchase_num'] = purchaseNum.toString();
    request.fields['review_text'] = reviewText;

    // 이미지 있을 경우 추가
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image_data', imageFile.path),
      );
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['result'] == 'OK') {
          print('✅ 리뷰 저장 성공');

          // Get.snackbar('성공', '리뷰가 저장되었습니다.');
          await fetchReview(purchaseNum.toString());
          update();
        } else {
          print('❌ 서버 에러: ${jsonResponse['message']}');
          Get.snackbar('실패', '서버 에러: ${jsonResponse['message']}');
          throw Exception('서버 에러: ${jsonResponse['message']}');
        }
      } else {
        print('❌ HTTP 에러 ${response.statusCode}: $responseBody');
        Get.snackbar('실패', 'HTTP 에러 ${response.statusCode}');
        throw Exception('HTTP 에러 ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 저장 중 예외 발생: $e');
      Get.snackbar('에러', '리뷰 저장 중 오류가 발생했습니다.');
      rethrow;
    }
  }



  /// 유저가 찜한 매장 리스트 불러오기
  Future<void> fetchMyStore(String id) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/select/my_store/$id"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];

      myStore.clear();
      for (var store in results) {
        myStore.add({'store_id': store['store_id'], 'store_name': store['store_name'], 'image_1': store['image_1'], 'store_like_count': store['store_like_count'], 'review_count': store['review_count']});
      }
    } catch (e) {
      Get.snackbar('에러', '찜한 매장 불러오기 실패');
    }
      print(myStore);
  }

}
