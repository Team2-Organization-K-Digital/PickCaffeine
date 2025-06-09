import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/model/purchase.dart';
import 'package:http/http.dart' as http;

class Order extends GetxController {
  final index = 0.obs;
  // 백엔드 서버 주소
  final String baseUrl = "http://127.0.0.1:8000";

  // 구매 내역 리스트
  final RxList<Purchase> purchase = <Purchase>[].obs;

  // 리뷰 여부 (구매 번호 리스트)
  final RxList<int> review = <int>[].obs;

  // 상세 메뉴 정보 리스트
  final RxList detailMenu = [].obs;

  // 메뉴 정보 리스트
  final RxList menu = [].obs;

  // 찜한 매장 리스트
  final RxList myStore = [].obs;

  // 매장 이름
  var storeName = ''.obs;

  // 매장 전화번호
  var storePhone = ''.obs;

  // 유저 닉네임
  var userNickname = ''.obs;

  // 유저 전화번호
  var userPhone = ''.obs;

  // 매장 찜 수
  var storeCount = 0.obs;

  // 매장 후기 수
  var reviewCount = 0.obs;

  /// 해당 유저의 구매 내역 불러오기
  Future<void> fetchPurchase(String id) async {
    await _fetchPurchaseData('$baseUrl/select/purchase_list/$id');
  }

  /// 매장 사장님 입장에서 구매 내역 불러오기
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

  /// 구매 내역에 해당하는 매장 정보 불러오기
  Future<void> fetchStore(String id, String store) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/select/purchase_list/$id/$store"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];

      if (results.length >= 1) {
        storeName.value = results[0][0];
        storePhone.value = results[0][1];
      }
    } catch (e) {
      Get.snackbar('에러', '매장 정보 불러오기 실패');
    }
  }

  /// 특정 주문의 상세 메뉴 불러오기 (메뉴 + 옵션 + 가격 + 수량)
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

  /// 메뉴 정보만 가져오기 (첫 번째 메뉴만)
  Future<void> fetchMenu(String id, String num) async {
  try {
    menu.clear(); // menu는 List<Map> 이라고 가정
    final res = await http.get(Uri.parse("$baseUrl/select/menu/$id/$num"));
    final data = json.decode(utf8.decode(res.bodyBytes));
    final List results = data['results'];

    if (results.isNotEmpty) {
      // 첫 번째 메뉴 이름
      String firstMenuName = results[0][0];

      // 총 결제 금액 (모든 행에 동일)
      int totalPrice = results[0][2];

      // 필요한 정보만 저장
      menu.add({
        'name': firstMenuName,
        'total': totalPrice
      });
    }
  } catch (e) {
    Get.snackbar('에러', '메뉴 불러오기 실패');
  }
}


  /// 특정 유저가 작성한 리뷰 구매 번호 리스트 불러오기
  // Future<void> fetchReview(String id) async {
  // try {
  //   review.clear();
  //   final res = await http.get(Uri.parse("$baseUrl/select/review/$id"));
  //   final data = json.decode(utf8.decode(res.bodyBytes));
  //   final List results = data['results'];
  //   print(results);
  //   List<int> reviewList = [];
  //   for (var i in results) {
  //     reviewList.add(i[0]);
  //   }
  //   review.value = reviewList;
  //   update();
  // } catch (i) {
  //   Get.snackbar('에러', '리뷰 정보 불러오기 실패');
  // }
  // }
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

  /// 구매한 유저의 정보(닉네임, 전화번호) 불러오기
  Future<void> fetchUser(String num) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/select/purchase_store/$num"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];

      if (results.length >= 1) {
        userNickname.value = results[0][0];
        userPhone.value = results[0][1];
      }
    } catch (e) {
      Get.snackbar('에러', '고객 정보 불러오기 실패');
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
        myStore.add({'store_name': store['store_name'], 'image_1': store['image_1']});
      }
    } catch (e) {
      Get.snackbar('에러', '찜한 매장 불러오기 실패');
    }
      print(myStore);
  }

  /// 해당 매장 찜 수 불러오기
  Future<void> fetchMyStoreCount(String id) async {
      final res = await http.get(Uri.parse("$baseUrl/select/my_store_count/$id"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];
      print(results);

      storeCount.value = results[0][0];

  }

  /// 해당 매장 후기 수 불러오기
  Future<void> fetchReviewCount(String id) async {
      final res = await http.get(Uri.parse("$baseUrl/select/review_count/$id"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];

      reviewCount.value = results[0][0];

  }

}
