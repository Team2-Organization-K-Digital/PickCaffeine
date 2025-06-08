import 'dart:convert';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pick_caffeine_app/model/Eunjun/purchase.dart';
import 'package:pick_caffeine_app/model/Eunjun/selected_menu.dart';
import 'package:pick_caffeine_app/vm/Eunjun/vm_handler_insertmenu.dart';
import 'package:http/http.dart' as http;

class VmHandlerPurchase extends VmHandlerInsertMenu {
  var purchaseNum = 0.obs;
  final RxList<SelectedMenu> shoppingMenus = <SelectedMenu>[].obs;
  final RxInt finalPrice = 0.obs;

  Future<void> fetchLastPurchase() async {
    final res = await http.get(Uri.parse('$baseUrl/select/maxpurchasenum'));
    final datas = json.decode(utf8.decode(res.bodyBytes));
    final String results = datas['results'][0].toString();
    if (results == "null") {
      purchaseNum.value =
          100000000000000 +
          (int.parse(DateFormat('yyyyMMddHHmmss').format(DateTime.now())));
    } else {
      purchaseNum.value =
          (((int.parse(results.substring(0, results.length - 14)) + 1) *
                  100000000000000) +
              (int.parse(DateFormat('yyyyMMddHHmmss').format(DateTime.now()))));
    }
  }

  Future<void> fetchShoppingMenus(int purchaseNum) async {
    final res = await http.get(
      Uri.parse('$baseUrl/select/shoppingmenu/${purchaseNum}'),
    );
    final datas = json.decode(utf8.decode(res.bodyBytes));
    if (datas['results'] != null) {
      final List results = datas['results'];
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
      shoppingMenus.value = returnResult;
    }
  }

  Future<void> updateSelectMenu(
    int selected_num,
    int selected_quantity,
    int total_price,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/update/selectMenu${selected_num}/quantity${selected_quantity}&totalprice${total_price}',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "selected_num": selected_num,
        "selected_quantity": selected_quantity,
        "total_price": total_price,
      }),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];

    return result;
  }

  Future<void> deleteSelctedMenu(int num) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete/selectedMenu/${num}'),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];

    return result;
  }

  Future<void> fetchFinalPrice(int purchaseNum) async {
    final res = await http.get(
      Uri.parse('$baseUrl/select/shoppingprice/${purchaseNum}'),
    );
    final datas = json.decode(utf8.decode(res.bodyBytes));
    if (datas['results'][0] == null) {
      finalPrice.value = 0;
    } else {
      final int results = datas['results'][0];
      finalPrice.value = results;
    }
  }

  Future<void> deletePurchase(int num) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete/purchase/${num}'),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];

    return result;
  }

  Future<void> insertPurhase(Purchase purchase) async {
    final url = Uri.parse("$baseUrl/insert/purchase");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(purchase.toMap()),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];

    return result;
  }
}
