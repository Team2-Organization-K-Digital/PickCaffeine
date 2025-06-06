import 'dart:convert';

import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:test_menu_update/model/menu.dart';
import 'package:test_menu_update/model/options.dart';
import 'package:test_menu_update/vm/menu.dart';

class VmHandlerInsertMenu extends StoreController {
  final baseUrl = "http://127.0.0.1:8000";
  var lastMenuNum = 0.obs;
  var categoryNum = 0.obs;

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
}
