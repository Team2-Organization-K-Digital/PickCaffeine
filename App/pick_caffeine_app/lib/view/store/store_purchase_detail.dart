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
    order.fetchDetailMenuStore(box.read('loginId'), args[0].toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text('주문 상세 정보', style: TextStyle(fontSize: 28)),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 주문번호 + 시간
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '주문 번호\n${args[0]}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                    ),
                    Text(
                      '주문 시간\n${args[1].toString().substring(11, 16)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // 고객정보
                Divider(thickness: 1.5, color: Colors.grey[400]),
                const SizedBox(height: 20),
                Text('고객 ID : ${args[2]}', style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 12),
                Text('고객 연락처 : ${args[3]}', style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 30),

                // 메뉴 & 수량 헤더
                Divider(thickness: 1.8, color: Colors.black),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('메뉴', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                    Text('가격 / 수량', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                  ],
                ),
                const SizedBox(height: 20),

                // 메뉴 리스트
                Obx(() {
                  return ListView.separated(
                    itemCount: order.detailMenuStore.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = order.detailMenuStore[index];
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['menu'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('옵션 : ${item['option']}', style: const TextStyle(fontSize: 20)),
                                  ],
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${item['price']}원 / ', style: const TextStyle(fontSize: 22)),
                                  Text('${item['quantity']}개', style: const TextStyle(fontSize: 20)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.grey),
                        ],
                      );
                    },
                  );
                }),
                const SizedBox(height: 40),

                // 요청사항
                Divider(thickness: 1.8, color: Colors.black),
                const SizedBox(height: 20),
                Text(
                  '요청 사항',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                ),
                const SizedBox(height: 14),
                Text('${args[4]}', style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 40),

                // 결제금액
                Divider(thickness: 1.8, color: Colors.black),
                const SizedBox(height: 20),
                Text(
                  '결제 금액',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                ),
                const SizedBox(height: 14),
                Text('${args[5]} 원', style: const TextStyle(fontSize: 28, color: Colors.green)),
              ],
            ),
          );
        },
      ),
    );
  }
}
