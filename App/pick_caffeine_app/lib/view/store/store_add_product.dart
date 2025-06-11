// 매장 제품 추가 페이지
/*
// ----------------------------------------------------------------- //
  - title         : Add Product Page
  - Description   :
  - Author        : 
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
import 'package:pick_caffeine_app/vm/eunjun/vm_handler_temp.dart';

class StoreAddProduct extends StatelessWidget {
  StoreAddProduct({super.key});
  final menunamecontroller = TextEditingController();
  final menupricecontroller = TextEditingController();
  final menucontentcontroller = TextEditingController();
  final menuProvier = Get.find<VmHandlerTemp>();

  @override
  Widget build(BuildContext context) {
    final value = Get.arguments;
    final storeId = value[0];
    final category = menuProvier.categoryMenuAdd.value;
    return Scaffold(
      appBar: AppBar(title: Text("메뉴 옵션 페이지")),
      body: SingleChildScrollView(
        child: Obx(
          () => Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap:
                      () =>
                          menuProvier.getImageFromGallery(ImageSource.gallery),
                  child: Container(
                    height: 200,
                    width: 200,
                    child:
                        menuProvier.imageFile.value == null
                            ? Center(
                              child: Icon(
                                Icons.add_box_outlined,
                                size: 200,
                                color: Colors.grey,
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
                maxLines: 5,
                controller: menucontentcontroller,
                decoration: InputDecoration(hintText: '메뉴 설명을 입력하세요'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: menuProvier.addTitle,
                    child: Text('옵션 타이틀 추가'),
                  ),
                  VerticalDivider(color: Colors.black, indent: 5, endIndent: 5),
                ],
              ),
              Divider(color: Colors.black),
              SizedBox(height: 10),
              ListView.builder(
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
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: menuProvier.optionControllers[i].length,
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
                        Divider(
                          thickness: 3,
                          color: Color(0xffD7A86E).withOpacity(0.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await menuProvier.fetchCategoryNum(category, storeId);
                  await insert();
                  menuProvier.clearAll();
                  menunamecontroller.clear();
                  menucontentcontroller.clear();
                  menupricecontroller.clear();
                  Get.back();
                },
                child: Text("메뉴 추가"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  insert() async {
    File imageFile1 = File(menuProvier.imageFile.value!.path);
    Uint8List getImage = await imageFile1.readAsBytes();
    String base64Image = base64Encode(getImage);

    final menu = Menu(
      category_num: menuProvier.categoryNum.value,
      menu_name: menunamecontroller.text,
      menu_content: menucontentcontroller.text,
      menu_price:
          menupricecontroller.text.isNotEmpty
              ? int.parse(menupricecontroller.text)
              : 0,
      menu_image: base64Image,
      menu_state: 0,
    );
    await menuProvier.insertMenu(menu);
    await menuProvier.fetchLastMenu(111);
    for (
      int optLength = 0;
      optLength < menuProvier.optionControllers.length;
      optLength++
    ) {
      for (
        int op = 0;
        op < menuProvier.optionControllers[optLength].length;
        op++
      ) {
        final option = Options(
          menu_num: menuProvier.lastMenuNum.value,
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
    }
  }
}
