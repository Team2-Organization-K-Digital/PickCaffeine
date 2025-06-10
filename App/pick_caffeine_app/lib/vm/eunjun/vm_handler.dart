import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/model/Eunjun/categories.dart';
import 'package:pick_caffeine_app/model/Eunjun/menu.dart';
import 'package:pick_caffeine_app/model/Eunjun/options.dart';

import 'package:http/http.dart' as http;
import 'package:pick_caffeine_app/vm/Eunjun/vm_handler_purchase.dart';

class VmHandlerMenu extends VmHandlerPurchase {
  var lastMenuNum = 0.obs;
  var categoryNum = 0.obs;
  final RxList<Menu> menus = <Menu>[].obs;
  final RxList<Categories> categories = <Categories>[].obs;
  final RxList<Categories> categoriesMenu = <Categories>[].obs;
  final RxList<Menu> selectMenu = <Menu>[].obs;
  final RxList<Options> optionList = <Options>[].obs;
  final RxList<String> optionTiltls = <String>[].obs;
  var categoryMenuAdd = "".obs;
  var clickedCategory = 0.obs;

  Future<void> insertMenu(Menu menu) async {
    final url = Uri.parse("$baseUrl/insert/Menu");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(menu.toMap()),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];

    return result;
  }

  Future<void> insertOption(Options option) async {
    final url = Uri.parse("$baseUrl/insert/menuoptions");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(option.toMap()),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];
    return result;
  }

  Future<void> fetchLastMenu(int storeid) async {
    lastMenuNum.value = 0;
    final res = await http.get(Uri.parse('$baseUrl/selectMax/${storeid}'));
    final data = json.decode(utf8.decode(res.bodyBytes));
    final List results = data['results'];
    lastMenuNum.value = results[0]['max'];
  }

  Future<void> fetchCategoryNum(String name, String storeid) async {
    categoryNum.value = 0;
    final res = await http.get(
      Uri.parse('$baseUrl/select/categoryNum/name=${name}store=${storeid}'),
    );
    final data = json.decode(utf8.decode(res.bodyBytes));
    final List results = data['results'];
    categoryNum.value = results[0]['num'];
  }

  Future<void> fetchCategory(String store) async {
    final res = await http.get(Uri.parse('$baseUrl/category/${store}'));
    final datas = json.decode(utf8.decode(res.bodyBytes));
    final List results = datas['results'];
    final List<Categories> returnResult =
        results.map((data) {
          return Categories(
            category_num: data['category_num'],
            store_id: data['store_id'],
            category_name: data['category_name'],
          );
        }).toList();
    categories.value = returnResult;
    categoriesMenu.value = returnResult;
  }

  Future<void> fetchMenuInCategory(String store) async {
    final res = await http.get(Uri.parse('$baseUrl/Menu/store=${store}'));
    final datas = json.decode(utf8.decode(res.bodyBytes));
    final List results = datas['results'];
    final List<Menu> returnResult =
        results.map((data) {
          return Menu(
            menu_num: data["menu_num"],
            category_num: data["category_num"],
            menu_name: data["menu_name"],
            menu_content: data["menu_content"],
            menu_price: data["menu_price"],
            menu_image: data["menu_image"] ?? "",
            menu_state: data["menu_state"],
          );
        }).toList();
    menus.value = returnResult;
  }

  Future<void> fetchSelectMenu(int menuNum) async {
    final res = await http.get(Uri.parse('$baseUrl/selectMenu/${menuNum}'));
    final datas = json.decode(utf8.decode(res.bodyBytes));
    final List results = datas['results'];
    final List<Menu> returnResult =
        results.map((data) {
          return Menu(
            menu_num: data["menu_num"],
            category_num: data["category_num"],
            menu_name: data["menu_name"],
            menu_content: data["menu_content"],
            menu_price: data["menu_price"],
            menu_image: data["menu_image"] ?? "",
            menu_state: data["menu_state"],
          );
        }).toList();
    selectMenu.value = returnResult;
  }

  Future<void> fetchOptions(int menuNum) async {
    final res = await http.get(Uri.parse('$baseUrl/selectOption/${menuNum}'));

    final datas = json.decode(utf8.decode(res.bodyBytes));
    final List results = datas['results'];
    final List<Options> returnResult =
        results.map((data) {
          return Options(
            option_num: data['option_num'],
            menu_num: data['menu_num'],
            option_title: data['option_title'],
            option_name: data['option_name'],
            option_price: data['option_price'],
            option_division: data['option_division'],
          );
        }).toList();

    for (int i = 0; i < returnResult.length; i++) {
      optionTiltls.add(returnResult[i].option_title);
    }
    optionTiltls.value = optionTiltls.toSet().toList();

    optionList.value = returnResult;
  }

  Future<void> deleteTitle(String title, int menuNum) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete/optionTitle/${title}'),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];
    fetchOptions(menuNum);
    return result;
  }

  Future<void> deleteOption(int optionNum) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete/option/${optionNum}'),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];

    return result;
  }

  Future<void> updateOption(Options option) async {
    final url = Uri.parse("$baseUrl/update/menuoptions");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(option.toMap()),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];
    return result;
  }

  Future<void> updateMenu(Menu menu) async {
    final url = Uri.parse("$baseUrl/update/menu");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(menu.toMap()),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];
    return result;
  }

  Future<void> updateAllMenu(Menu menu) async {
    final url = Uri.parse("$baseUrl/updateAll/menu");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(menu.toMap()),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];
    return result;
  }

  Future<void> insertCategory(Categories category) async {
    final url = Uri.parse("$baseUrl/insert/category");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(category.toMap()),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];
    return result;
  }

  Future<void> deleteCategory(int categoryNum) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete/category/${categoryNum}'),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];

    return result;
  }

  Future<void> updateMenuCategory(int originNum, int selectNum) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update/menuCategory'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"originNum": originNum, "selectNum": selectNum}),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];

    return result;
  }

  Future<void> updateMenuState(int originNum, int selectNum) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update/menuState'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"originNum": originNum, "selectNum": selectNum}),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];

    return result;
  }
}
