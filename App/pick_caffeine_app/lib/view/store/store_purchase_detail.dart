// 매장 주문 상세내역 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Store Purchase Detail Page
  - Description   :
  - Author        : Jeong SeoYun
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.05
  - package       :

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  :
// ----------------------------------------------------------------- //
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/vm/oder_list.dart';

class StorePurchaseDetail extends StatelessWidget {
  const StorePurchaseDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final Order order = Get.find<Order>();
    order.fetchDetailMenu(11.toString(), 13.toString());
    order.fetchStore(11.toString(), 111.toString());
    order.fetchUser(10.toString());
    final args = Get.arguments ?? '__';
    return Scaffold(
      appBar: AppBar(title: Text('주문 상세 정보')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '주문 번호 ${args[0]}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                  Text(
                    '주문 시간 ${args[1].toString().substring(11, 16)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                ],
              ),
              Text(
                '고객ID ${order.userNickname}',
                style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                ),
              ),
              Text(
                '고객 연락처 ${order.userPhone}',
                style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                  '메뉴',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                      fontSize: 20
                  ),
                  ), 
                  Text(
                    '수량',
                    style: TextStyle(
                    fontWeight: FontWeight.bold,
                      fontSize: 20
                  ),
                  )
                ],
              ),
          
              //////////////////////////////////////////////////////////////////
              Obx(() {
                return ListView.builder(
                  itemCount: order.detailMenu.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = order.detailMenu[index];
          
                    return ListTile(
                      title: Text(item['menu']),
                      subtitle: Text('옵션 : ${item['option']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        Text(('${item['price']}원')),
                        SizedBox(width: 10),
                        Text(('${item['quantity']}개')),
                      ])
                    );
                  },
                );
              }),
              Text('요청 사항'),
              Text('요청 사항 내용 : ${args[2]}'),
              Text('결제 금액'),
              Text(args[3].toString()),
            ],
          ),
        ),
      ),
    );
  }
}
