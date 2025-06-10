// 홈 페이지 (매장, review)
/*
// ----------------------------------------------------------------- //
  - title         : Review Home Page (Store)
  - Description   :
  - Author        : Gam Sung
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.05
  - package       :

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  :
// ----------------------------------------------------------------- //
*/

import 'package:flutter/material.dart';

class StoreHomeReview extends StatelessWidget {
  const StoreHomeReview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("리뷰보기"),),
    );
  }
}