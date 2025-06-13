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
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/vm/seoyun/vm_handler.dart';

class CustomerPurchaseDetail extends StatelessWidget {
  CustomerPurchaseDetail({super.key});

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final Order order = Get.find<Order>();
    final args = Get.arguments ?? '__';
    order.fetchStore(box.read('loginId'));
    order.fetchDetailMenu(box.read('loginId'), args[0].toString());

    // order.fetchStore('11');
    // order.fetchDetailMenu('11', args[0].toString());
    return Scaffold(
      appBar: AppBar(title: Text('주문 상세 정보'), backgroundColor: AppColors.white,),
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 주문 기본 정보 카드
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppColors.lightpick,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('주문 번호', args[0].toString()),
                      _buildInfoRow(
                        '주문 시간',
                        args[1].toString().substring(11, 16),
                      ),
                      _buildInfoRow('주문 매장', args[2]),
                      _buildInfoRow('매장 연락처', args[3].toString()),
                    ],
                  ),
                ),
              ),

              // SizedBox(height: 16),

              /// 메뉴 리스트 카드 , 요청사항
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppColors.lightpick,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '주문 메뉴',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),

                      Obx(() {
                        return ListView.separated(
                          itemCount: order.detailMenu.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          separatorBuilder: (_, __) => Divider(),
                          itemBuilder: (context, index) {
                            final item = order.detailMenu[index];
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item['menu']} (옵션: ${item['option'] ?? '없음'})',
                                  ),
                                ),
                                Text(
                                  '${item['quantity']}개  |  ${item['price']}원',
                                ),
                              ],
                            );
                          },
                        );
                      }),
                      Text(
                        '요청 사항',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(args[4] ?? '없음'),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10),

              /// 결제 금액 카드
              Card(
                color: Colors.brown[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '결제 금액',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${args[5]}원',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(width: 8),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis,)),
        ],
      ),
    );
  }
}
