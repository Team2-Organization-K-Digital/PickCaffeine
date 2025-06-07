import 'dart:convert';

import 'package:get/get.dart';
import 'package:pick_caffeine_app/model/Eunjun/store.dart';
import 'package:pick_caffeine_app/vm/Eunjun/vm_handler.dart';
import 'package:http/http.dart' as http;

class VmHanderStore extends VmHandlerMenu {
  final RxList<Store> loginStore = <Store>[].obs;

  Future<void> fetchLoginStore(String storeid) async {
    final res = await http.get(Uri.parse('$baseUrl/select/store/${storeid}'));
    final datas = json.decode(utf8.decode(res.bodyBytes));
    final List results = datas['results'];
    final List<Store> returnResult =
        results.map((data) {
          return Store(
            store_id: data['store_id'],
            store_password: data['store_password'],
            store_name: data['store_name'],
            store_phone: data['store_phone'],
            store_address: data['store_address'],
            store_addressdetail: data['store_address_detail'],
            store_latitude: data['store_latitude'],
            store_longitude: data['store_longitude'],
            store_content: data['store_content'] ?? '',
            store_state: data['store_state'],
            store_business_num: data['store_business_num'],
            store_regular_hoilday: data['store_regular_hoilday'] ?? "",
            store_temporary_holiday: data['store_temporary_holiday'] ?? "",
            store_business_hour: data['store_business_hour'] ?? '',
            store_created_date: data['store_created_date'],
          );
        }).toList();
    loginStore.value = returnResult;
  }
}
