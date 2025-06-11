// class Myinfomation {
//   final user_id;
//   final user_nickname;
//   final user_phone;
//   final user_image;
//   final List<Review> reviews;

// Myinfomation({

//   required this.user_id,
//   required this.user_nickname,
//   required this.user_phone,
//   required this.user_image,
//   required this.reviews,
// });

// factory myinfomation.fromMap(Map<String, dynamic>map)(){
//   return Myinfomation(
//     user_id: user_id, 
//     user_nickname: user_nickname, 
//     user_phone: user_phone, 
//     user_image: user_image, 
//     reviews: (map['reviews'] as List)
//           .map((e) => Reviews.fromMap(e))
//           .toList()
//           );
// }
// }

// class Review{
//   final review_num;
//   final review_content;
//   final review_iamge;
//   final review_state;
//   final review_date;

//   factory Review.fromMap(Map<String, dynamic>map){
//     return Review(
//       review_num:map['review_id']

//     )
//   }
// }