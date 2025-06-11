import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:pick_caffeine_app/model/Eunjun/categories.dart';
import 'package:pick_caffeine_app/vm/eunjun/vm_handler_temp.dart';

class Storemenuwidget {
  categoryDialog(VmHandlerTemp handler, String store_id) {
    final addController = TextEditingController();
    List<Categories> allCategory = handler.categories.value;
    List<Categories> changeOption = allCategory;
    Get.defaultDialog(
      barrierDismissible: true,
      titlePadding: EdgeInsets.only(top: 20),
      title: "카테고리 목록",
      actions: [ElevatedButton(onPressed: () => Get.back(), child: Text('확인'))],
      content: Column(
        children: [
          SizedBox(
            height: 300,
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: handler.categories.length,
              itemBuilder: (context, index) {
                final category = handler.categories[index];
                return Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                    decoration: BoxDecoration(border: Border.all()),
                    height: 50,
                    width: 20,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Row(
                              children: [
                                Text("${index + 1}."),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(category.category_name),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              VerticalDivider(),
                              IconButton(
                                onPressed: () async {
                                  if (handler.categories.length == 1) {
                                    return;
                                  }
                                  if (handler.menus
                                      .where(
                                        (m) =>
                                            m.category_num ==
                                            category.category_num!,
                                      )
                                      .isNotEmpty) {
                                    Get.back();
                                    final change_name = category.category_name;
                                    final originNum = category.category_num!;
                                    changeOption.removeAt(index);
                                    Get.defaultDialog(
                                      titlePadding: EdgeInsets.only(top: 20),
                                      title: '카테고리 삭제',
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Get.back();
                                            Storemenuwidget().categoryDialog(
                                              handler,
                                              store_id,
                                            );
                                          },
                                          child: Text('취소'),
                                        ),
                                      ],
                                      content: Column(
                                        children: [
                                          Text(
                                            '$change_name에 속한 메뉴를 \n 변경할 카테고리를 선택해 주세요.',
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(
                                            height: 300,
                                            width: 300,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: changeOption.length,
                                              itemBuilder: (context, index) {
                                                final category =
                                                    changeOption[index];
                                                final selectNum =
                                                    category.category_num!;
                                                return Padding(
                                                  padding: const EdgeInsets.all(
                                                    3.0,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(),
                                                    ),
                                                    height: 50,
                                                    width: 20,
                                                    child: Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  left: 15,
                                                                ),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  "${index + 1}.",
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets.only(
                                                                        left:
                                                                            20,
                                                                      ),
                                                                  child: Text(
                                                                    category
                                                                        .category_name,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              VerticalDivider(),
                                                              IconButton(
                                                                onPressed: () async {
                                                                  await handler
                                                                      .updateMenuCategory(
                                                                        originNum,
                                                                        selectNum,
                                                                      );
                                                                  await handler
                                                                      .deleteCategory(
                                                                        originNum,
                                                                      );
                                                                  await handler
                                                                      .fetchMenuInCategory(
                                                                        store_id,
                                                                      );
                                                                  await handler
                                                                      .fetchCategory(
                                                                        store_id,
                                                                      );
                                                                  Get.back();
                                                                  Storemenuwidget()
                                                                      .categoryDialog(
                                                                        handler,
                                                                        store_id,
                                                                      );
                                                                },
                                                                icon: Icon(
                                                                  Icons.check,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    await handler.deleteCategory(
                                      category.category_num!,
                                    );
                                    await handler.fetchMenuInCategory(store_id);
                                    await handler.fetchCategory(store_id);
                                    Get.back();
                                    Storemenuwidget().categoryDialog(
                                      handler,
                                      store_id,
                                    );
                                  }
                                },
                                icon: Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Column(
            children: [
              Divider(),
              Text('카테고리 추가 '),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: SizedBox(
                      height: 30,
                      width: 200,
                      child: TextField(
                        controller: addController,
                        decoration: InputDecoration(hintText: '카테고리 이름'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: IconButton(
                      onPressed: () async {
                        if (addController.text.isNotEmpty) {
                          final category = Categories(
                            store_id: store_id,
                            category_name: addController.text,
                          );
                          await handler.insertCategory(category);
                          await handler.fetchMenuInCategory(store_id);
                          await handler.fetchCategory(store_id);
                          Get.back();
                          Storemenuwidget().categoryDialog(handler, store_id);
                        }
                      },
                      icon: Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
