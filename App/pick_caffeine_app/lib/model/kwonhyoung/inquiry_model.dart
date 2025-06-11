// 문의 모델 (25.06.10. 수정 버전)
class Inquiry {
  final int inquiryNum;
  final DateTime inquiryDate;
  final String inquiryContent;
  final String inquiryState;
  final String? response;
  final DateTime? responseDate;
  final String userId;
  final String userNickname; // 닉네임 외래키로 받아옴

  Inquiry({
    required this.inquiryNum,
    required this.inquiryDate,
    required this.inquiryContent,
    required this.inquiryState,
    this.response,
    this.responseDate,
    required this.userId,
    required this.userNickname, 
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    return Inquiry(
      inquiryNum: json['inquiry_num'] ?? 0,
      userId: json['user_id']?.toString() ?? '',
      userNickname: json['user_nickname']?.toString() ?? '알수없음', 
      inquiryDate: _parseDate(json['inquiry_date']),
      inquiryContent: json['inquiry_content']?.toString() ?? '',
      inquiryState: json['inquiry_state']?.toString() ?? '',
      response: json['response']?.toString(),
      responseDate: _parseOptionalDate(json['response_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inquiry_num': inquiryNum,
      'inquiry_date': inquiryDate.toIso8601String(),
      'inquiry_content': inquiryContent,
      'inquiry_state': inquiryState,
      'response': response,
      'response_date': responseDate?.toIso8601String(),
      'user_id': userId,
      'user_nickname': userNickname,
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

  /// 답변 완료 여부를 확인하는 getter
  bool get isAnswered => response != null && response!.isNotEmpty;

  /// 사용자 표시명을 반환하는 getter
  String get displayUserInfo => '$userNickname ($userId)';

  /// Inquiry 객체를 복사하면서 일부 필드를 수정합니다
  Inquiry copyWith({
    int? inquiryNum,
    DateTime? inquiryDate,
    String? inquiryContent,
    String? inquiryState,
    String? response,
    DateTime? responseDate,
    String? userId,
    String? userNickname,
  }) {
    return Inquiry(
      inquiryNum: inquiryNum ?? this.inquiryNum,
      inquiryDate: inquiryDate ?? this.inquiryDate,
      inquiryContent: inquiryContent ?? this.inquiryContent,
      inquiryState: inquiryState ?? this.inquiryState,
      response: response ?? this.response,
      responseDate: responseDate ?? this.responseDate,
      userId: userId ?? this.userId,
      userNickname: userNickname ?? this.userNickname,
    );
  }

  @override
  String toString() {
    return 'Inquiry(inquiryNum: $inquiryNum, userId: $userId, '
           'userNickname: $userNickname, inquiryState: $inquiryState, '
           'isAnswered: $isAnswered)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Inquiry &&
        other.inquiryNum == inquiryNum &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return inquiryNum.hashCode ^ userId.hashCode;
  }
}