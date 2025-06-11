class Reviewmodel {
  final String user_nickname;
  final String user_image;
  final String review_date;
  final String review_content;
  final String review_state;
  final String review_image;

  Reviewmodel({
    required this.user_nickname,
    required this.user_image,
    required this.review_date,
    required this.review_content,
    required this.review_state,
    required this.review_image,

  });

  factory Reviewmodel.fromMap(Map<String, dynamic>map){
    return Reviewmodel(
      user_nickname: map['user_nickname'] ?? '',
      user_image: map['user_image']?? '',
      review_date: map['review_date'] ?? '', 
      review_content: map['review_content'] ?? '',  
      review_state: map['review_state'] ?? '', 
      review_image: map['review_image']?? '',
      );
  }
  Map<String, dynamic>toMap(){
    return{
      'user_nickname':user_nickname,
      'user_image':user_image,
      'review_date': review_date,
      'review_content':review_content,
      'review_state':review_state,
      'review_iamge':review_image
    };
  }

  
}