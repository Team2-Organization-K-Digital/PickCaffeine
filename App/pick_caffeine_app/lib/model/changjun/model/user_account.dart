class UserAccount {
  final String userId;
  final String userNickname;
  final String userPW;
  final String userPhone;
  final String userEmail;
  final String userGender;

  UserAccount(
    {
      required this.userId,
      required this.userNickname,
      required this.userPW,
      required this.userPhone,
      required this.userEmail,
      required this.userGender
    }
  );
// ----------------------------------------- //
factory UserAccount.fromMap(Map<String, dynamic> map){
  return UserAccount(
    userId: map['userId'], 
    userNickname: map['userNickname'], 
    userPW: map['userPW'], 
    userPhone: map['userPhone'], 
    userEmail: map['userEmail'],
    userGender: map['userGender']
  );
}
// ----------------------------------------- //
}