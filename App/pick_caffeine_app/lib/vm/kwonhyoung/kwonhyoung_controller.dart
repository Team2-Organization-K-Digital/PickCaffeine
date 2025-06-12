import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pick_caffeine_app/model/kwonhyoung/declaration_model.dart';
import 'package:pick_caffeine_app/model/kwonhyoung/inquiry_model.dart';

// 개선된 버전(25.06.11.) - 수정 버전2

// =====================================================================================
// 신고 및 매장 관리 컨트롤러 (Declaration과 Store 관리 통합) - 수정
// =====================================================================================
class DeclarationController extends GetxController with GetSingleTickerProviderStateMixin {
  // =================== 기본 설정 ===================
  static String baseUrl = 'http://192.168.50.236:8000/kwonhyoung'; // 백엔드 서버 주소
  
  // =================== UI 컨트롤러 ===================
  late TabController tabController; // 탭바 컨트롤러 (매장리스트/매장리뷰/제재내역)
  
  // =================== 반응형 변수들 ===================
  var isLoading = false.obs; // 로딩 상태
  var declarations = <Declaration>[].obs; // 신고/리뷰 목록
  var sanctionedUsers = <Declaration>[].obs; // 제재된 유저 목록
  var stores = <Map<String, dynamic>>[].obs; // 매장 목록
  var reviews = <Map<String, dynamic>>[].obs; // 리뷰 목록
  
  // 통계 정보
  var userCount = 0.obs; // 전체 유저 수
  var storeCount = 0.obs; // 전체 매장 수
  var reviewCount = 0.obs; // 전체 리뷰 수
  var sanctionedUserCount = 0.obs; // 제재된 유저 수
  
  // 매장 및 리뷰 선택 관련 (새로 추가)
  var selectedStoreId = ''.obs; // 선택된 매장 ID
  var selectedReviewNums = <int>[].obs; // 선택된 리뷰 번호들
  
  // 제재 관련
  var selectedDeclaration = Rxn<Declaration>(); // 선택된 신고/리뷰
  var selectedSanctionType = '전체'.obs; // 선택된 제재 유형
  var selectedSanctionPeriod = '1일'.obs; // 선택된 제재 기간

  // =================== Getter 메서드들 ===================
  
  /// 선택된 매장의 리뷰들만 필터링해서 반환
  List<Map<String, dynamic>> get filteredReviews {
    if (selectedStoreId.value.isEmpty) {
      return reviews; // 매장이 선택되지 않으면 전체 리뷰 반환
    }
    return reviews.where((review) => 
      review['store_id']?.toString() == selectedStoreId.value
    ).toList();
  }

  /// 선택된 리뷰들을 반환 (체크박스로 선택된 리뷰들)
  List<Map<String, dynamic>> get selectedReviews {
    return filteredReviews.where((review) => 
      selectedReviewNums.contains(review['review_num'])
    ).toList();
  }

  /// 제재 유형에 따라 필터링된 제재 내역을 반환
  List<Declaration> get filteredSanctionedDeclarations {
    final sanctionedDeclarations = declarations
        .where((d) => d.sanctionContent != null && d.sanctionContent!.isNotEmpty)
        .toList();
    
    if (selectedSanctionType.value == '전체') {
      return sanctionedDeclarations;
    }
    
    return sanctionedDeclarations.where((d) {
      final sanctionContent = d.sanctionContent?.toLowerCase() ?? '';
      if (selectedSanctionType.value == '1차 제재') {
        return sanctionContent.contains('1차');
      } else if (selectedSanctionType.value == '2차 제재') {
        return sanctionContent.contains('2차');
      }
      return true;
    }).toList();
  }

