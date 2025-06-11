class UserInformation {
  final String user_id;
  final String user_nickname;
  final String user_password;
  final String user_phone;
  final String user_email;
  final String user_iamge;



  UserInformation({
    required this.user_id,
    required this.user_nickname,
    required this.user_password,
    required this.user_phone,
    required this.user_email,
    required this.user_iamge,


  });
  factory UserInformation.fromMap(Map<String, dynamic>map){
    return UserInformation(
      user_id: map['user_id']?? '', 
      user_nickname: map['user_nickname']?? '',
      user_password: map['user_password']?? '', 
      user_phone: map['user_phone']?? '', 
      user_email: map['user_email']?? '', 
      user_iamge: map['user_iamge']?? '',
      );
  }

    Map<String, dynamic>toMap(){
    return{
      'user_id': user_id, 
      'user_nickname': user_nickname,
      'user_password': user_password,
      'user_phone': user_phone ,
      'user_email': user_email,
      'user_iamge': user_iamge,
    };
  }
  
  
}