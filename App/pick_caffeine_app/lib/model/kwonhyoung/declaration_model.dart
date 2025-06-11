// 신고 모델 (25.06.10. 개선된 버전)
class Declaration {
  final String userId;
  final int reviewNum;
  final DateTime declarationDate;
  final String declarationContent;
  final String declarationState;
  final String? sanctionContent;
  final DateTime? sanctionDate;
  final String? userNickname; // 사용자 닉네임 추가
  final String? userImage; // 사용자 이미지 추가
  final String? userState; // 사용자 상태 추가

  Declaration({
    required this.userId,
    required this.reviewNum,
    required this.declarationDate,
    required this.declarationContent,
    required this.declarationState,
    this.sanctionContent,
    this.sanctionDate,
    this.userNickname,
    this.userImage,
    this.userState,
  });

  factory Declaration.fromJson(Map<String, dynamic> json) {
    return Declaration(
      userId: json['user_id']?.toString() ?? '',
      reviewNum: json['review_num'] ?? 0,
      declarationDate: _parseDate(json['declaration_date']),
      declarationContent: json['declaration_content']?.toString() ?? '',
      declarationState: json['declaration_state']?.toString() ?? '',
      sanctionContent: json['sanction_content']?.toString(),
      sanctionDate: _parseOptionalDate(json['sanction_date']),
      userNickname: json['user_nickname']?.toString() ?? json['user_id']?.toString() ?? '알수없음',
      userImage: json['user_image']?.toString(),
      userState: json['user_state']?.toString() ?? '알수없음',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'review_num': reviewNum,
      'declaration_date': declarationDate.toIso8601String(),
      'declaration_content': declarationContent,
      'declaration_state': declarationState,
      'sanction_content': sanctionContent,
      'sanction_date': sanctionDate?.toIso8601String(),
      'user_nickname': userNickname,
      'user_image': userImage,
      'user_state': userState,
    };
  }

  /// 날짜 파싱 헬퍼 메서드 (필수 날짜)
  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    try {
      if (dateValue is String) {
        // 다양한 날짜 형식 지원
        if (dateValue.contains('T')) {
          return DateTime.parse(dateValue);
        } else {
          // YYYY-MM-DD 형식
          return DateTime.parse('${dateValue}T00:00:00');
        }
      } else if (dateValue is DateTime) {
        return dateValue;
      }
      return DateTime.now();
    } catch (e) {
      print('날짜 파싱 오류: $dateValue, 오류: $e');
      return DateTime.now();
    }
  }

  /// 선택적 날짜 파싱 헬퍼 메서드 (null 허용)
  static DateTime? _parseOptionalDate(dynamic dateValue) {
    if (dateValue == null || dateValue.toString().isEmpty) return null;
    
    try {
      if (dateValue is String) {
        if (dateValue.contains('T')) {
          return DateTime.parse(dateValue);
        } else {
          return DateTime.parse('${dateValue}T00:00:00');
        }
      } else if (dateValue is DateTime) {
        return dateValue;
      }
      return null;
    } catch (e) {
      print('선택적 날짜 파싱 오류: $dateValue, 오류: $e');
      return null;
    }
  }

  /// Declaration 객체를 복사하면서 일부 필드를 수정합니다
  Declaration copyWith({
    String? userId,
    int? reviewNum,
    DateTime? declarationDate,
    String? declarationContent,
    String? declarationState,
    String? sanctionContent,
    DateTime? sanctionDate,
    String? userNickname,
    String? userImage,
    String? userState,
  }) {
    return Declaration(
      userId: userId ?? this.userId,
      reviewNum: reviewNum ?? this.reviewNum,
      declarationDate: declarationDate ?? this.declarationDate,
      declarationContent: declarationContent ?? this.declarationContent,
      declarationState: declarationState ?? this.declarationState,
      sanctionContent: sanctionContent ?? this.sanctionContent,
      sanctionDate: sanctionDate ?? this.sanctionDate,
      userNickname: userNickname ?? this.userNickname,
      userImage: userImage ?? this.userImage,
      userState: userState ?? this.userState,
    );
  }

  /// 제재 여부를 확인합니다
  bool get isSanctioned => sanctionContent != null && sanctionContent!.isNotEmpty;

  /// 제재 레벨을 반환합니다 (1차, 2차, 기타)
  String get sanctionLevel {
    if (!isSanctioned) return '제재없음';
    
    final content = sanctionContent!.toLowerCase();
    if (content.contains('1차')) return '1차 제재';
    if (content.contains('2차')) return '2차 제재';
    return '기타 제재';
  }

  /// 사용자 표시명을 반환합니다 (닉네임 또는 ID)
  String get displayName {
    if (userNickname != null && userNickname!.isNotEmpty) {
      return '$userNickname ($userId)';
    }
    return userId;
  }

  /// 제재 기간이 유효한지 확인합니다
  bool get isActiveSanction {
    if (!isSanctioned || sanctionDate == null) return false;
    
    // 제재일로부터 30일이 지나면 자동 해제로 간주 (임시 로직)
    final thirtyDaysLater = sanctionDate!.add(Duration(days: 30));
    return DateTime.now().isBefore(thirtyDaysLater);
  }

  @override
  String toString() {
    return 'Declaration(userId: $userId, reviewNum: $reviewNum, '
           'declarationState: $declarationState, '
           'sanctionContent: $sanctionContent, '
           'userNickname: $userNickname)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Declaration &&
        other.userId == userId &&
        other.reviewNum == reviewNum &&
        other.declarationDate == declarationDate;
  }

  @override
  int get hashCode {
    return userId.hashCode ^ reviewNum.hashCode ^ declarationDate.hashCode;
  }
}