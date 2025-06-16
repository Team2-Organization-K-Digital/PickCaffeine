import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/model/kwonhyoung/declaration_model.dart';
import 'package:pick_caffeine_app/model/kwonhyoung/inquiry_model.dart';
import 'dart:typed_data';

// 개선된 버전(25.06.12.) - 수정 버전3
// =====================================================================================
// 신고 및 매장 관리 컨트롤러 (Declaration과 Store 관리 통합) - 이미지, 리뷰, 리스트 갱신 수정
// =====================================================================================

class DeclarationController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // =================== 기본 설정 ===================
  static String baseUrl = 'http://127.0.0.1:8000/kwonhyoung'; // 백엔드 서버 주소

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

    // 데이터 타입 안전한 비교
    return reviews.where((review) {
      final reviewStoreId = review['store_id']?.toString() ?? '';
      final selectedId = selectedStoreId.value.toString();
      return reviewStoreId == selectedId && reviewStoreId.isNotEmpty;
    }).toList();
  }

  /// 선택된 리뷰들을 반환 (체크박스로 선택된 리뷰들)
  List<Map<String, dynamic>> get selectedReviews {
    return filteredReviews
        .where((review) => selectedReviewNums.contains(review['review_num']))
        .toList();
  }

  /// 제재 유형에 따라 필터링된 제재 내역을 반환
  List<Declaration> get filteredSanctionedDeclarations {
    final sanctionedDeclarations =
        declarations
            .where(
              (d) => d.sanctionContent != null && d.sanctionContent!.isNotEmpty,
            )
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
    tabController = TabController(length: 3, vsync: this);
    // 즉시 로딩 시작
    ever(stores, (_) => update()); // stores 변경 시 UI 업데이트
    _initializeDataSequentially();
  }

  // 초기화 메서드 수정
  Future<void> _initializeDataSequentially() async {
    try {
      isLoading.value = true;

      // 통계는 병렬로 처리
      fetchStats();

      // 매장 데이터를 먼저 확실하게 로드
      await fetchStores();

      // 매장 로드 완료 후 나머지 데이터 로드
      if (stores.isNotEmpty) {
        await Future.wait([
          fetchReviews(),
          fetchDeclarations(),
          fetchSanctionedUsers(),
        ]);
      }
    } catch (e) {
      _showErrorSnackbar('데이터 로딩 중 오류가 발생했습니다.');
    } finally {
      isLoading.value = false;
    }
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
  Future sanctionSelectedReviewsWithReason({
    required String sanctionLevel,
    required String sanctionReason,
  }) async {
    final selectedList = selectedReviews;
    if (selectedList.isEmpty) {
      Get.snackbar(
        '알림',
        '제재할 리뷰를 선택해주세요.',
        backgroundColor: AppColors.lightbrown,
        colorText: AppColors.white,
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
          } else {
            failedList.add(userId);
          }
        } catch (e) {
          failedList.add(userId);
        }
      }

      // 제재 처리 후 선택 해제
      clearAllReviewSelections();

      // 성공한 Declaration들을 로컬에 반영
      if (newDeclarations.isNotEmpty) {
        for (Declaration newDecl in newDeclarations) {
          // 중복 제거 후 추가
          declarations.removeWhere(
            (d) =>
                d.userId == newDecl.userId && d.reviewNum == newDecl.reviewNum,
          );
          declarations.add(newDecl);
        }
        declarations.refresh();
      }

      // 결과에 따른 메시지 표시 (한 번만)
      await _showSanctionResult(successList, failedList, sanctionLevel);

      // 성공한 건이 있으면 서버 데이터 새로고침
      if (successList.isNotEmpty) {
        await Future.delayed(Duration(milliseconds: 500)); // UI 업데이트 시간 확보
        await _refreshAllData();
      }
    } catch (e) {
      Get.snackbar(
        '오류',
        '제재 처리 중 시스템 오류가 발생했습니다.',
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
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
      return false;
    }
  }

  /// 제재 결과 메시지 표시 (내부 메서드)
  Future<void> _showSanctionResult(
    List<String> successList,
    List<String> failedList,
    String sanctionLevel,
  ) async {
    if (successList.isNotEmpty && failedList.isEmpty) {
      // 모든 제재 성공
      Get.snackbar(
        '제재 완료',
        '${successList.length}개 리뷰에 대한 $sanctionLevel 제재가 완료되었습니다.',
        backgroundColor: AppColors.brown,
        colorText: AppColors.white,
        duration: Duration(seconds: 3),
      );
    } else if (successList.isNotEmpty && failedList.isNotEmpty) {
      // 일부 성공, 일부 실패
      Get.snackbar(
        '제재 부분 완료',
        '성공: ${successList.length}개, 실패: ${failedList.length}개',
        backgroundColor: AppColors.lightbrown,
        colorText: AppColors.white,
        duration: Duration(seconds: 4),
      );
    } else {
      // 모든 제재 실패
      Get.snackbar(
        '제재 실패',
        '모든 제재 처리가 실패했습니다. 네트워크 상태를 확인해주세요.',
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
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
      // 에러 처리
    }
  }

  // =================== API 호출 메서드들 ===================
  /// 서버에서 통계 정보를 가져옵니다
  Future fetchStats() async {
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
      }
    } catch (e) {
      storeCount.value = 0;
      userCount.value = 0;
      reviewCount.value = 0;
      sanctionedUserCount.value = 0;
    }
  }

  /// 매장 목록을 서버에서 가져옵니다 (수정된 버전)
  Future<void> fetchStores() async {
    try {
      // 로딩 상태 유지 (값 초기화 제거)

      final response = await http
          .get(
            Uri.parse('$baseUrl/stores'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 15)); // 타임아웃 증가

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));

        if (result['status'] == 'success' && result['data'] != null) {
          final rawStores = List<Map<String, dynamic>>.from(result['data']);

          List<Map<String, dynamic>> processedStores = [];
          for (var store in rawStores) {
            try {
              Map<String, dynamic> processedStore = {
                'store_id': store['store_id']?.toString() ?? '',
                'store_name': store['store_name']?.toString() ?? '매장명 없음',
                'store_business_num':
                    store['store_business_num']?.toString() ?? '정보 없음',
                'store_address':
                    store['store_address']?.toString() ?? '주소 정보 없음',
                'store_addressdetail':
                    store['store_addressdetail']?.toString() ?? '',
                'store_phone': store['store_phone']?.toString(),
                'store_content': store['store_content']?.toString() ?? '',
                'store_state': store['store_state']?.toString() ?? '연결 안됨',
                'review_count': store['review_count'] ?? 0,
              };

              _processStoreImage(processedStore, store);
              processedStores.add(processedStore);
            } catch (e) {
              continue;
            }
          }

          // 리스트 업데이트 보장
          stores.assignAll(processedStores);
          storeCount.value = processedStores.length;
        } else {
          stores.clear();
        }
      } else {
        stores.clear();
        _showErrorSnackbar('서버 연결 실패: ${response.statusCode}');
      }
    } catch (e) {
      stores.clear();
      _showErrorSnackbar('매장 목록 로딩 실패');
    }
  }

  /// 이미지를 표시하기 위한 위젯 반환 메서드
  Widget getStoreImageWidget(
    Map<String, dynamic> store, {
    double? width,
    double? height,
  }) {
    final imageData = store['store_image_base64'];
    if (imageData != null && imageData.toString().isNotEmpty) {
      try {
        // base64 문자열을 Uint8List로 변환
        Uint8List bytes = base64Decode(imageData.toString());
        return Container(
          width: width ?? 100,
          height: height ?? 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.greyopac,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.store, color: AppColors.grey, size: 30);
              },
            ),
          ),
        );
      } catch (e) {
        return Container(
          width: width ?? 100,
          height: height ?? 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.greyopac,
          ),
          child: Icon(Icons.store, color: AppColors.grey, size: 30),
        );
      }
    } else {
      return Container(
        width: width ?? 100,
        height: height ?? 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.greyopac,
        ),
        child: Icon(Icons.store, color: AppColors.grey, size: 30),
      );
    }
  }

  /// 리뷰 목록을 서버에서 가져옵니다 (개선된 버전)
  Future fetchReviews() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        if (result['status'] == 'success' && result['data'] != null) {
          final reviewData = List<Map<String, dynamic>>.from(result['data']);

          // 데이터 안전성 검증 및 정리
          List<Map<String, dynamic>> validReviews = [];
          for (var review in reviewData) {
            try {
              // 필수 필드 확인 및 기본값 설정
              final validReview = {
                'review_num': review['review_num'] ?? 0,
                'purchase_num': review['purchase_num'] ?? 0,
                'review_content': review['review_content']?.toString() ?? '',
                'review_image': review['review_image']?.toString(),
                'review_date': review['review_date']?.toString() ?? '',
                'review_state': review['review_state']?.toString() ?? '정상',
                'user_id': review['user_id']?.toString() ?? 'unknown',
                'store_id': review['store_id']?.toString() ?? 'unknown',
                'user_nickname':
                    review['user_nickname']?.toString() ?? 'unknown',
                'user_image': review['user_image']?.toString(),
                'user_state': review['user_state']?.toString() ?? 'unknown',
                'store_name': review['store_name']?.toString() ?? 'unknown',
                'store_address': review['store_address']?.toString() ?? '',
                'sanction_content': review['sanction_content']?.toString(),
                'sanction_date': review['sanction_date']?.toString(),
                'declaration_state': review['declaration_state']?.toString(),
                'current_sanction_status':
                    review['current_sanction_status']?.toString() ?? 'normal',
              };
              validReviews.add(validReview);
            } catch (e) {
              continue;
            }
          }

          reviews.value = validReviews;
        } else {
          reviews.value = [];
        }
      } else {
        reviews.value = [];
      }
    } catch (e) {
      reviews.value = [];
      _showErrorSnackbar('리뷰 목록을 가져올 수 없습니다.');
    }
  }

  /// 특정 매장의 리뷰를 서버에서 가져옵니다
  /// @param storeId 조회할 매장 ID
  Future fetchStoreReviews(String storeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stores/$storeId/reviews'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        if (result['status'] == 'success' && result['data'] != null) {
          List<Map<String, dynamic>> storeReviews =
              List<Map<String, dynamic>>.from(result['data']);

          // 기존 리뷰에서 해당 매장 리뷰 제거 후 새 데이터 추가
          reviews.removeWhere(
            (review) => review['store_id']?.toString() == storeId,
          );
          reviews.addAll(storeReviews);

          // UI 새로고침
          reviews.refresh();
        }
      }
    } catch (e) {
      _showErrorSnackbar('매장 리뷰를 가져올 수 없습니다.');
    }
  }

  /// 신고 목록을 서버에서 가져옵니다
  Future fetchDeclarations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/declarations'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        List<Declaration> declarationList = [];

        if (result['status'] == 'success' && result['data'] != null) {
          for (var item in result['data']) {
            try {
              final declaration = Declaration.fromJson(item);
              declarationList.add(declaration);
            } catch (e) {
              continue;
            }
          }

          // declarations 업데이트
          declarations.value = declarationList;

          // UI 강제 새로고침
          declarations.refresh();
        }
      } else {
        _showErrorSnackbar('신고 목록을 가져오는데 실패했습니다 (${response.statusCode})');
      }
    } catch (e) {
      _showErrorSnackbar('서버에 연결할 수 없습니다');
    }
  }

  /// 제재된 유저 목록을 서버에서 가져옵니다
  Future fetchSanctionedUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sanctioned_users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        List<Declaration> sanctionedList = [];

        if (result['status'] == 'success' && result['data'] != null) {
          for (var item in result['data']) {
            try {
              final sanctionedUser = Declaration.fromJson(item);
              sanctionedList.add(sanctionedUser);
            } catch (e) {
              continue;
            }
          }

          sanctionedUsers.value = sanctionedList;
        }
      }
    } catch (e) {
      // 에러 처리
    }
  }

  // =================== 제재 관리 메서드들 ===================
  /// 신고/리뷰를 수정합니다 (제재 처리 포함)
  Future updateDeclaration({
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
      _showErrorSnackbar('제재 처리 중 오류가 발생했습니다');
    } finally {
      isLoading.value = false;
    }
  }

  /// 특정 사용자의 제재를 해제합니다
  Future releaseSanction(String userId) async {
    try {
      isLoading.value = true;

      final response = await http.put(
        Uri.parse('$baseUrl/release_sanction/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['status'] == 'success') {
          // 1. 로컬 declarations에서 해당 사용자의 제재 내용 즉시 제거
          declarations.removeWhere(
            (d) => d.userId == userId && d.sanctionContent != null,
          );
          sanctionedUsers.removeWhere((d) => d.userId == userId);

          // 2. 로컬 reviews에서 해당 사용자의 리뷰 상태를 '정상'으로 즉시 업데이트
          _updateLocalReviewStates(userId, '정상');

          // 3. UI 즉시 새로고침
          declarations.refresh();
          sanctionedUsers.refresh();
          reviews.refresh();

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
      _showErrorSnackbar('제재 해제 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// 로컬 리뷰 데이터에서 특정 사용자의 리뷰 상태를 업데이트
  void _updateLocalReviewStates(String userId, String newState) {
    for (int i = 0; i < reviews.length; i++) {
      if (reviews[i]['user_id']?.toString() == userId) {
        // 기존 리뷰 데이터 복사 후 상태 업데이트
        Map<String, dynamic> updatedReview = Map.from(reviews[i]);
        updatedReview['review_state'] = newState;
        updatedReview['user_state'] = '활성'; // 사용자 상태도 함께 업데이트
        reviews[i] = updatedReview;
      }
    }
  }

  /// 제재 해제 후 백그라운드 데이터 새로고침
  Future<void> _refreshAllDataAfterSanctionRelease() async {
    try {
      await Future.wait([
        fetchDeclarations(),
        fetchSanctionedUsers(),
        fetchReviews(), // 리뷰 데이터 새로고침 추가
        fetchStats(),
      ]);
    } catch (e) {
      // 에러 처리
    }
  }

  /// 신고를 삭제합니다
  Future deleteDeclaration(int reviewNum) async {
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
      _showErrorSnackbar('신고 삭제 중 오류가 발생했습니다.');
    } finally {
      isLoading.value = false;
    }
  }

  /// 새로운 신고를 등록합니다
  Future createDeclaration({
    required String userId,
    required int reviewNum,
    required String declarationContent,
    required String declarationDate,
    required String declarationState,
    String? sanctionContent,
    String? sanctionDate,
  }) async {
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

      if (response.statusCode == 200) {
        try {
          final data = json.decode(utf8.decode(response.bodyBytes));
          if (data['status'] == 'success') {
            return; // 성공시 정상 종료
          } else {
            final errorMsg = data['message'] ?? data['result'] ?? '알 수 없는 오류';
            throw Exception(errorMsg);
          }
        } catch (jsonError) {
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

        throw Exception(errorMessage);
      }
    } on Exception catch (e) {
      rethrow; // 이미 처리된 예외는 다시 throw
    } catch (e) {
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
  /// 모든 데이터를 새로고침합니다 (수정된 버전)
  Future refreshData() async {
    try {
      isLoading.value = true;

      // 순차적으로 데이터 새로고침
      await fetchStats();
      await fetchStores();

      // 나머지 데이터는 병렬로 처리
      await Future.wait([
        fetchReviews(),
        fetchDeclarations(),
        fetchSanctionedUsers(),
      ]);

      // 모든 옵저버블 강제 새로고침
      stores.refresh();
      reviews.refresh();
      declarations.refresh();
      sanctionedUsers.refresh();
    } catch (e) {
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
        return AppColors.lightbrown;
      case '처리중':
        return AppColors.lightbrown;
      case '완료':
      case '처리완료':
        return AppColors.brown;
      case '제재중':
        return AppColors.red;
      case '선택됨':
        return AppColors.brown;
      default:
        return AppColors.grey;
    }
  }

  // =================== 디버깅 메서드들 ===================
  /// 매장 이미지 디버깅
  Future debugStoreImages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/debug/store_images'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        if (result['status'] == 'success' && result['data'] != null) {
          final data = result['data'] as List;

          // UI에 결과 표시
          Get.dialog(
            AlertDialog(
              title: Text(
                'store_image 테이블 현황',
                style: TextStyle(color: AppColors.brown),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final row = data[index];
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '매장 ID: ${row['store_id']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '이미지1: ${row['has_image_1']} (${row['image_1_size']} bytes)',
                            ),
                            Text(
                              '이미지2: ${row['has_image_2']} (${row['image_2_size']} bytes)',
                            ),
                            Text(
                              '이미지3: ${row['has_image_3']} (${row['image_3_size']} bytes)',
                            ),
                            Text(
                              '이미지4: ${row['has_image_4']} (${row['image_4_size']} bytes)',
                            ),
                            Text(
                              '이미지5: ${row['has_image_5']} (${row['image_5_size']} bytes)',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('닫기', style: TextStyle(color: AppColors.brown)),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      // 에러 처리
    }
  }

  // =================== 사설 헬퍼 메서드들 ===================
  /// 성공 스낵바를 표시합니다
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      '성공',
      message,
      backgroundColor: AppColors.brown,
      colorText: AppColors.white,
      duration: Duration(seconds: 2),
    );
  }

  /// 에러 스낵바를 표시합니다
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      '오류',
      message,
      backgroundColor: AppColors.red,
      colorText: AppColors.white,
      duration: Duration(seconds: 3),
    );
  }

  /// 매장 이미지 데이터 처리 (내부 메서드)
  void _processStoreImage(
    Map<String, dynamic> processedStore,
    Map<String, dynamic> rawStore,
  ) {
    try {
      // 기본값 설정
      processedStore['store_image'] = null;
      processedStore['store_image_base64'] = null;
      processedStore['store_image_display'] = null;

      // store_image 또는 store_image_base64 필드에서 이미지 데이터 추출
      final imageData =
          rawStore['store_image'] ?? rawStore['store_image_base64'];

      if (imageData != null && imageData.toString().isNotEmpty) {
        String base64Data = imageData.toString();

        // data:image 형식인 경우 base64 부분만 추출
        if (base64Data.startsWith('data:image')) {
          List<String> parts = base64Data.split(',');
          if (parts.length > 1) {
            base64Data = parts[1];
          }
        }

        // base64 데이터 유효성 검증
        if (_isValidBase64(base64Data)) {
          processedStore['store_image_base64'] = base64Data;
          processedStore['store_image'] = base64Data;
          processedStore['store_image_display'] =
              'data:image/jpeg;base64,$base64Data';
        }
      }
    } catch (e) {
      // 에러 발생 시 기본값 유지
    }
  }

  /// Base64 데이터 유효성 검증 (내부 메서드)
  bool _isValidBase64(String base64String) {
    try {
      if (base64String.isEmpty) return false;

      // 길이 체크 (base64는 4의 배수여야 함)
      if (base64String.length % 4 != 0) {
        // 패딩 추가 시도
        int padding = 4 - (base64String.length % 4);
        base64String += '=' * padding;
      }

      // 디코딩 테스트
      base64Decode(base64String);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 기본 매장 객체 생성 (내부 메서드)
  Map<String, dynamic> _createDefaultStore(int index) {
    return {
      'store_id': 'error_store_$index',
      'store_name': '매장 정보 오류',
      'store_business_num': '정보 없음',
      'store_address': '주소 정보 없음',
      'store_addressdetail': '',
      'store_phone': null,
      'store_content': '',
      'store_state': '연결 안됨',
      'review_count': 0,
      'store_image': null,
      'store_image_base64': null,
      'store_image_display': null,
    };
  }
}

// =====================================================================================
// 문의 관리 컨트롤러 (InquiryController) - 수정된 버전
// =====================================================================================

class InquiryController extends GetxController {
  // =================== 기본 설정 ===================
  final String baseUrl = 'http://127.0.0.1:8000/kwonhyoung'; // prefix 추가

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
          inquiryList.value =
              result['data'].map<Inquiry>((e) => Inquiry.fromJson(e)).toList();
        } else {
          errorMessage.value = '데이터가 없습니다';
        }
      } else {
        errorMessage.value = '서버 오류: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = '데이터를 불러오는데 실패했습니다.\n${e.toString()}';
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
  /// @param inquiryNum 문의 번호
  /// @param responseText 답변 내용
  /// @param responseDate 답변 날짜
  Future updateResponse(
    int inquiryNum,
    String responseText,
    DateTime? responseDate,
  ) async {
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

      if (responseText.isEmpty) {
        Get.snackbar(
          '오류',
          '내용을 입력하세요.',
          backgroundColor: AppColors.red,
          colorText: AppColors.white,
        );
      }

      if (success) {
        Get.snackbar(
          '성공',
          '답변이 등록되었습니다.',
          backgroundColor: AppColors.brown,
          colorText: AppColors.white,
        );
      } else {
        Get.snackbar(
          '오류',
          '답변 등록에 실패했습니다.',
          backgroundColor: AppColors.red,
          colorText: AppColors.white,
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
            backgroundColor: AppColors.lightbrown,
            colorText: AppColors.white,
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
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
      return false;
    }
  }

  /// 선택된 문의 객체를 반환하는 getter
  Inquiry? get selectedInquiry {
    return inquiryList.firstWhereOrNull(
      (i) => i.inquiryNum == selectedInquiryNum.value,
    );
  }

  // --------------------추가-------------------------
  /// 모든 매장 리뷰를 표시하기 위해 매장 선택을 해제합니다
  void clearStoreSelection(DeclarationController controller) {
    controller.selectedStoreId.value = '';
    controller.clearAllReviewSelections();
  }
}
