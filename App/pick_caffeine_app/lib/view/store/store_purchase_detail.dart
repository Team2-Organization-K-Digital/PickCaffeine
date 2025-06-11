// 매장 주문내역 상세 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Purchase Detail Page (Store)
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

class StorePurchaseDetail extends StatelessWidget {
  StorePurchaseDetail({super.key});

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final Order order = Get.find<Order>();
    final args = Get.arguments ?? '__';
    order.fetchDetailMenuStore(box.read('login_Id'), args[0].toString());

    return Scaffold(
      appBar: AppBar(title: Text('주문 상세 정보', style: TextStyle(fontSize: 30),)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
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
                      fontSize: 30
                    ),
                  ),
                  Text(
                    '주문 시간 ${args[1].toString().substring(11, 16)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25
                    ),
                  ),
                ],
              ),
              Text(
                '고객ID : ${args[2]}',
                style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30
                ),
              ),
              Text(
                '고객 연락처 : ${args[3]}',
                style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30
                ),
                ),
                SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                  '메뉴',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                      fontSize: 30
                  ),
                  ), 
                  Text(
                    '수량',
                    style: TextStyle(
                    fontWeight: FontWeight.bold,
                      fontSize: 30
                  ),
                  )
                ],
              ),
          
              //////////////////////////////////////////////////////////////////
              Obx(() {
                return ListView.builder(
                  itemCount: order.detailMenuStore.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = order.detailMenuStore[index];
          
                    return ListTile(
                      title: Text(item['menu'], 
                      style: TextStyle(
                        fontSize: 25
                      )),
                      subtitle: Text('옵션 : ${item['option']}',
                      style: TextStyle(
                        fontSize: 25
                      )),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        Text('${item['price']}원',
                        style: TextStyle(
                        fontSize: 25
                      )),
                        SizedBox(width: 30),
                        Text('${item['quantity']}개',
                        style: TextStyle(
                        fontSize: 25
                      )),
                      ])
                    );
                  },
                );
              }),
              SizedBox(height: 20),
              Text('요청 사항 : ${args[4]}',
              style: TextStyle(
                    fontWeight: FontWeight.bold,
                      fontSize: 30
                  ),),
              SizedBox(height: 20),
              Text('결제 금액',
              style: TextStyle(
                    fontWeight: FontWeight.bold,
                      fontSize: 30
                  ),),
              Text('${args[5]} 원',
              style: TextStyle(
                    fontWeight: FontWeight.bold,
                      fontSize: 30
                  ),),
            ],
          ),
        ),
      ),
    );
  }
}
