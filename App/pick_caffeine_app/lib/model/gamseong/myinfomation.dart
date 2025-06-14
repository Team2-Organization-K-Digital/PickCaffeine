class Myinfomation { 
  // 이미지 닉네임 아이디 패스워드 패스워드확인 전화번호 이메일
  final String user_nickname;
  final String user_id;
  final String user_password;
  final String user_phone;
  final String user_email;
  final String user_image;


  Myinfomation
  
  ({
    required this.user_image,
    required this.user_nickname,
    required this.user_id,
    required this.user_password,
    required this.user_phone,
    required this.user_email,

  });
  

  factory Myinfomation.fromMap(Map<String, dynamic>map){
    return Myinfomation(
      user_image: map['user_image'] ?? '', 
      user_nickname: map['user_nickname'] ?? '', 
      user_id: map['user_id'] ?? '', 
      user_password: map['user_password'] ?? '', 
      user_phone: map['user_phone'] ?? '', 
      user_email: map['user_email'] ?? '');
  }

  Map<String, dynamic>toMap(){
    return{
    'user_image':user_image,
    'user_nickname':user_nickname,
    'user_id':user_id,
    'user_password':user_password,
    'user_phone':user_phone,
    'user_email':user_email,
    };
  }
}