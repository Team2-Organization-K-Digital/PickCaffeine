// 매장 메뉴 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Products List Page (Customr)
  - Description   :
  - Author        : Kim EunJun
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.07
  - package       :

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  :
// ----------------------------------------------------------------- //
*/
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/view/customer/customer_product_options.dart';
import 'package:pick_caffeine_app/view/customer/customer_shopping_cart.dart';
import 'package:pick_caffeine_app/view/store/store_add_product.dart';
import 'package:pick_caffeine_app/view/store/store_products_update.dart';
import 'package:pick_caffeine_app/vm/eunjun/vm_handler_temp.dart';
import 'package:pick_caffeine_app/widget_class/message/storemenuwidget.dart';
import 'package:pick_caffeine_app/widget_class/utility/menu_utility.dart';

class CustomerProductsList extends StatelessWidget {
  CustomerProductsList({super.key});
  final vmHandler = Get.find<VmHandlerTemp>();

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final storeId = box.read("storeId");
    final storeName = box.read("storeName");
    final purchaseNum = box.read('purchaseNum');
    vmHandler.clickedCategory.value = -1;

    vmHandler.fetchMenuInCategory(storeId);
    vmHandler.fetchCategory(storeId);
    vmHandler.fetchCustomerSelectMenu();
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 80),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: IconButton(
                  onPressed: () {
                    vmHandler.deletePurchase(purchaseNum);
                    Get.back();
                  },
                  icon: Icon(Icons.arrow_back_ios),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: Text(
                  storeName,
                  style: TextStyle(color: AppColors.black, fontSize: 25),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
          Obx(() {
            return Row(
              children: [
                SizedBox(
                  width: 400,
                  height: 60,
                  child: Row(
                    children: [
                      SizedBox(width: 20),
                      vmHandler.categories.isEmpty
                          ? Center(child: Text('카테고리가 없습니다.'))
                          : Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: vmHandler.categories.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      5,
                                      10,
                                      2,
                                      10,
                                    ),
                                    child: TextButton(
                                      style: ElevatedButton.styleFrom(
                                        surfaceTintColor: AppColors.lightbrown,
                                        backgroundColor:
                                            vmHandler.clickedCategory.value !=
                                                    index
                                                ? null
                                                : AppColors.brown,
                                        shape: ContinuousRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        vmHandler.categoryMenuAdd.value = "";
                                        vmHandler.clickedCategory.value = index;
                                        await vmHandler.fetchMenuInCategory(
                                          storeId,
                                        );
                                        await vmHandler.fetchCategory(storeId);
                                      },
                                      child: Text(
                                        '전체 메뉴',
                                        style: TextStyle(
                                          color:
                                              vmHandler.clickedCategory.value !=
                                                      index
                                                  ? AppColors.black
                                                  : AppColors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  final category =
                                      vmHandler.categories![index - 1];

                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      2,
                                      10,
                                      2,
                                      10,
                                    ),
                                    child: TextButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            vmHandler.clickedCategory.value !=
                                                    index
                                                ? null
                                                : AppColors.brown,

                                        shape: ContinuousRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        await vmHandler.fetchMenuInCategory(
                                          storeId,
                                        );
                                        await vmHandler.fetchCategory(storeId);
                                        vmHandler.categoryMenuAdd.value =
                                            category.category_name;
                                        vmHandler.categoriesMenu.value =
                                            vmHandler.categories.value;
                                        vmHandler.categoriesMenu.value =
                                            vmHandler.categoriesMenu
                                                .where(
                                                  (c) =>
                                                      c.category_name ==
                                                      category.category_name,
                                                )
                                                .toList();
                                        vmHandler.clickedCategory.value = index;
                                      },
                                      child: Text(
                                        category.category_name,
                                        style: TextStyle(
                                          color:
                                              vmHandler.clickedCategory.value !=
                                                      index
                                                  ? AppColors.black
                                                  : AppColors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            );
          }),
          Divider(),
          Obx(() {
            return vmHandler.categoriesMenu.isEmpty
                ? Center(child: Text('카테고리가 없습니다.'))
                : Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(0),
                    itemCount: vmHandler.categoriesMenu.length,
                    itemBuilder: (context, i) {
                      final category = vmHandler.categoriesMenu[i];
                      final menusInCategory =
                          vmHandler.menus
                              .where(
                                (c) => c.category_num == category.category_num!,
                              )
                              .toList();
                      return Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 5,
                                  left: 20,
                                  bottom: 5,
                                ),
                                child: Text(
                                  category.category_name,
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: AppColors.brown,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Divider(
                                thickness: 5,
                                color: AppColors.lightbrown.withAlpha(80),
                              ),
                            ],
                          ),
                          menusInCategory.isEmpty
                              ? Text('메뉴가 없습니다.')
                              : ListView.builder(
                                padding: EdgeInsets.all(5),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: menusInCategory.length,
                                itemBuilder: (context, index) {
                                  final menu = menusInCategory[index];
                                  return Stack(
                                    children: [
                                      Column(
                                        children: [
                                          GestureDetector(
                                            behavior:
                                                HitTestBehavior.translucent,
                                            onTap: () async {
                                              vmHandler.total.value =
                                                  menu.menu_price;

                                              await Get.to(
                                                CustomerProductOptions(),
                                                arguments: [
                                                  category.category_name,
                                                  menu.menu_num!,
                                                ],
                                              )!.then(
                                                (value) =>
                                                    vmHandler
                                                        .fetchCustomerSelectMenu(),
                                              );
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: 200,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          25.0,
                                                        ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          menu.menu_name,

                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                top: 2,
                                                                bottom: 8,
                                                              ),
                                                          child: Text(
                                                            menu.menu_content,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${menu.menu_price.toString()} 원',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                top: 2,
                                                              ),
                                                          child: Text(
                                                            '주문수 : ',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 25,
                                                      ),
                                                  child: SizedBox(
                                                    width: 95,
                                                    height: 95,
                                                    child:
                                                        menu.menu_image.isEmpty
                                                            ? null
                                                            : Image.memory(
                                                              base64Decode(
                                                                menu.menu_image,
                                                              ),
                                                            ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(indent: 20, endIndent: 20),
                                        ],
                                      ),
                                      menu.menu_state == 1
                                          ? MenuUtility().unsaleContainer()
                                          : Text(''),
                                    ],
                                  );
                                },
                              ),
                          SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                );
          }),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.lightbrown,
        onPressed: () {
          Get.to(CustomerShoppingCart());
        },
        child: Icon(Icons.shopping_cart_outlined, color: AppColors.white),
      ),
    );
  }
}
