// 관리자 페이지 관련 모델
// 장바구니 드롭다운 관련 모델 및 메뉴 슬라이더블 관련 모델
//----------------------------------------------------------------------------------
// 관리자 신고 모델
class Declaration {
  final String userId;
  final int reviewNum;
  final DateTime declarationDate;
  final String declarationContent;
  final String declarationState;
  final String? sanctionContent;
  final DateTime? sanctionDate;

  Declaration({
    required this.userId,
    required this.reviewNum,
    required this.declarationDate,
    required this.declarationContent,
    required this.declarationState,
    this.sanctionContent,
    this.sanctionDate,
  });

  factory Declaration.fromJson(Map<String, dynamic> json) {
    return Declaration(
      userId: json['user_id'],
      reviewNum: json['review_num'],
      declarationDate: DateTime.parse(json['declaration_date']),
      declarationContent: json['declaration_content'],
      declarationState: json['declaration_state'],
      sanctionContent: json['sanction_content'],
      sanctionDate: json['sanction_date'] != null
          ? DateTime.tryParse(json['sanction_date'])
          : null,
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
    };
  }
}

//----------------------------------------------------------------------------------

// 관리자 문의 모델
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
      inquiryNum: json['inquiry_num'],
      userId: json['user_id'],
      userNickname: json['user_nickname'] ?? '알수없음', 
      inquiryDate: DateTime.parse(json['inquiry_date']),
      inquiryContent: json['inquiry_content'],
      inquiryState: json['inquiry_state'],
      response: json['response'],
      responseDate: json['response_date'] != null
          ? DateTime.tryParse(json['response_date'])
          : null,
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
}

//----------------------------------------------------------------------------------

//장바구니 드롭다운 관련 모델
// 장바구니 아이템 모델
class CartItem {
  final int menuNum;
  final String menuName;
  final int menuPrice;
  final int selectedQuantity;
  final String selectedOptions;
  final int totalPrice;

  CartItem({
    required this.menuNum,
    required this.menuName,
    required this.menuPrice,
    required this.selectedQuantity,
    required this.selectedOptions,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'menuNum': menuNum,
      'menuName': menuName,
      'menuPrice': menuPrice,
      'selected_quantity': selectedQuantity,
      'selectedOptions': selectedOptions,
      'totalPrice': totalPrice,
    };
  }
}

//----------------------------------------------------------------------------------
// 메뉴 슬라이더블 사용 관련 모델
// 메뉴 모델 
class MenuItem {
  final int menuNum;
  final int categoryNum; 
  final String menuName;
  final String menuContent;
  final int menuPrice;
  final String menuImage;
  String menuState; // 판매중/품절 상태

  MenuItem({
    required this.menuNum,
    required this.categoryNum,
    required this.menuName,
    required this.menuContent,
    required this.menuPrice,
    required this.menuImage,
    this.menuState = '판매중',
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      menuNum: json['menu_num'],
      categoryNum: json['category_num'],
      menuName: json['menu_name'],
      menuContent: json['menu_content'],
      menuPrice: json['menu_price'],
      menuImage: json['menu_image'],
      menuState: json['menu_state'] ?? '판매중',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_num': menuNum,
      'category_num': categoryNum,
      'menu_name': menuName,
      'menu_content': menuContent,
      'menu_price': menuPrice,
      'menu_image': menuImage,
      'menu_state': menuState,
    };
  }

  // 편의 메소드
  bool get isAvailable => menuState == '판매중';
}
