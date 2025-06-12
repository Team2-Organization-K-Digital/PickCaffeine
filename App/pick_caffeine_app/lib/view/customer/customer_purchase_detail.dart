// 고객 주문내역 상세 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Purchase Detail Page (Customer)
  - Description   :
  - Author        : Jeong seoyun
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
import 'package:get_storage/get_storage.dart';
import 'package:pick_caffeine_app/vm/seoyun/vm_handler.dart';

class CustomerPurchaseDetail extends StatelessWidget {
  CustomerPurchaseDetail({super.key});

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final Order order = Get.find<Order>();
    final args = Get.arguments ?? '__';
    // order.fetchStore(box.read('login_Id'));
    // order.fetchDetailMenu(box.read('login_Id'), args[0].toString());

    order.fetchStore('11');
    order.fetchDetailMenu('11', args[0].toString());
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
                '주문 매장 ${args[2]}',
                style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                ),
              ),
              Text(
                '매장 연락처 ${args[3]}',
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
                      subtitle: Text('옵션 : ${item['option'] ?? '__'} '),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        Text(('${item['price']}원')),
                        SizedBox(width: 10),
                        Text(('${item['quantity']}개')),
                      ]),
                    );
                  },
                );
              }),
              Text('요청 사항'),
              Text('요청 사항 내용 : ${args[4]}'),
              Text('결제 금액'),
              Text(args[5].toString()),
            ],
          ),
        ),
      ),
    );
  }
}
