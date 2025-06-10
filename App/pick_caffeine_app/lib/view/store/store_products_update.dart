// 매장 제품 수정 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Products Upadete Page (Store)
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
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pick_caffeine_app/model/Eunjun/menu.dart';
import 'package:pick_caffeine_app/model/Eunjun/options.dart';
import 'package:pick_caffeine_app/vm/Eunjun/vm_handler_temp.dart';

class StoreProductsUpdate extends StatelessWidget {
  StoreProductsUpdate({super.key});
  final menunamecontroller = TextEditingController();
  final menupricecontroller = TextEditingController();
  final menucontentcontroller = TextEditingController();
  final editNameController = TextEditingController();
  final editPriceController = TextEditingController();
  final menuProvier = Get.find<VmHandlerTemp>();

  @override
  Widget build(BuildContext context) {
    menuProvier.optionTiltls.clear();
    menuProvier.clearAll();
    final value = Get.arguments;
    final storeId = value[0];
    final category = value[1];
    final menu_num = value[2];

    menuProvier.fetchSelectMenu(menu_num);
    menuProvier.fetchOptions(menu_num);

    return Scaffold(
      appBar: AppBar(title: Text("메뉴 업데이트 페이지")),
      body: SingleChildScrollView(
        child: Obx(() {
          if (menuProvier.selectMenu.isEmpty) {
            return Center(child: CircularProgressIndicator());
          } else {
            final sMenu = menuProvier.selectMenu[0];
            menunamecontroller.text = sMenu.menu_name;
            menupricecontroller.text = sMenu.menu_price.toString();
            menucontentcontroller.text = sMenu.menu_content;
            return Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap:
                        () => menuProvier.getImageFromGallery(
                          ImageSource.gallery,
                        ),
                    child: Container(
                      height: 200,
                      width: 200,
                      color: Colors.grey,
                      child:
                          menuProvier.imageFile.value == null
                              ? Image.memory(
                                base64Decode(
                                  menuProvier.selectMenu[0].menu_image,
                                ),
                              )
                              : Image.file(
                                File(menuProvier.imageFile.value!.path),
                              ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, right: 30),
                      child: Text('카테고리 : $category'),
                    ),
                  ],
                ),
                TextField(
                  controller: menunamecontroller,
                  decoration: InputDecoration(hintText: '메뉴 이름을 입력하세요'),
                ),
                TextField(
                  controller: menupricecontroller,
                  decoration: InputDecoration(hintText: '메뉴 가격을 입력하세요'),
                ),
                TextField(
                  controller: menucontentcontroller,
                  decoration: InputDecoration(hintText: '메뉴 설명을 입력하세요'),
                  maxLines: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        menuProvier.addTitle();
                      },
                      child: Text('옵션 타이틀 추가'),
                    ),
                    VerticalDivider(
                      color: Colors.black,
                      indent: 5,
                      endIndent: 5,
                    ),
                  ],
                ),
                Divider(color: Colors.black),
                SizedBox(height: 10),
                menuProvier.optionList.isNotEmpty
                    ? Obx(
                      () => ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: menuProvier.optionTiltls.length,
                        itemBuilder: (context, i) {
                          final optionTitle = menuProvier.optionTiltls[i];
                          final options =
                              menuProvier.optionList
                                  .where((o) => o.option_title == optionTitle)
                                  .toList();
                          if (menuProvier.updateSelected.length !=
                              menuProvier.optionTiltls.length) {
                            menuProvier.updateSelected.value = List.generate(
                              menuProvier.optionTiltls.length,
                              (_) => false,
                            );
                          }
                          final updateValue = menuProvier.updateSelected[i];
                          return Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 250,
                                      child: Text(optionTitle),
                                    ),
                                    Obx(
                                      () => Checkbox(
                                        value: menuProvier.updateSelected[i],
                                        onChanged: (value) {
                                          menuProvier.updateSelected[i] =
                                              value!;
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        menuProvier.deleteTitle(
                                          optionTitle.toString(),
                                          menu_num,
                                        );
                                        menuProvier.optionTiltls.removeAt(i);
                                        menuProvier
                                            .updateSelected
                                            .value = List.generate(
                                          menuProvier.optionTiltls.length,
                                          (_) => false,
                                        );
                                      },
                                      icon: Icon(Icons.delete),
                                    ),
                                  ],
                                ),

                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final option = options[index];

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children:
                                          "${option.option_title}$index" ==
                                                  menuProvier.editIndex.value
                                              ? [
                                                SizedBox(
                                                  width: 200,
                                                  child: TextField(
                                                    controller:
                                                        editNameController,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          option.option_name,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 80,
                                                  child: TextField(
                                                    controller:
                                                        editPriceController,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          '${option.option_price}원',
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () async {
                                                    await updateOptionAction(
                                                      option.option_num!,
                                                      menu_num,
                                                      option.option_title,
                                                      updateValue,
                                                    );
                                                    menuProvier
                                                        .editIndex
                                                        .value = "";
                                                    menuProvier.fetchOptions(
                                                      menu_num,
                                                    );
                                                    editNameController.clear();
                                                    editPriceController.clear();
                                                  },
                                                  icon: Icon(Icons.check),
                                                  color: Colors.green,
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    menuProvier.deleteOption(
                                                      option.option_num!,
                                                    );
                                                    menuProvier
                                                        .editIndex
                                                        .value = "";
                                                    menuProvier.fetchOptions(
                                                      menu_num,
                                                    );
                                                  },
                                                  icon: Icon(Icons.remove),
                                                  color: Colors.red,
                                                ),
                                              ]
                                              : [
                                                Text(option.option_name),
                                                Text("${option.option_price}원"),
                                                IconButton(
                                                  onPressed: () async {
                                                    menuProvier
                                                            .editIndex
                                                            .value =
                                                        "${option.option_title}$index";
                                                    menuProvier.fetchOptions(
                                                      menu_num,
                                                    );
                                                  },
                                                  icon: Icon(Icons.edit),
                                                ),
                                              ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                    : Text(""),
                Obx(
                  () => ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: menuProvier.titleControllers.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 250,
                                  child: TextField(
                                    controller: menuProvier.titleControllers[i],
                                    decoration: InputDecoration(
                                      hintText: '옵션 타이틀 입력',
                                    ),
                                  ),
                                ),
                                Obx(
                                  () => Checkbox(
                                    value: menuProvier.selected[i],
                                    onChanged: (value) {
                                      menuProvier.selected[i] = value!;
                                    },
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    menuProvier.removeTitle(i);
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                              ],
                            ),

                            Obx(
                              () => ListView.builder(
                                padding: EdgeInsets.all(0),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount:
                                    menuProvier.optionControllers[i].length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        child: TextField(
                                          controller:
                                              menuProvier
                                                  .optionControllers[i][index],
                                          decoration: InputDecoration(
                                            labelText: '옵션 이름 입력',
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 80,
                                        child: TextField(
                                          controller:
                                              menuProvier
                                                  .optPriceControllers[i][index],
                                          decoration: InputDecoration(
                                            labelText: '옵션 가격(원)',
                                            labelStyle: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),

                                      IconButton(
                                        onPressed: () {
                                          menuProvier.removeOption(i, index);
                                        },

                                        icon: Icon(Icons.remove),
                                        color: Colors.red,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                menuProvier.addOption(i);
                              },
                              child: Text("+ 옵션 추가"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await menuProvier.fetchCategoryNum(category, storeId);
                    if (menunamecontroller.text.isNotEmpty &&
                        menupricecontroller.text.isNotEmpty) {
                      await update();
                    } else {
                      Get.snackbar("오류", "메뉴 이름과 가격을 입력해주세요.");
                    }
                    menuProvier.clearAll();
                    menuProvier.fetchSelectMenu(menu_num);
                    menuProvier.fetchOptions(menu_num);
                    Get.back();
                  },
                  child: Text("메뉴 수정"),
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  update() async {
    Uint8List getImage = base64Decode(menuProvier.selectMenu[0].menu_image);
    if (menuProvier.imageFile.value != null) {
      File imageFile1 = File(menuProvier.imageFile.value!.path);
      getImage = await imageFile1.readAsBytes();
    }

    String base64Image = base64Encode(getImage);
    final menu = Menu(
      menu_num: menuProvier.selectMenu[0].menu_num!,
      category_num: menuProvier.categoryNum.value,
      menu_name: menunamecontroller.text,
      menu_content: menucontentcontroller.text,
      menu_price: int.parse(menupricecontroller.text),
      menu_image: base64Image,
      menu_state: menuProvier.selectMenu[0].menu_state,
    );
    if (menuProvier.imageFile.value == null) {
      await menuProvier.updateMenu(menu);
    } else {
      await menuProvier.updateAllMenu(menu);
    }
    for (
      int optLength = 0;
      optLength < menuProvier.optionControllers.length;
      optLength++
    ) {
      if (menuProvier.titleControllers[optLength].value.text.isNotEmpty) {
        for (
          int op = 0;
          op < menuProvier.optionControllers[optLength].length;
          op++
        ) {
          if (menuProvier.optionControllers[optLength][op].value.text.isEmpty) {
            return Get.snackbar("경고", "옵션 이름을 입력하세요");
          }
          final option = Options(
            menu_num: menuProvier.selectMenu[0].menu_num!,
            option_title: menuProvier.titleControllers[optLength].value.text,
            option_name: menuProvier.optionControllers[optLength][op].text,
            option_price:
                menuProvier.optPriceControllers[optLength][op].text.isNotEmpty
                    ? int.parse(
                      menuProvier.optPriceControllers[optLength][op].text,
                    )
                    : 0,
            option_division: menuProvier.selected[optLength] ? 0 : 1,
          );
          await menuProvier.insertOption(option);
        }
      } else {
        Get.snackbar("경고", "옵션 타이틀을 입력하세요");
      }
    }
  }

  updateOptionAction(int oNum, int menu_num, String title, bool select) async {
    if (editNameController.text.isNotEmpty) {
      final option = Options(
        option_num: oNum,
        menu_num: menu_num,
        option_title: title,
        option_name: editNameController.text,
        option_price:
            editPriceController.text.isNotEmpty
                ? int.parse(editPriceController.text)
                : menuProvier.optionList
                    .where((o) => o.option_num == oNum)
                    .first
                    .option_price,
        option_division: select ? 1 : 0,
      );
      await menuProvier.updateOption(option);
    }
  }
}