  // =================== 생명주기 메서드 ===================
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this); // 3개 탭 설정
    _initializeData(); // 초기 데이터 로드
  }

  @override
  void onClose() {
    tabController.dispose(); // 탭 컨트롤러 메모리 해제
    super.onClose();
  }

  // =================== 초기화 메서드 ===================
  /// 앱 시작 시 필요한 모든 데이터를 로드합니다
  void _initializeData() {
    fetchStores(); // 매장 목록 가져오기
    fetchReviews(); // 리뷰 목록 가져오기
    fetchDeclarations(); // 신고/리뷰 목록 가져오기
    fetchSanctionedUsers(); // 제재된 유저 목록 가져오기
    fetchStats(); // 통계 정보 가져오기
  }

  // =================== 매장 및 리뷰 선택 관리 메서드들 ===================
  
  /// 매장을 선택하고 해당 매장의 리뷰를 필터링합니다
  /// @param storeId 선택할 매장 ID
  void selectStore(String storeId) {
    selectedStoreId.value = storeId;
    // 매장 변경 시 선택된 리뷰들 초기화
    selectedReviewNums.clear();
    // 해당 매장의 리뷰 새로고침
    fetchStoreReviews(storeId);
  }

  /// 리뷰 선택/해제를 토글합니다
  /// @param reviewNum 선택/해제할 리뷰 번호
  void toggleReviewSelection(int reviewNum) {
    if (selectedReviewNums.contains(reviewNum)) {
      selectedReviewNums.remove(reviewNum);
    } else {
      selectedReviewNums.add(reviewNum);
    }
  }

  /// 모든 리뷰 선택을 해제합니다
  void clearAllReviewSelections() {
    selectedReviewNums.clear();
  }

  /// 선택된 모든 리뷰들에 대해 제재를 처리합니다 (제재 사유와 레벨 포함)
  /// @param sanctionLevel 제재 단계 ('1차 제재', '2차 제재')
  /// @param sanctionReason 제재 사유
  Future<void> sanctionSelectedReviewsWithReason({
    required String sanctionLevel,
    required String sanctionReason,
  }) async {
    final selectedList = selectedReviews;
    
    if (selectedList.isEmpty) {
      Get.snackbar(
        '알림',
        '제재할 리뷰를 선택해주세요.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
      return;
    }

    try {
      isLoading.value = true;
      
      // 제재 내용 생성
      final sanctionContent = '$sanctionLevel: $sanctionReason';
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      
      // 성공/실패 추적
      List<String> successList = [];
      List<String> failedList = [];
      List<Declaration> newDeclarations = [];
      
      // 각 리뷰에 대해 순차적으로 제재 처리
      for (int i = 0; i < selectedList.length; i++) {
        final review = selectedList[i];
        final userId = review['user_id']?.toString() ?? '';
        final reviewNum = review['review_num'] ?? 0;
        
        try {
          // 서버에 제재 요청
          final success = await _processSingleSanction(
            userId: userId,
            reviewNum: reviewNum,
            sanctionReason: sanctionReason,
            sanctionContent: sanctionContent,
            today: today,
          );
          
          if (success) {
            // 서버 처리 성공 시에만 로컬 데이터 생성
            final newDeclaration = Declaration(
              userId: userId,
              reviewNum: reviewNum,
              declarationDate: DateTime.parse(today),
              declarationContent: sanctionReason,
              declarationState: '처리완료',
              sanctionContent: sanctionContent,
              sanctionDate: DateTime.parse(today),
              userNickname: review['user_nickname']?.toString() ?? '알수없음',
              userImage: review['user_image']?.toString(),
              userState: '제재중',
            );
            
            newDeclarations.add(newDeclaration);
            successList.add(userId);
            print('✅ 제재 성공 - $userId');
          } else {
            failedList.add(userId);
            print('❌ 제재 실패 - $userId');
          }
          
        } catch (e) {
          failedList.add(userId);
          print('❌ 제재 실패 - $userId: $e');
        }
      }
      
      // 제재 처리 후 선택 해제
      clearAllReviewSelections();
      
      // 성공한 Declaration들을 로컬에 반영
      if (newDeclarations.isNotEmpty) {
        for (Declaration newDecl in newDeclarations) {
          // 중복 제거 후 추가
          declarations.removeWhere((d) => 
            d.userId == newDecl.userId && d.reviewNum == newDecl.reviewNum);
          declarations.add(newDecl);
        }
        declarations.refresh();
        print('📊 로컬 데이터 업데이트 완료: ${newDeclarations.length}개');
      }
      
      // 결과에 따른 메시지 표시 (한 번만)
      await _showSanctionResult(successList, failedList, sanctionLevel);
      
      // 성공한 건이 있으면 서버 데이터 새로고침
      if (successList.isNotEmpty) {
        print('🔄 서버 데이터 새로고침 시작...');
        await Future.delayed(Duration(milliseconds: 500)); // UI 업데이트 시간 확보
        await _refreshAllData();
        print('✅ 서버 데이터 새로고침 완료');
      }
      
      print('🎉 === 제재 처리 완료 ===');
      print('✅ 성공: ${successList.length}개, ❌ 실패: ${failedList.length}개');
      
    } catch (e) {
      print('💥 전체 제재 처리 오류: $e');
      Get.snackbar(
        '오류',
        '제재 처리 중 시스템 오류가 발생했습니다.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 개별 제재 처리 (내부 메서드)
  Future<bool> _processSingleSanction({
    required String userId,
    required int reviewNum,
    required String sanctionReason,
    required String sanctionContent,
    required String today,
  }) async {
    try {
      await createDeclaration(
        userId: userId,
        reviewNum: reviewNum,
        declarationContent: sanctionReason,
        declarationDate: today,
        declarationState: '처리완료',
        sanctionContent: sanctionContent,
        sanctionDate: today,
      );
      return true;
    } catch (e) {
      print('개별 제재 실패 - $userId: $e');
      return false;
    }
  }

  /// 제재 결과 메시지 표시 (내부 메서드)
  Future<void> _showSanctionResult(List<String> successList, List<String> failedList, String sanctionLevel) async {
    if (successList.isNotEmpty && failedList.isEmpty) {
      // 모든 제재 성공
      Get.snackbar(
        '제재 완료',
        '${successList.length}개 리뷰에 대한 $sanctionLevel 제재가 완료되었습니다.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } else if (successList.isNotEmpty && failedList.isNotEmpty) {
      // 일부 성공, 일부 실패
      Get.snackbar(
        '제재 부분 완료',
        '성공: ${successList.length}개, 실패: ${failedList.length}개',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } else {
      // 모든 제재 실패
      Get.snackbar(
        '제재 실패',
        '모든 제재 처리가 실패했습니다. 네트워크 상태를 확인해주세요.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    }
  }

  /// 전체 데이터 새로고침 (내부 메서드)
  Future<void> _refreshAllData() async {
    try {
      await Future.wait([
        fetchDeclarations(),
        fetchSanctionedUsers(),
        fetchStats(),
      ]);
    } catch (e) {
      print('데이터 새로고침 오류: $e');
    }
  }

  // =================== API 호출 메서드들 ===================
  
  /// 서버에서 통계 정보를 가져옵니다
  Future<void> fetchStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin_stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        if (result['status'] == 'success' && result['data'] != null) {
          final data = result['data'];
          storeCount.value = data['store_count'] ?? 0;
          userCount.value = data['user_count'] ?? 0;
          reviewCount.value = data['review_count'] ?? 0;
          sanctionedUserCount.value = data['sanctioned_user_count'] ?? 0;
        }
      } else {
        print('통계 정보 가져오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('통계 정보 가져오기 오류: $e');
      storeCount.value = 0;
      userCount.value = 0;
      reviewCount.value = 0;
      sanctionedUserCount.value = 0;
    }
  }

  /// 매장 목록을 서버에서 가져옵니다
  Future<void> fetchStores() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stores'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        if (result['status'] == 'success' && result['data'] != null) {
          stores.value = List<Map<String, dynamic>>.from(result['data']);
          print('매장 목록 로드 완료: ${stores.length}개');
        } else {
          stores.value = [];
          print('매장 데이터가 없습니다.');
        }
      } else {
        print('매장 목록 가져오기 실패: ${response.statusCode}');
        stores.value = [];
      }
    } catch (e) {
      print('fetchStores 오류: $e');
      stores.value = [];
      _showErrorSnackbar('매장 목록을 가져올 수 없습니다.');
    }
  }

  /// 리뷰 목록을 서버에서 가져옵니다
  Future<void> fetchReviews() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        if (result['status'] == 'success' && result['data'] != null) {
          reviews.value = List<Map<String, dynamic>>.from(result['data']);
          print('리뷰 목록 로드 완료: ${reviews.length}개');
        } else {
          reviews.value = [];
          print('리뷰 데이터가 없습니다.');
        }
      } else {
        print('리뷰 목록 가져오기 실패: ${response.statusCode}');
        reviews.value = [];
      }
    } catch (e) {
      print('fetchReviews 오류: $e');
      reviews.value = [];
      _showErrorSnackbar('리뷰 목록을 가져올 수 없습니다.');
    }
  }

  /// 특정 매장의 리뷰를 서버에서 가져옵니다
  /// @param storeId 조회할 매장 ID
  Future<void> fetchStoreReviews(String storeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stores/$storeId/reviews'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        if (result['status'] == 'success' && result['data'] != null) {
          List<Map<String, dynamic>> storeReviews = List<Map<String, dynamic>>.from(result['data']);
          
          // 기존 리뷰에서 해당 매장 리뷰 제거 후 새 데이터 추가
          reviews.removeWhere((review) => review['store_id']?.toString() == storeId);
          reviews.addAll(storeReviews);
          
          print('매장 $storeId 리뷰 로드 완료: ${storeReviews.length}개');
        }
      } else {
        print('매장 리뷰 가져오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('fetchStoreReviews 오류: $e');
      _showErrorSnackbar('매장 리뷰를 가져올 수 없습니다.');
    }
  }

  /// 신고 목록을 서버에서 가져옵니다
  Future<void> fetchDeclarations() async {
    try {
      print('🔄 === fetchDeclarations 시작 ===');
      final response = await http.get(
        Uri.parse('$baseUrl/declarations'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 declarations 응답 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        List<Declaration> declarationList = [];
        
        if (result['status'] == 'success' && result['data'] != null) {
          print('📊 받은 declarations 데이터 수: ${result['data'].length}');
          
          for (var item in result['data']) {
            try {
              final declaration = Declaration.fromJson(item);
              declarationList.add(declaration);
              
              // 제재 관련 데이터 로그
              if (declaration.sanctionContent != null && declaration.sanctionContent!.isNotEmpty) {
                print('🚨 제재 데이터 발견:');
                print('   👤 사용자: ${declaration.userId} (${declaration.userNickname})');
                print('   📝 제재내용: ${declaration.sanctionContent}');
                print('   📋 제재사유: ${declaration.declarationContent}');
                print('   📅 제재날짜: ${declaration.sanctionDate}');
              }
            } catch (e) {
              print('❌ Declaration 파싱 오류: $e');
              print('   원본 데이터: $item');
              continue;
            }
          }
        }
        
        // declarations 업데이트
        final oldCount = declarations.length;
        declarations.value = declarationList;
        
        // 제재된 선언 수 계산
        final sanctionedCount = declarationList
            .where((d) => d.sanctionContent != null && d.sanctionContent!.isNotEmpty)
            .length;
            
        print('✅ declarations 업데이트 완료:');
        print('   📊 전체: ${declarationList.length}개 (이전: $oldCount개)');
        print('   🚨 제재: $sanctionedCount개');
        
        // UI 강제 새로고침
        declarations.refresh();
        
      } else {
        print('❌ declarations API 오류: ${response.statusCode}');
        print('   응답: ${response.body}');
        _showErrorSnackbar('신고 목록을 가져오는데 실패했습니다 (${response.statusCode})');
      }
    } catch (e) {
      print('❌ fetchDeclarations 네트워크 오류: $e');
      _showErrorSnackbar('서버에 연결할 수 없습니다');
    }
  }

  /// 제재된 유저 목록을 서버에서 가져옵니다
  Future<void> fetchSanctionedUsers() async {
    try {
      print('=== fetchSanctionedUsers 시작 ===');
      final response = await http.get(
        Uri.parse('$baseUrl/sanctioned_users'),
        headers: {'Content-Type': 'application/json'},
      );

      print('sanctioned_users 응답 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        List<Declaration> sanctionedList = [];
        
        if (result['status'] == 'success' && result['data'] != null) {
          print('받은 sanctioned_users 데이터 수: ${result['data'].length}');
          
          for (var item in result['data']) {
            try {
              final sanctionedUser = Declaration.fromJson(item);
              sanctionedList.add(sanctionedUser);
              print('제재 사용자 발견 - 사용자: ${sanctionedUser.userId}, 제재내용: ${sanctionedUser.sanctionContent}');
            } catch (e) {
              print('SanctionedUser 파싱 오류: $e, 데이터: $item');
              continue;
            }
          }
        }
        
        sanctionedUsers.value = sanctionedList;
        print('sanctionedUsers 업데이트 완료: ${sanctionedList.length}개');
      }
    } catch (e) {
      print('fetchSanctionedUsers 오류: $e');
    }
  }

  // =================== 제재 관리 메서드들 ===================
  
  /// 신고/리뷰를 수정합니다 (제재 처리 포함)
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
          _showSuccessSnackbar('제재 처리가 완료되었습니다.');
          
          await Future.wait([
            fetchDeclarations(),
            fetchSanctionedUsers(),
            fetchStats(),
          ]);
        } else {
          throw Exception(data['message'] ?? '알 수 없는 오류');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('updateDeclaration 오류: $e');
      _showErrorSnackbar('제재 처리 중 오류가 발생했습니다');
    } finally {
      isLoading.value = false;
    }
  }

  /// 특정 사용자의 제재를 해제합니다
  Future<void> releaseSanction(String userId) async {
    try {
      isLoading.value = true;
      
      print('🔓 === 제재 해제 시작 - 사용자: $userId ===');
      
      final response = await http.put(
        Uri.parse('$baseUrl/release_sanction/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 제재 해제 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['status'] == 'success') {
          print('✅ 서버 제재 해제 성공: $userId');
          
          // 1. 로컬 declarations에서 해당 사용자의 제재 내용 즉시 제거
          declarations.removeWhere((d) => d.userId == userId && d.sanctionContent != null);
          sanctionedUsers.removeWhere((d) => d.userId == userId);
          
          // 2. 로컬 reviews에서 해당 사용자의 리뷰 상태를 '정상'으로 즉시 업데이트
          _updateLocalReviewStates(userId, '정상');
          
          // 3. UI 즉시 새로고침
          declarations.refresh();
          sanctionedUsers.refresh();
          reviews.refresh();
          
          print('✅ 로컬 데이터 즉시 업데이트 완료');
          
          _showSuccessSnackbar('제재가 해제되었습니다.');
          
          // 4. 백그라운드에서 서버 데이터와 동기화
          _refreshAllDataAfterSanctionRelease();
          
        } else {
          throw Exception('제재 해제 실패: ${data['message'] ?? '알 수 없는 오류'}');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ releaseSanction 오류: $e');
      _showErrorSnackbar('제재 해제 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// 로컬 리뷰 데이터에서 특정 사용자의 리뷰 상태를 업데이트
  void _updateLocalReviewStates(String userId, String newState) {
    print('🔄 로컬 리뷰 상태 업데이트 시작 - 사용자: $userId → $newState');
    
    int updatedCount = 0;
    for (int i = 0; i < reviews.length; i++) {
      if (reviews[i]['user_id']?.toString() == userId) {
        // 기존 리뷰 데이터 복사 후 상태 업데이트
        Map<String, dynamic> updatedReview = Map<String, dynamic>.from(reviews[i]);
        updatedReview['review_state'] = newState;
        updatedReview['user_state'] = '활성'; // 사용자 상태도 함께 업데이트
        
        reviews[i] = updatedReview;
        updatedCount++;
        
        print('   ✅ 리뷰 ${reviews[i]['review_num']} 상태 업데이트: $newState');
      }
    }
    
    print('📊 총 $updatedCount개 리뷰 상태 업데이트 완료');
  }

  /// 제재 해제 후 백그라운드 데이터 새로고침
  Future<void> _refreshAllDataAfterSanctionRelease() async {
    try {
      print('🔄 제재 해제 후 백그라운드 동기화 시작...');
      
      await Future.wait([
        fetchDeclarations(),
        fetchSanctionedUsers(),
        fetchReviews(), // 리뷰 데이터 새로고침 추가
        fetchStats(),
      ]);
      
      print('✅ 제재 해제 후 백그라운드 동기화 완료');
      
    } catch (e) {
      print('❌ 백그라운드 동기화 오류: $e');
    }
  }

  /// 신고를 삭제합니다
  Future<void> deleteDeclaration(int reviewNum) async {
    try {
      isLoading.value = true;
      
      final response = await http.delete(
        Uri.parse('$baseUrl/declarations/$reviewNum'), // URL 수정
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['status'] == 'success') {
          _showSuccessSnackbar('신고가 삭제되었습니다.');
          await fetchDeclarations();
        } else {
          throw Exception(data['message'] ?? '알 수 없는 오류');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('deleteDeclaration 오류: $e');
      _showErrorSnackbar('신고 삭제 중 오류가 발생했습니다.');
    } finally {
      isLoading.value = false;
    }
  }

  /// 새로운 신고를 등록합니다
  Future<void> createDeclaration({
    required String userId,
    required int reviewNum,
    required String declarationContent,
    required String declarationDate,
    required String declarationState,
    String? sanctionContent,
    String? sanctionDate,
  }) async {
    print('🔄 createDeclaration 시작 - $userId, 리뷰: $reviewNum');
    
    try {
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

      print('📡 서버 응답 - 코드: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = json.decode(utf8.decode(response.bodyBytes));
          print('📄 응답 데이터: $data');
          
          if (data['status'] == 'success') {
            print('✅ 제재 등록 성공: $userId');
            return; // 성공시 정상 종료
          } else {
            final errorMsg = data['message'] ?? data['result'] ?? '알 수 없는 오류';
            print('❌ 제재 등록 실패: $errorMsg');
            throw Exception(errorMsg);
          }
        } catch (jsonError) {
          print('❌ JSON 파싱 오류: $jsonError');
          print('원본 응답: ${response.body}');
          throw Exception('서버 응답 파싱 실패');
        }
      } else {
        // HTTP 에러 상태 코드
        String errorMessage = 'HTTP ${response.statusCode} 오류';
        try {
          final errorData = json.decode(utf8.decode(response.bodyBytes));
          errorMessage = errorData['detail'] ?? errorMessage;
        } catch (e) {
          // JSON 파싱 실패시 기본 메시지 사용
        }
        print('❌ HTTP 오류: $errorMessage');
        throw Exception(errorMessage);
      }
    } on Exception catch (e) {
      print('❌ 처리된 예외: $e');
      rethrow; // 이미 처리된 예외는 다시 throw
    } catch (e) {
      print('❌ 예상치 못한 오류: $e');
      throw Exception('네트워크 오류: ${e.toString()}');
    }
  }

  // =================== 제재 옵션 설정 메서드들 ===================
  
  /// 제재 유형을 설정합니다
  void setSanctionType(String type) {
    selectedSanctionType.value = type;
  }

  /// 제재 기간을 설정합니다
  void setSanctionPeriod(String period) {
    selectedSanctionPeriod.value = period;
  }

  /// 현재 선택된 제재 옵션으로 제재 내용을 생성합니다
  String generateSanctionContent() {
    return '${selectedSanctionType.value} - ${selectedSanctionPeriod.value} 제재';
  }

  // =================== 데이터 새로고침 및 유틸리티 메서드들 ===================
  
  /// 모든 데이터를 새로고침합니다
  Future<void> refreshData() async {
    try {
      print('🔄 === 전체 데이터 새로고침 시작 ===');
      isLoading.value = true;
      
      // 모든 데이터를 병렬로 새로고침
      await Future.wait([
        fetchStores(),
        fetchReviews(),
        fetchDeclarations(),
        fetchSanctionedUsers(),
        fetchStats(),
      ]);
      
      print('✅ === 전체 데이터 새로고침 완료 ===');
      print('📊 현재 상태:');
      print('   🏪 매장: ${stores.length}개');
      print('   📝 리뷰: ${reviews.length}개');
      print('   📋 신고: ${declarations.length}개');
      print('   🚨 제재: ${declarations.where((d) => d.sanctionContent != null && d.sanctionContent!.isNotEmpty).length}개');
      
    } catch (e) {
      print('❌ 전체 데이터 새로고침 오류: $e');
      _showErrorSnackbar('데이터 새로고침 중 오류가 발생했습니다');
    } finally {
      isLoading.value = false;
    }
  }

  /// 상태에 따른 색상을 반환합니다
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
      case '선택됨':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // =================== 사설 헬퍼 메서드들 ===================
  
  /// 성공 스낵바를 표시합니다
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      '성공',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  /// 에러 스낵바를 표시합니다
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      '오류',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }
}

// =====================================================================================
// 문의 관리 컨트롤러 (InquiryController) - 수정된 버전
// =====================================================================================
class InquiryController extends GetxController {
  // =================== 기본 설정 ===================
  final String baseUrl = 'http://192.168.50.236:8000/kwonhyoung'; // prefix 추가

  // =================== 반응형 변수들 ===================
  var inquiryList = <Inquiry>[].obs; // 문의 목록
  var isLoading = true.obs; // 로딩 상태
  var errorMessage = ''.obs; // 에러 메시지
  RxnInt selectedInquiryNum = RxnInt(); // 선택된 문의 번호

  @override
  void onInit() {
    super.onInit();
    fetchInquiries(); // 문의 목록 초기 로드
  }

  /// 전체 문의 내역을 서버에서 가져옵니다
  void fetchInquiries() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      var url = Uri.parse('$baseUrl/inquiries');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        if (result['status'] == 'success' && result['data'] != null) {
          inquiryList.value = result['data'].map<Inquiry>((e) => Inquiry.fromJson(e)).toList();
          print('문의 목록 로드 완료: ${inquiryList.length}개');
        } else {
          errorMessage.value = '데이터가 없습니다';
        }
      } else {
        errorMessage.value = '서버 오류: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = '데이터를 불러오는데 실패했습니다.\n${e.toString()}';
      print('fetchInquiries 오류: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 개별 문의를 조회합니다
  /// @param inquiryNum 조회할 문의 번호
  /// @return 문의 객체 또는 null
  Future<Inquiry?> getInquiry(int inquiryNum) async {
    try {
      var url = Uri.parse('$baseUrl/inquiries/$inquiryNum'); // URL 수정
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));
        if (result['status'] == 'success' && result['data'] != null) {
          return Inquiry.fromJson(result['data']);
        }
      }
      return null;
    } catch (e) {
      print('getInquiry 오류: $e');
      return null;
    }
  }

  /// 새로운 문의를 등록합니다
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
        if (result['status'] == 'success') {
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

  /// 문의를 수정합니다
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
      var url = Uri.parse('$baseUrl/inquiries/$inquiryNum'); // URL 수정
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
        if (result['status'] == 'success') {
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

  /// 문의에 답변을 등록합니다 (수정된 버전)
  /// inquiryNum 문의 번호
  /// responseText 답변 내용
  /// responseDate 답변 날짜
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
      if(responseText.isEmpty){
               Get.snackbar(
          '오류', 
          '내용을 입력하세요.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        ); 
      }
      if (success) {
        Get.snackbar(
          '성공', 
          '답변이 등록되었습니다.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          '오류', 
          '답변 등록에 실패했습니다.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  /// 문의를 삭제합니다 (반려 처리)
  /// @param inquiryNum 삭제할 문의 번호
  /// @return 삭제 성공 여부
  Future<bool> deleteInquiry(int inquiryNum) async {
    try {
      var url = Uri.parse('$baseUrl/inquiries/$inquiryNum'); // URL 수정
      var response = await http.delete(url);

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        if (result['status'] == 'success') {
          inquiryList.removeWhere((i) => i.inquiryNum == inquiryNum);
          Get.snackbar(
            '성공', 
            '문의가 반려되었습니다.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      errorMessage.value = '삭제 실패: ${e.toString()}';
      Get.snackbar(
        '오류', 
        '문의 반려에 실패했습니다.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// 선택된 문의 객체를 반환하는 getter
  Inquiry? get selectedInquiry {
    return inquiryList.firstWhereOrNull((i) => i.inquiryNum == selectedInquiryNum.value);
  }
}
