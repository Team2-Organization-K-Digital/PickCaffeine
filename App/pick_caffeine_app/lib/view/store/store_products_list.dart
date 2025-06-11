// 매장 제품 리스트 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Products List Page (Store)
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

import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pick_caffeine_app/app_colors.dart';

import 'package:pick_caffeine_app/view/store/store_add_product.dart';
import 'package:pick_caffeine_app/view/store/store_products_update.dart';
import 'package:pick_caffeine_app/vm/eunjun/vm_handler_temp.dart';
import 'package:pick_caffeine_app/widget_class/message/storemenuwidget.dart';
import 'package:pick_caffeine_app/widget_class/utility/menu_utility.dart';

class StoreProductsList extends StatelessWidget {
  StoreProductsList({super.key});
  final vmHandler = Get.find<VmHandlerTemp>();

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final storeId = box.read("storeId");
    final storeName = box.read("storeName");
    vmHandler.fetchMenuInCategory(storeId);
    vmHandler.fetchCategory(storeId);
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
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.arrow_back_ios),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: Text(
                  storeName,
                  style: TextStyle(color: AppColors.black, fontSize: 40),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
          Obx(() {
            return Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Storemenuwidget().categoryDialog(vmHandler, storeId);
                          vmHandler.fetchMenuInCategory(storeId);
                          vmHandler.fetchCategory(storeId);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '카테고리',
                              style: TextStyle(
                                fontSize: 25,
                                color: AppColors.black,
                              ),
                            ),
                            Text(
                              '설정',
                              style: TextStyle(
                                fontSize: 25,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      VerticalDivider(width: 2, thickness: 3),
                      vmHandler.categories.isEmpty
                          ? Center(child: Text('카테고리가 없습니다.'))
                          : Expanded(
                            child: ReorderableListView.builder(
                              onReorder: (oldIndex, newIndex) {
                                final item = vmHandler.categories.removeAt(
                                  oldIndex,
                                );
                                vmHandler.categories.insert(newIndex, item);
                              },
                              scrollDirection: Axis.horizontal,
                              itemCount: vmHandler.categories!.length + 1,
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
                                          fontSize: 25,
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
                                        print(vmHandler.categoriesMenu);
                                      },
                                      child: Text(
                                        category.category_name,
                                        style: TextStyle(
                                          fontSize: 25,
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
                      VerticalDivider(width: 5, thickness: 3),
                      IconButton(
                        onPressed: () {
                          vmHandler.clearImage();
                          if (vmHandler.categoryMenuAdd.isEmpty) {
                            Get.snackbar('경고', '카테고리를 선택해주세요.');
                            return;
                          }
                          Get.to(StoreAddProduct(), arguments: [storeId])!.then(
                            (_) {
                              vmHandler.categoryMenuAdd.value = "";
                              vmHandler.clickedCategory.value = 0;
                              vmHandler.fetchMenuInCategory(storeId);
                              vmHandler.fetchCategory(storeId);
                            },
                          );
                        },
                        icon: Icon(Icons.add, size: 50),
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
                                  left: 20,
                                  top: 5,
                                  bottom: 5,
                                ),
                                child: Text(
                                  category.category_name,
                                  style: TextStyle(
                                    fontSize: 60,
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
                              ? Text(
                                '메뉴가 없습니다.',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                              : ListView.builder(
                                padding: EdgeInsets.all(5),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: menusInCategory.length,
                                itemBuilder: (context, index) {
                                  final menu = menusInCategory[index];
                                  return Slidable(
                                    key: ValueKey(menu.menu_num!),
                                    endActionPane: ActionPane(
                                      motion: DrawerMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) async {
                                            final confirm =
                                                await showDialog<bool>(
                                                  context: context,
                                                  builder:
                                                      (_) => AlertDialog(
                                                        title: Text('삭제 확인'),
                                                        content: Text(
                                                          '정말로 이 메뉴를 삭제하시겠습니까?',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed:
                                                                () => Get.back(
                                                                  result: false,
                                                                ),
                                                            child: Text('취소'),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () => Get.back(
                                                                  result: true,
                                                                ),
                                                            child: Text('삭제'),
                                                          ),
                                                        ],
                                                      ),
                                                );

                                            if (confirm == true) {
                                              vmHandler.updateMenuState(
                                                menu.menu_num!,
                                                -1,
                                              );
                                              vmHandler.fetchMenuInCategory(
                                                storeId,
                                              );
                                              vmHandler.fetchCategory(storeId);
                                            }
                                          },
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
                                          label: '삭제',
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ],
                                    ),
                                    startActionPane: ActionPane(
                                      motion: ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) {
                                            if (menu.menu_state == -1) {
                                              return;
                                            }
                                            if (menu.menu_state == 0) {
                                              vmHandler.updateMenuState(
                                                menu.menu_num!,
                                                1,
                                              );
                                            } else {
                                              vmHandler.updateMenuState(
                                                menu.menu_num!,
                                                0,
                                              );
                                            }
                                            vmHandler.fetchMenuInCategory(
                                              storeId,
                                            );
                                            vmHandler.fetchCategory(storeId);
                                          },
                                          backgroundColor:
                                              menu.menu_state == 0
                                                  ? AppColors.lightbrown
                                                  : Colors.green,
                                          foregroundColor: Colors.white,
                                          icon:
                                              menu.menu_state == 0
                                                  ? Icons.block
                                                  : Icons.check_circle,
                                          label:
                                              menu.menu_state == 0
                                                  ? '품절'
                                                  : '판매재개',
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        Column(
                                          children: [
                                            GestureDetector(
                                              behavior:
                                                  HitTestBehavior.translucent,
                                              onTap: () {
                                                vmHandler.clearImage();
                                                Get.to(
                                                  StoreProductsUpdate(),
                                                  arguments: [
                                                    storeId,
                                                    category.category_name,
                                                    menu.menu_num!,
                                                  ],
                                                )!.then((value) {
                                                  vmHandler.fetchMenuInCategory(
                                                    storeId,
                                                  );
                                                  vmHandler.fetchCategory(
                                                    storeId,
                                                  );
                                                });
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: 500,
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
                                                              fontSize: 30,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
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
                                                                fontSize: 20,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${menu.menu_price.toString()} 원',
                                                            style: TextStyle(
                                                              fontSize: 25,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
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
                                                                fontSize: 20,
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
                                                      width: 200,
                                                      height: 200,
                                                      child: Image.memory(
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
                                    ),
                                  );
                                },
                              ),
                        ],
                      );
                    },
                  ),
                );
          }),
        ],
      ),
    );
  }
}
