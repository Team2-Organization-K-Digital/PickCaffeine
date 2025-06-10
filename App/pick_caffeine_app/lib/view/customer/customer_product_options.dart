// 메뉴 옵션 선택 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Menu Option Select Page
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/model/Eunjun/selected_menu.dart';
import 'package:pick_caffeine_app/view/customer/customer_shopping_cart.dart';
import 'package:pick_caffeine_app/vm/Eunjun/vm_handler_temp.dart';

class CustomerProductOptions extends StatelessWidget {
  final vmHandler = Get.find<VmHandlerTemp>();
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final value = Get.arguments;
    final menuNum = value[1];
    final menuCategory = value[0];
    vmHandler.fetchSelectMenu(menuNum);
    vmHandler.fetchOptions(menuNum);
    vmHandler.fetchOptionTitle(menuNum);
    vmHandler.totalPrice.value =
        vmHandler.total.value * vmHandler.quantity.value;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Stack(
        children: [
          Obx(
            () => SingleChildScrollView(
              child: Column(
                children: [
                  vmHandler.selectMenu.isEmpty
                      ? Text('메뉴가 없습니다.')
                      : Obx(() {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: SizedBox(
                                height: 300,
                                child: Image.memory(
                                  base64Decode(
                                    vmHandler.selectMenu[0].menu_image,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vmHandler.selectMenu[0].menu_name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 25,
                                      color: AppColors.brown,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      bottom: 10,
                                    ),
                                    child: Text(
                                      "${vmHandler.selectMenu[0].menu_price} 원",
                                      style: TextStyle(),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: SizedBox(
                                      width: 300,
                                      child: Text(
                                        vmHandler.selectMenu[0].menu_content,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 25),
                                  child: Text(
                                    '수량',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if (vmHandler.quantity.value != 1) {
                                            vmHandler.quantity.value -= 1;
                                          }
                                          vmHandler.totalPrice.value =
                                              vmHandler.total.value *
                                              vmHandler.quantity.value;
                                        },
                                        icon: Icon(
                                          Icons
                                              .indeterminate_check_box_outlined,
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
                                            vmHandler.quantity.value.toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          vmHandler.quantity.value += 1;
                                          vmHandler.totalPrice.value =
                                              vmHandler.total.value *
                                              vmHandler.quantity.value;
                                        },
                                        icon: Icon(
                                          Icons.add_box_outlined,
                                          size: 40,
                                          color: AppColors.brown,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            vmHandler.optionTitles.isNotEmpty
                                ? ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: vmHandler.optionTitles.length,
                                  itemBuilder: (context, index) {
                                    final titles = vmHandler.optionTitles;
                                    final title = titles[index];
                                    final options =
                                        vmHandler.optionList
                                            .where(
                                              (option) =>
                                                  option.option_title ==
                                                  title.option_title,
                                            )
                                            .toList();

                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 18,
                                                ),
                                                child: Text(
                                                  title.option_title,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 25,
                                                    color: AppColors.brown,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 18,
                                                ),
                                                child: Container(
                                                  height: 30,
                                                  width: 75,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        title.option_division ==
                                                                0
                                                            ? AppColors
                                                                .lightbrown
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .surface,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child:
                                                      title.option_division == 0
                                                          ? Center(
                                                            child: Text(
                                                              '필수옵션',
                                                              style: TextStyle(
                                                                color:
                                                                    AppColors
                                                                        .white,
                                                              ),
                                                            ),
                                                          )
                                                          : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            thickness: 5,
                                            color: AppColors.lightbrownopac,
                                          ),

                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: options.length,
                                            itemBuilder: (context, index) {
                                              final option = options[index];
                                              return vmHandler.isLoading.value
                                                  ? Center(child: Text(''))
                                                  :
                                                  // : Padding(
                                                  //   padding: const EdgeInsets.all(
                                                  //     4.0,
                                                  //   ),
                                                  //   child: Row(
                                                  //     children: [
                                                  //       Text(option.option_name),
                                                  //       Text('      '),
                                                  //       option.option_price != null
                                                  //           ? Text(
                                                  //             "${option.option_price}원",
                                                  //           )
                                                  //           : Text(''),
                                                  //       Checkbox(
                                                  //         value:
                                                  //             vmHandler
                                                  //                 .isLoading
                                                  //                 .value,
                                                  //         onChanged: (value) {
                                                  //           value =
                                                  //               vmHandler
                                                  //                   .isLoading
                                                  //                   .value;
                                                  //           if (value = true) {
                                                  //             vmHandler
                                                  //                     .selectedOptions[title
                                                  //                     .option_title] =
                                                  //                 option
                                                  //                     .option_name;
                                                  //           } else {
                                                  //             vmHandler
                                                  //                     .selectedOptions[title
                                                  //                     .option_title] =
                                                  //                 null;
                                                  //           } // 선택 해제
                                                  //           setState(() {}); // 선택
                                                  //         },
                                                  //       ),
                                                  //     ],
                                                  //   ),
                                                  // );
                                                  Obx(
                                                    () => Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        CheckboxListTile(
                                                          controlAffinity:
                                                              ListTileControlAffinity
                                                                  .leading,
                                                          checkboxShape:
                                                              CircleBorder(
                                                                side: BorderSide(
                                                                  color:
                                                                      AppColors
                                                                          .brown,
                                                                  width: 0.2,
                                                                ),
                                                              ),
                                                          activeColor:
                                                              AppColors.brown,
                                                          value:
                                                              vmHandler
                                                                  .selectedOptionsValue[option
                                                                  .option_name] ??
                                                              false,
                                                          title: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                option
                                                                    .option_name,
                                                              ),
                                                              option.option_price !=
                                                                      null
                                                                  ? Text(
                                                                    '+ ${option.option_price.toString()}원',
                                                                  )
                                                                  : Text(""),
                                                            ],
                                                          ),
                                                          onChanged: (value) {
                                                            final currentTitle =
                                                                title
                                                                    .option_title;
                                                            final currentOption =
                                                                option
                                                                    .option_name;

                                                            // if (value == true) {
                                                            //   vmHandler
                                                            //       .optionList
                                                            //       .where(
                                                            //         (o) =>
                                                            //             o.option_title ==
                                                            //             currentTitle,
                                                            //       )
                                                            //       .forEach((o) {
                                                            //         if (vmHandler
                                                            //                 .selectedOptionsValue[o
                                                            //                 .option_name] ==
                                                            //             true) {
                                                            //           vmHandler
                                                            //                   .selectedOptionsValue[o
                                                            //                   .option_name] =
                                                            //               false;
                                                            //           if (option
                                                            //                   .option_price !=
                                                            //               null) {
                                                            //             vmHandler.total =
                                                            //                 vmHandler.total -
                                                            //                 option.option_price!;
                                                            //             vmHandler
                                                            //                 .totalPrice
                                                            //                 .value = vmHandler.total.value *
                                                            //                 vmHandler.quantity.value;
                                                            //           }
                                                            //         }
                                                            //       });
                                                            //   vmHandler
                                                            //           .selectedOptionsValue[currentOption] =
                                                            //       true;
                                                            //   vmHandler
                                                            //           .selectedOptions[currentTitle] =
                                                            //       currentOption;
                                                            //   if (option
                                                            //           .option_price !=
                                                            //       null) {
                                                            //     vmHandler
                                                            //             .total =
                                                            //         vmHandler
                                                            //             .total +
                                                            //         option
                                                            //             .option_price!;
                                                            //     vmHandler
                                                            //             .totalPrice
                                                            //             .value =
                                                            //         vmHandler
                                                            //             .total
                                                            //             .value *
                                                            //         vmHandler
                                                            //             .quantity
                                                            //             .value;
                                                            //   }
                                                            // } else {
                                                            //   vmHandler
                                                            //           .selectedOptionsValue[currentOption] =
                                                            //       false;
                                                            //   vmHandler
                                                            //       .selectedOptions
                                                            //       .remove(
                                                            //         currentTitle,
                                                            //       );
                                                            //   vmHandler
                                                            //           .totalPrice
                                                            //           .value =
                                                            //       vmHandler
                                                            //           .total
                                                            //           .value *
                                                            //       vmHandler
                                                            //           .quantity
                                                            //           .value;
                                                            //   if (option
                                                            //           .option_price !=
                                                            //       null) {
                                                            //     vmHandler
                                                            //             .total =
                                                            //         vmHandler
                                                            //             .total -
                                                            //         option
                                                            //             .option_price!;
                                                            //     vmHandler
                                                            //             .totalPrice
                                                            //             .value =
                                                            //         vmHandler
                                                            //             .total
                                                            //             .value *
                                                            //         vmHandler
                                                            //             .quantity
                                                            //             .value;
                                                            //   }
                                                            // }
                                                            if (value == true) {
                                                              // 기존 체크 되어있는 것들 해제
                                                              vmHandler
                                                                  .optionList
                                                                  .where(
                                                                    (o) =>
                                                                        o.option_title ==
                                                                        currentTitle,
                                                                  )
                                                                  .forEach((o) {
                                                                    if (vmHandler
                                                                            .selectedOptionsValue[o
                                                                            .option_name] ==
                                                                        true) {
                                                                      vmHandler
                                                                              .selectedOptionsValue[o
                                                                              .option_name] =
                                                                          false;
                                                                      if (option
                                                                              .option_price !=
                                                                          null) {
                                                                        vmHandler.total =
                                                                            vmHandler.total -
                                                                            option.option_price!;
                                                                        vmHandler
                                                                            .totalPrice
                                                                            .value = vmHandler.total.value *
                                                                            vmHandler.quantity.value;
                                                                      }
                                                                    }
                                                                  });

                                                              // 현재 옵션 체크
                                                              vmHandler
                                                                      .selectedOptionsValue[currentOption] =
                                                                  true;
                                                              vmHandler
                                                                      .selectedOptions[currentTitle] =
                                                                  currentOption;
                                                              if (option
                                                                      .option_price !=
                                                                  null) {
                                                                vmHandler
                                                                        .total =
                                                                    vmHandler
                                                                        .total +
                                                                    option
                                                                        .option_price!;
                                                                vmHandler
                                                                        .totalPrice
                                                                        .value =
                                                                    vmHandler
                                                                        .total
                                                                        .value *
                                                                    vmHandler
                                                                        .quantity
                                                                        .value;
                                                              }
                                                            } else {
                                                              // option_division == 0 이면 최소 1개 유지
                                                              if (option
                                                                      .option_division ==
                                                                  0) {
                                                                // 현재 그룹에서 체크된 개수 확인
                                                                int
                                                                checkedCount =
                                                                    vmHandler
                                                                        .optionList
                                                                        .where(
                                                                          (o) =>
                                                                              o.option_title ==
                                                                              currentTitle,
                                                                        )
                                                                        .where(
                                                                          (o) =>
                                                                              vmHandler.selectedOptionsValue[o.option_name] ==
                                                                              true,
                                                                        )
                                                                        .length;

                                                                // 현재 1개만 체크 되어 있으면 해제 막음
                                                                if (checkedCount <=
                                                                    1) {
                                                                  // 그냥 return; 해서 해제 못하게
                                                                  return;
                                                                }
                                                              }

                                                              // 정상 해제 진행
                                                              vmHandler
                                                                      .selectedOptionsValue[currentOption] =
                                                                  false;
                                                              vmHandler
                                                                  .selectedOptions
                                                                  .remove(
                                                                    currentTitle,
                                                                  );
                                                              vmHandler
                                                                      .totalPrice
                                                                      .value =
                                                                  vmHandler
                                                                      .total
                                                                      .value *
                                                                  vmHandler
                                                                      .quantity
                                                                      .value;
                                                              if (option
                                                                      .option_price !=
                                                                  null) {
                                                                vmHandler
                                                                        .total =
                                                                    vmHandler
                                                                        .total -
                                                                    option
                                                                        .option_price!;
                                                                vmHandler
                                                                        .totalPrice
                                                                        .value =
                                                                    vmHandler
                                                                        .total
                                                                        .value *
                                                                    vmHandler
                                                                        .quantity
                                                                        .value;
                                                              }
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                                : Text(''),
                            SizedBox(height: 100),
                          ],
                        );
                      }),
                ],
              ),
            ),
          ),
          Positioned(
            left: 15,
            child: IconButton(
              onPressed: () {
                vmHandler.selectedOptions.value = {};
                vmHandler.selectedOptionsValue.value = {};
                vmHandler.total.value = 0;
                vmHandler.quantity.value = 1;
                Get.back();
              },
              icon: Icon(Icons.arrow_back_ios),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 80,
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(130, 40),
                          foregroundColor: AppColors.white,
                          backgroundColor: AppColors.lightbrown,
                        ),
                        onPressed: () {
                          insertAction();
                          vmHandler.quantity.value = 1;

                          vmHandler.selectedOptionsValue.value = {};
                          Get.back();
                          Get.to(CustomerShoppingCart());
                        },
                        child: Text(
                          '바로 주문',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Obx(
                      () => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(230, 40),

                          foregroundColor: AppColors.white,
                          backgroundColor: AppColors.brown,
                        ),
                        onPressed: () {
                          insertAction();
                          vmHandler.quantity.value = 1;
                          vmHandler.selectedOptionsValue.value = {};
                          Get.back();
                        },
                        child: Text(
                          '${vmHandler.totalPrice.value}원 장바구니에 담기',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  insertAction() async {
    final value = Get.arguments ?? "__";

    final selectedMenu = SelectedMenu(
      menu_num: value[1],
      selected_options: vmHandler.selectedOptions,
      total_price: vmHandler.totalPrice.toInt(),
      purchase_num: box.read('purchaseNum'),
      selected_quantity: vmHandler.quantity.value,
    );
    vmHandler.insertSelecMenu(selectedMenu);
  }
}
