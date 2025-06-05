// 관리자 페이지 신고관리, 문의내역
// 장바구니 드롭다운 옵션 적용
// 메뉴 슬라이더블 품절/재개 컨트롤러

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pick_caffein/model/cart_model.dart';
import 'package:pick_caffein/model/declaration_model.dart';
import 'package:pick_caffein/model/inquiry_model.dart';
import 'package:pick_caffein/model/menu_model.dart';

// 신고 관리 컨트롤러-------------------------------------------------------------
class DeclarationController extends GetxController with GetSingleTickerProviderStateMixin {
  // 기본 설정
  static const String baseUrl = 'http://192.168.50.236:8000'; // 백엔드 서버 주소
  
  // 탭 컨트롤러
  late TabController tabController;
  
  // 반응형 변수들
  var isLoading = false.obs;
  var declarations = <Declaration>[].obs;
  var sanctionedUsers = <Declaration>[].obs;
  var userCount = 0.obs;
  var storeCount = 0.obs;
  var sanctionedUserCount = 0.obs;
  
  // 선택된 신고 및 제재 옵션
  var selectedDeclaration = Rxn<Declaration>();
  var selectedSanctionType = '1차 제재'.obs;
  var selectedSanctionPeriod = '1일'.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this); 
    fetchDeclarations();
    fetchSanctionedUsers();
    fetchStats();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // 통계 정보 가져오기
  Future<void> fetchStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        userCount.value = data['user_count'] ?? 0;
        storeCount.value = data['store_count'] ?? 0;
        sanctionedUserCount.value = data['sanctioned_user_count'] ?? 0;
      } else {
        print('통계 정보 가져오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('통계 정보 가져오기 오류: $e');
    }
  }

  // 신고 목록 가져오기
  Future<void> fetchDeclarations() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('$baseUrl/declarations'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        List<Declaration> declarationList = [];
        
        if (data['declarations'] != null) {
          for (var item in data['declarations']) {
            try {
              declarationList.add(Declaration.fromJson(item));
            } catch (e) {
              return;
            }
          }
        }
        
        declarations.value = declarationList;
      } else {
        Get.snackbar(
          '오류',
          '신고 목록을 가져오는데 실패했습니다.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        '네트워크 오류',
        '서버에 연결할 수 없습니다.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 제재 유저 목록 가져오기
  Future<void> fetchSanctionedUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sanctioned_users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        List<Declaration> sanctionedList = [];
        
        if (data['sanctioned_users'] != null) {
          for (var item in data['sanctioned_users']) {
            try {
              sanctionedList.add(Declaration.fromJson(item));
            } catch (e) {
              return;
            }
          }
        }
        
        sanctionedUsers.value = sanctionedList;
      }
    } catch (e) {
      return;
    }
  }

  // 신고 수정 (제재 처리)
  Future<void> updateDeclaration({
    required int reviewNum,
    required String userId,
    required String declarationDate,
    required String declarationContent,
    required String declarationState,
    String? sanctionContent,
    String? sanctionDate,
  }) async {
    try {
      isLoading.value = true;
      
      final response = await http.put(
        Uri.parse('$baseUrl/declarations/$reviewNum'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'userId': userId,
          'declarationDate': declarationDate,
          'declarationContent': declarationContent,
          'declarationState': declarationState,
          'sanctionContent': sanctionContent ?? '',
          'sanctionDate': sanctionDate ?? '',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['status'] == 'success') {
          Get.snackbar(
            '성공',
            '제재 처리가 완료되었습니다.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          await Future.wait([
            fetchDeclarations(),
            fetchSanctionedUsers(),
            fetchStats(),
          ]);
        } else {
          throw Exception(data['result'] ?? '알 수 없는 오류');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        '오류',
        '제재 처리 중 오류가 발생했습니다',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 제재 해제
  Future<void> releaseSanction(String userId) async {
  try {
    isLoading.value = true;
    
    final response = await http.put(
      Uri.parse('$baseUrl/release_sanction/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['status'] == 'success') {
        // 로컬 데이터에서 즉시 제거 (UI에서 바로 사라지게 함)
        declarations.removeWhere((d) => d.userId == userId && d.sanctionContent != null);
        declarations.refresh();
        
        Get.snackbar(
          '성공',
          '제재가 해제되었습니다.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        await Future.wait([
          fetchDeclarations(),
          fetchSanctionedUsers(),
          fetchStats(),
        ]);
      }
    }
  } catch (e) {
    Get.snackbar(
      '오류',
      '제재 해제 중 오류가 발생했습니다.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isLoading.value = false;
  }
}

  // 신고 삭제
  Future<void> deleteDeclaration(int reviewNum) async {
    try {
      isLoading.value = true;
      
      final response = await http.delete(
        Uri.parse('$baseUrl/declarations_delete/$reviewNum'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['status'] == 'success') {
          Get.snackbar(
            '성공',
            '신고가 삭제되었습니다.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          await fetchDeclarations(); // 목록 새로고침
        } else {
          throw Exception(data['result'] ?? '알 수 없는 오류');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        '오류',
        '신고 삭제 중 오류가 발생했습니다.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 신고 등록
  Future<void> createDeclaration({
    required String userId,
    required int reviewNum,
    required String declarationContent,
    required String declarationDate,
    required String declarationState,
    String? sanctionContent,
    String? sanctionDate,
  }) async {
    try {
      isLoading.value = true;
      
      final response = await http.post(
        Uri.parse('$baseUrl/declaration_insert'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'userId': userId,
          'reviewNum': reviewNum.toString(),
          'declarationContent': declarationContent,
          'declarationDate': declarationDate,
          'declarationState': declarationState,
          'sanctionContent': sanctionContent ?? '',
          'sanctionDate': sanctionDate ?? '',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['status'] == 'success') {
          Get.snackbar(
            '성공',
            '신고가 등록되었습니다.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          await fetchDeclarations(); // 목록 새로고침
        } else {
          throw Exception(data['result'] ?? '알 수 없는 오류');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        '오류',
        '신고 등록 중 오류가 발생했습니다.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 제재 옵션 설정
  void setSanctionType(String type) {
    selectedSanctionType.value = type;
  }

  void setSanctionPeriod(String period) {
    selectedSanctionPeriod.value = period;
  }

  // 제재 내용 생성
  String generateSanctionContent() {
    return '${selectedSanctionType.value} - ${selectedSanctionPeriod.value} 제재';
  }

  // 데이터 새로고침
  Future<void> refreshData() async {
    await Future.wait([
      fetchDeclarations(),
      fetchSanctionedUsers(),
      fetchStats(),
    ]);
  }

  // 상태별 색상 반환
  Color getStatusColor(String status) {
    switch (status) {
      case '접수완료':
      case '접수':
        return Colors.blue;
      case '처리중':
        return Colors.orange;
      case '완료':
      case '처리완료':
        return Colors.green;
      case '제재중':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}



// --------문의 하기 컨트롤러 -----------------------------------------------------
class InquiryController extends GetxController {
  var inquiryList = <Inquiry>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  RxnInt selectedInquiryNum = RxnInt();
  
  final String baseUrl = 'http://192.168.50.236:8000';

  @override
  void onInit() {
    super.onInit();
    fetchInquiries();
  }

  // 전체 문의 내역 가져오기
  void fetchInquiries() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      var url = Uri.parse('$baseUrl/inquiries');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        List data = json.decode(utf8.decode(response.bodyBytes))["inquiries"];
        inquiryList.value = data.map((e) => Inquiry.fromJson(e)).toList();
      } else {
        errorMessage.value = '서버 오류: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = '데이터를 불러오는데 실패했습니다.\n${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // 개별 문의 조회
  Future<Inquiry?> getInquiry(int inquiryNum) async {
    try {
      var url = Uri.parse('$baseUrl/inquiries_indi/$inquiryNum');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        if (data.containsKey('결과')) {
          return Inquiry.fromJson(data['결과']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 문의 등록
  Future<bool> insertInquiry({
    required String userId,
    required String inquiryDate,
    required String inquiryContent,
    required String inquiryState,
    String? response,
    String? responseDate,
  }) async {
    try {
      var url = Uri.parse('$baseUrl/inquiry_insert');
      var httpResponse = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'userId': userId,
          'inquiryDate': inquiryDate,
          'inquiryContent': inquiryContent,
          'inquiryState': inquiryState,
          if (response != null) 'response': response,
          if (responseDate != null) 'responseDate': responseDate,
        },
      );

      if (httpResponse.statusCode == 200) {
        var result = json.decode(httpResponse.body);
        if (result['result'] == '문의 등록 성공') {
          fetchInquiries(); // 목록 새로고침
          return true;
        }
      }
      return false;
    } catch (e) {
      errorMessage.value = '문의 등록 실패: ${e.toString()}';
      return false;
    }
  }

  // 문의 수정
  Future<bool> updateInquiry({
    required int inquiryNum,
    required String userId,
    required String inquiryDate,
    required String inquiryContent,
    required String inquiryState,
    String? response,
    String? responseDate,
  }) async {
    try {
      var url = Uri.parse('$baseUrl/inquiry/$inquiryNum');
      var httpResponse = await http.put(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'userId': userId,
          'inquiryDate': inquiryDate,
          'inquiryContent': inquiryContent,
          'inquiryState': inquiryState,
          if (response != null) 'response': response,
          if (responseDate != null) 'responseDate': responseDate,
        },
      );

      if (httpResponse.statusCode == 200) {
        var result = json.decode(httpResponse.body);
        if (result['result'] == '문의 수정 완료') {
          fetchInquiries(); 
          return true;
        }
      }
      return false;
    } catch (e) {
      errorMessage.value = '문의 수정 실패: ${e.toString()}';
      return false;
    }
  }

  // 문의 답변 등록 
  Future<void> updateResponse(int inquiryNum, String responseText, DateTime? responseDate) async {
    int index = inquiryList.indexWhere((i) => i.inquiryNum == inquiryNum);
    if (index != -1) {
      final old = inquiryList[index];
      
      // 서버에 업데이트 요청
      bool success = await updateInquiry(
        inquiryNum: inquiryNum,
        userId: old.userId,
        inquiryDate: old.inquiryDate.toIso8601String().split('T')[0],
        inquiryContent: old.inquiryContent,
        inquiryState: '답변완료',
        response: responseText,
        responseDate: responseDate?.toIso8601String().split('T')[0],
      );

      if (success) {
        Get.snackbar('성공', '답변이 등록되었습니다.');
      } else {
        Get.snackbar('오류', '답변 등록에 실패했습니다.');
      }
    }
  }

  // 문의 삭제
  Future<bool> deleteInquiry(int inquiryNum) async {
    try {
      var url = Uri.parse('$baseUrl/inquirise/$inquiryNum'); // 백엔드 오타 그대로 사용
      var response = await http.delete(url);

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        if (result['result'] == 'OK') {
          inquiryList.removeWhere((i) => i.inquiryNum == inquiryNum);
          return true;
        }
      }
      return false;
    } catch (e) {
      errorMessage.value = '삭제 실패: ${e.toString()}';
      return false;
    }
  }

  // 선택된 문의 객체 가져오기
  Inquiry? get selectedInquiry {
    return inquiryList.firstWhereOrNull((i) => i.inquiryNum == selectedInquiryNum.value);
  }
}



// ------------구매 장바구니 드롭다운 옵션 컨트롤러 ----------------------------------
class RequestController extends GetxController {
  final List<String> requestOptions = [
    '연하게 해주세요',
    '얼음 많이 넣어주세요',
    '직접 입력',
  ];

  final selectedRequest = ''.obs;
  final tempSelectedRequest = ''.obs;
  final directInputText = ''.obs;
  final cartItems = <CartItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  bool get isDirectInput => tempSelectedRequest.value == '직접 입력';

  void setTempSelected(String value) {
    tempSelectedRequest.value = value;
    if (value != '직접 입력') {
      directInputText.value = '';
    }
  }

  void setInputText(String value) {
    directInputText.value = value;
  }

  void applySelection() {
    if (isDirectInput && directInputText.value.trim().isNotEmpty) {
      selectedRequest.value = directInputText.value.trim();
    } else if (!isDirectInput && tempSelectedRequest.value.isNotEmpty) {
      selectedRequest.value = tempSelectedRequest.value;
    }
    successMessage.value = '요청사항이 적용되었습니다!';
    Future.delayed(Duration(seconds: 2), () {
      successMessage.value = '';
    });
  }

  // 장바구니에 아이템 추가
  void addToCart({
    required int menuNum,
    required String menuName,
    required int menuPrice,
    required int quantity,
  }) {
    final options = selectedRequest.value.isEmpty ? '없음' : selectedRequest.value;
    final totalPrice = menuPrice * quantity;
    
    final cartItem = CartItem(
      menuNum: menuNum,
      menuName: menuName,
      menuPrice: menuPrice,
      selectedQuantity: quantity,
      selectedOptions: options,
      totalPrice: totalPrice,
    );
    
    cartItems.add(cartItem);
    successMessage.value = '장바구니에 추가되었습니다!';
    Future.delayed(Duration(seconds: 2), () {
      successMessage.value = '';
    });
  }

  // 장바구니 아이템 삭제
  void removeFromCart(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
    }
  }

  // 총 가격 계산
  int get totalAmount {
    return cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  // 데이터베이스에 주문 저장
  Future<void> saveOrderToDatabase() async {
    if (cartItems.isEmpty) {
      errorMessage.value = '장바구니가 비어있습니다.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 구매 번호 생성 (현재 시간 기반)
      final purchaseNum = DateTime.now().millisecondsSinceEpoch;

      // 각 장바구니 아이템을 데이터베이스에 저장
      for (CartItem item in cartItems) {
        final url = Uri.parse('http://192.168.50.236:8000/order/select_menu');
        
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'menuNum': item.menuNum.toString(),
            'selectedOptions': json.encode({
              'request': item.selectedOptions,
              'menuName': item.menuName,
            }),
            'selectedQuantity': item.selectedQuantity.toString(),
            'totalPrice': item.totalPrice.toString(),
            'purchaseNum': purchaseNum.toString(),
          },
        );

        if (response.statusCode != 200) {
          throw Exception('서버 오류: ${response.statusCode}');
        }
      }

      // 성공 시 장바구니 비우기
      cartItems.clear();
      selectedRequest.value = '';
      tempSelectedRequest.value = '';
      directInputText.value = '';
      
      successMessage.value = '주문이 성공적으로 저장되었습니다!';
      
      // 성공 다이얼로그 표시
      Get.dialog(
        AlertDialog(
          title: Text('주문 완료'),
          content: Text('주문번호: $purchaseNum\n주문이 성공적으로 접수되었습니다.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('확인'),
            ),
          ],
        ),
      );

    } catch (e) {
      errorMessage.value = '주문 저장 중 오류가 발생했습니다: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // 에러 메시지 초기화
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }
}

// ----------메뉴 슬라이더블 품절/재개 화면 -----------------------------------------
class MenuController extends GetxController {
  final RxList<MenuItem> menuItems = <MenuItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final String baseUrl = 'http://192.168.50.236:8000';

  @override
  void onInit() {
    super.onInit();
    loadMenuItems();
  }

  // 메뉴 아이템 로드
  Future<void> loadMenuItems() async {
    try {
      isLoading.value = true;
      // 로딩 시뮬레이션
      await Future.delayed(Duration(milliseconds: 500));
      
      menuItems.clear();
      _loadDummyData();
    } catch (e) {
      return;
    } finally {
      isLoading.value = false;
    }
  }

  // 품절/판매재개 토글
  Future<void> toggleAvailability(int menuNum) async {
    try {
      final itemIndex = menuItems.indexWhere((item) => item.menuNum == menuNum);
      if (itemIndex == -1) return;

      final item = menuItems[itemIndex];
      final newStatus = item.menuState == '판매중' ? '품절' : '판매중';
      
      // 로컬 상태 업데이트
      item.menuState = newStatus;
      menuItems[itemIndex] = item;
      menuItems.refresh();
      
      Get.snackbar(
        '상태 변경',
        '${item.menuName}이 ${newStatus} 상태로 변경되었습니다.',
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('오류', '상태 변경에 실패했습니다.');
    }
  }

  // 상품 목록 삭제 
  Future<bool> deleteMenu(int menuNum) async {
    try {
      isDeleting.value = true;
      final uri = Uri.parse('$baseUrl/delete_menu/$menuNum');
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        if (result['삭제결과'] == '삭제함') {
          menuItems.removeWhere((item) => item.menuNum == menuNum);

          Get.snackbar(
            '삭제완료', '메뉴가 삭제 되었습니다.',
            backgroundColor: Colors.amber,
            colorText: Colors.white,
            duration: Duration(seconds: 2)
          );

          return true;
        }
      }
      throw Exception('서버 오류: ${response.statusCode}');
    } catch (e) {
      Get.snackbar(
        '삭제실패', '메뉴 삭제를 실패 했습니다.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 2)
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  // 더미 데이터 (테스트용)
  void _loadDummyData() {
    menuItems.addAll([
      MenuItem(
        menuNum: 1,
        categoryNum: 1,
        menuName: '아메리카노',
        menuContent: '깔끔하고 진한 원두의 맛',
        menuPrice: 4000,
        menuImage: 'americano.jpg',
        menuState: '판매중',
      ),
      MenuItem(
        menuNum: 2,
        categoryNum: 1,
        menuName: '카페라떼',
        menuContent: '부드러운 우유와 에스프레소의 조화',
        menuPrice: 4500,
        menuImage: 'latte.jpg',
        menuState: '판매중',
      ),
      MenuItem(
        menuNum: 3,
        categoryNum: 1,
        menuName: '카라멜 마키아토',
        menuContent: '달콤한 카라멜과 에스프레소',
        menuPrice: 5500,
        menuImage: 'caramel_macchiato.jpg',
        menuState: '판매중',
      ),
    ]);
  }
}
