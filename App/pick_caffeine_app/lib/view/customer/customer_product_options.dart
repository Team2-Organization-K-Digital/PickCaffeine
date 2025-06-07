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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/model/Eunjun/selected_menu.dart';
import 'package:pick_caffeine_app/vm/Eunjun/vm_handler_temp.dart';

class CustomerProductOptions extends StatelessWidget {
  final vmHandler = Get.find<VmHandlerTemp>();

  @override
  Widget build(BuildContext context) {
    vmHandler.fetchSelectMenu(35);
    vmHandler.fetchOptions(35);
    vmHandler.fetchOptionTitle(35);
    return Scaffold(
      appBar: AppBar(
        title: Text('option test'),
        actions: [
          IconButton(
            onPressed: () {
              //
            },
            icon: Icon(Icons.arrow_right_alt),
          ),
        ],
      ),

      body: Obx(
        () => Column(
          children: [
            vmHandler.selectMenu.isEmpty
                ? Text('메뉴가 없습니다.')
                : SingleChildScrollView(
                  child: Obx(
                    () => Column(
                      children: [
                        Text(vmHandler.selectMenu[0].menu_name),
                        Text(vmHandler.selectMenu[0].menu_content),
                        Text(vmHandler.selectMenu[0].menu_price.toString()),
                        vmHandler.optionTitles.isNotEmpty
                            ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: vmHandler.optionTitles.length,
                              itemBuilder: (context, index) {
                                print(vmHandler.optionList[index]);
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
                                    children: [
                                      Text(title.option_title),
                                      Divider(color: Colors.black),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
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
                                                () => CheckboxListTile(
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
                                                      Text(option.option_name),
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
                                                        title.option_title;
                                                    final currentOption =
                                                        option.option_name;
                                                    if (value == true) {
                                                      vmHandler.optionList
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
                                                                vmHandler
                                                                        .totalPrice =
                                                                    vmHandler
                                                                        .totalPrice -
                                                                    option
                                                                        .option_price!;
                                                              }
                                                            }
                                                          });
                                                      vmHandler
                                                              .selectedOptionsValue[currentOption] =
                                                          true;
                                                      vmHandler
                                                              .selectedOptions[currentTitle] =
                                                          currentOption;
                                                      if (option.option_price !=
                                                          null) {
                                                        vmHandler.totalPrice =
                                                            vmHandler
                                                                .totalPrice +
                                                            option
                                                                .option_price!;
                                                      }
                                                    } else {
                                                      vmHandler
                                                              .selectedOptionsValue[currentOption] =
                                                          false;
                                                      vmHandler.selectedOptions
                                                          .remove(currentTitle);
                                                      if (option.option_price !=
                                                          null) {
                                                        vmHandler.totalPrice =
                                                            vmHandler
                                                                .totalPrice -
                                                            option
                                                                .option_price!;
                                                      }
                                                    }
                                                    print(
                                                      vmHandler.selectedOptions,
                                                    );
                                                    print(vmHandler.totalPrice);
                                                  },
                                                ),
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                            : Text('옵션없음'),
                      ],
                    ),
                  ),
                ),

            ElevatedButton(
              onPressed: () {
                insertAction();
                vmHandler.totalPrice.value = 0;
                vmHandler.selectedOptionsValue.value = {};
              },
              child: Text('주문'),
            ),
          ],
        ),
      ),
    );
  }

  insertAction() async {
    final total = vmHandler.totalPrice + vmHandler.menus[0].menu_price;

    final selectedMenu = SelectedMenu(
      menu_num: 1,
      selected_options: vmHandler.selectedOptions,
      total_price: total.value,
    );
    vmHandler.insertSelecMenu(selectedMenu);
  }
}
