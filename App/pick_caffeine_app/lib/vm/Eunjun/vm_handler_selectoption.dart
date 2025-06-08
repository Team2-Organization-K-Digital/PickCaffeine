import 'dart:convert';

import 'package:get/get.dart';
import 'package:pick_caffeine_app/model/Eunjun/menu.dart';

import 'package:http/http.dart' as http;
import 'package:pick_caffeine_app/model/Eunjun/options.dart';
import 'package:pick_caffeine_app/model/Eunjun/selected_menu.dart';
import 'package:pick_caffeine_app/vm/Eunjun/image_provider.dart';

class VmHandlerSelectoption extends ImageModel {
  final String baseUrl = "http://127.0.0.1:8000/eunjun";
  final RxList<Menu> menus = <Menu>[].obs;
  final RxList<OptionTitle> optionTitles = <OptionTitle>[].obs;
  final RxList<SelectedMenu> selectedMenu = <SelectedMenu>[].obs;
  final RxMap<String, String> selectedOptions = <String, String>{}.obs;
  var isLoading = false.obs;
  RxMap<String, bool> selectedOptionsValue = <String, bool>{}.obs;
  var totalPrice = 0.obs;
  var total = 0.obs;
  var quantity = 1.obs;

  Future<void> fetchOptionTitle(int num) async {
    try {
      isLoading.value = true;
      optionTitles.clear();
      final res = await http.get(
        Uri.parse('$baseUrl/select/optioncount/num=${num}'),
      );
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];

      final List<OptionTitle> returnResult =
          results.map((data) {
            return OptionTitle(option_title: data[0], option_division: data[1]);
          }).toList();
      optionTitles.value = returnResult;
    } catch (e) {
      Get.snackbar('error', "불러오기 실패2 : $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCustomerSelectMenu() async {
    isLoading.value = true;
    selectedMenu.clear();
    final res = await http.get(Uri.parse('$baseUrl/select/selecmenu'));
    final data = json.decode(utf8.decode(res.bodyBytes));
    final List results = data['results'];
    final List<SelectedMenu> returnResult =
        results.map((data) {
          Map<String, String> options = {};
          if (data[2] != null && data[2] is String) {
            final jsonList = jsonDecode(data[2]);
            for (final item in jsonList) {
              if (item is Map<String, dynamic>) {
                options.addAll(item.map((k, v) => MapEntry(k, v.toString())));
              }
            }
          }
          return SelectedMenu(
            selected_num: data[0],
            menu_num: data[1],
            selected_options: options,
            total_price: data[3],
            purchase_num: int.parse(data[4]),
            selected_quantity: data[5],
          );
        }).toList();

    // final List<SelectedMenu> returnResult =
    //     results.map((data) {
    //       return SelectedMenu(
    //         selected_num: data[0],
    //         menu_num: data[1],
    //         selected_options: data[2],
    //         total_price: data[3],
    //       );
    //     }).toList();
    selectedMenu.value = returnResult;
  }

  Future<void> fetchCustomerShoppingMenu(int purchaseNum) async {
    isLoading.value = true;
    selectedMenu.clear();
    final res = await http.get(Uri.parse('$baseUrl/select/selecmenu'));
    final data = json.decode(utf8.decode(res.bodyBytes));
    final List results = data['results'];
    final List<SelectedMenu> returnResult =
        results.map((data) {
          Map<String, String> options = {};
          if (data[2] != null && data[2] is String) {
            final jsonList = jsonDecode(data[2]);
            for (final item in jsonList) {
              if (item is Map<String, dynamic>) {
                options.addAll(item.map((k, v) => MapEntry(k, v.toString())));
              }
            }
          }
          return SelectedMenu(
            selected_num: data[0],
            menu_num: data[1],
            selected_options: options,
            total_price: data[3],
            purchase_num: int.parse(data[4]),
            selected_quantity: data[5],
          );
        }).toList();

    // final List<SelectedMenu> returnResult =
    //     results.map((data) {
    //       return SelectedMenu(
    //         selected_num: data[0],
    //         menu_num: data[1],
    //         selected_options: data[2],
    //         total_price: data[3],
    //       );
    //     }).toList();
    selectedMenu.value = returnResult;
  }

  Future<void> insertSelecMenu(SelectedMenu selectedMenu) async {
    final url = Uri.parse("$baseUrl/insert/selecedMenu");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(selectedMenu.toJson()),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];
    return result;
  }
}
