// 장바구니 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Shopping Cart Page
  - Description   :
  - Author        : Kim EunJun
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
import 'package:pick_caffeine_app/model/Eunjun/options.dart';
import 'package:pick_caffeine_app/model/Eunjun/purchase.dart';
import 'package:pick_caffeine_app/view/customer/customer_store_detail.dart';
import 'package:pick_caffeine_app/vm/eunjun/vm_handler_temp.dart';
import 'package:pick_caffeine_app/widget_class/utility/custom_text_field.dart';
import 'package:pick_caffeine_app/widget_class/utility/menu_utility.dart';

class CustomerShoppingCart extends StatelessWidget {
  CustomerShoppingCart({super.key});
  final handler = Get.find<VmHandlerTemp>();
  final box = GetStorage();
  final requestController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userId = box.read('loginId');
    final store = box.read('storeId');
    final purchaseNum = box.read('purchaseNum');
    handler.fetchShoppingMenus(purchaseNum);
    handler.fetchCustomerSelectMenu();
    handler.fetchMenuInCategory(store);
    handler.fetchFinalPrice(purchaseNum);

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Stack(
        children: [
          Obx(
            () => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50),

                  Center(
                    child: SizedBox(
                      height: 300,
                      width: 300,
                      child: MenuUtility().flutterMap(handler),
                    ),
                  ),
                  Divider(color: AppColors.lightbrownopac, thickness: 5),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      '주문상품정보',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brown,
                      ),
                    ),
                  ),
                  handler.shoppingMenus.isEmpty
                      ? SizedBox(
                        height: 200,
                        child: Center(child: Text('주문 메뉴가 없습니다.')),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: handler.shoppingMenus.length,
                        itemBuilder: (context, index) {
                          final shoppingMenu = handler.shoppingMenus[index];
                          final menu = handler.menus.where(
                            (m) => m.menu_num! == shoppingMenu.menu_num,
                          );
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20, 5, 15, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  menu.first.menu_name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 150,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  shoppingMenu
                                                      .selected_options!
                                                      .length,
                                              itemBuilder: (context, i) {
                                                final optionTitle =
                                                    shoppingMenu
                                                        .selected_options!
                                                        .keys
                                                        .toList();
                                                final optionName =
                                                    shoppingMenu
                                                        .selected_options!
                                                        .values
                                                        .toList();

                                                return Text(
                                                  '${optionTitle[i]} : ${optionName[i]}',
                                                );
                                              },
                                            ),
                                          ),
                                          Text(
                                            "${shoppingMenu.total_price} 원",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            if (shoppingMenu
                                                    .selected_quantity ==
                                                1) {
                                              await handler.deleteSelctedMenu(
                                                shoppingMenu.selected_num!,
                                              );
                                              await handler.fetchShoppingMenus(
                                                purchaseNum,
                                              );
                                              await handler
                                                  .fetchCustomerSelectMenu();
                                              await handler.fetchFinalPrice(
                                                purchaseNum,
                                              );
                                            } else {
                                              final oncePrice =
                                                  shoppingMenu.total_price /
                                                  shoppingMenu
                                                      .selected_quantity;

                                              await handler.updateSelectMenu(
                                                shoppingMenu.selected_num!,
                                                shoppingMenu.selected_quantity -
                                                    1,
                                                shoppingMenu.total_price
                                                        .toInt() -
                                                    oncePrice.toInt(),
                                              );
                                              await handler.fetchShoppingMenus(
                                                purchaseNum,
                                              );
                                              await handler
                                                  .fetchCustomerSelectMenu();
                                              await handler.fetchFinalPrice(
                                                purchaseNum,
                                              );
                                            }
                                          },
                                          icon:
                                              shoppingMenu.selected_quantity !=
                                                      1
                                                  ? Icon(
                                                    Icons
                                                        .indeterminate_check_box_outlined,
                                                    size: 40,
                                                    color: AppColors.brown,
                                                  )
                                                  : Icon(
                                                    Icons.delete_outline,
                                                    size: 40,
                                                    color: AppColors.brown,
                                                  ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                          ),
                                          child: SizedBox(
                                            width: 15,
                                            child: Text(
                                              shoppingMenu.selected_quantity
                                                  .toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            final oncePrice =
                                                shoppingMenu.total_price /
                                                shoppingMenu.selected_quantity;

                                            await handler.updateSelectMenu(
                                              shoppingMenu.selected_num!,
                                              shoppingMenu.selected_quantity +
                                                  1,
                                              shoppingMenu.total_price.toInt() +
                                                  oncePrice.toInt(),
                                            );
                                            await handler.fetchShoppingMenus(
                                              purchaseNum,
                                            );
                                            await handler
                                                .fetchCustomerSelectMenu();
                                            await handler.fetchFinalPrice(
                                              purchaseNum,
                                            );
                                          },
                                          icon: Icon(
                                            Icons.add_box_outlined,
                                            size: 40,
                                            color: AppColors.brown,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(250, 40),
                        backgroundColor: AppColors.lightbrown,
                        foregroundColor: AppColors.white,
                      ),
                      onPressed: Get.back,
                      child: Text(
                        '+ 메뉴 더 담기',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Divider(
                      color: AppColors.lightbrownopac,
                      thickness: 5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "요청 사항",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brown,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: CustomTextField(
                      label: '요청사항을 입력해주세요',
                      controller: requestController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Divider(
                      color: AppColors.lightbrownopac,
                      thickness: 5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "총 주문 금액",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brown,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('주문 금액 :'),
                        Text('${handler.finalPrice}원'),
                      ],
                    ),
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Positioned(
            left: 15,
            child: IconButton(
              onPressed: () {
                handler.selectedOptions.value = {};
                handler.selectedOptionsValue.value = {};
                handler.total.value = 0;
                handler.quantity.value = 1;
                Get.back();
              },
              icon: Icon(Icons.arrow_back_ios),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  '장바구니',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            child: Obx(
              () => Container(
                color: Theme.of(context).colorScheme.surface,
                width: MediaQuery.of(context).size.width,
                height: 100,
                child:
                    handler.shoppingMenus.isNotEmpty
                        ? Center(
                          child: Column(
                            children: [
                              Divider(
                                color: AppColors.lightbrownopac,
                                thickness: 5,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(250, 40),
                                  backgroundColor: AppColors.lightbrown,
                                  foregroundColor: AppColors.white,
                                ),
                                onPressed: () async {
                                  final purchase = Purchase(
                                    purchase_num: purchaseNum,
                                    user_id: userId,
                                    store_id: store,
                                    purchase_date: DateTime.now().toString(),
                                    purchase_request: requestController.text,
                                    purchase_state: 0,
                                  );
                                  await handler.insertPurhase(purchase);
                                  Get.back();
                                  Get.back();
                                },
                                child: Text('${handler.finalPrice} 원 주문하기'),
                              ),
                            ],
                          ),
                        )
                        : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
