import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/model/Eunjun/store.dart';
import 'package:pick_caffeine_app/vm/eunjun/vm_handler.dart';
import 'package:http/http.dart' as http;

class VmHanderStore extends VmHandlerMenu {
  final RxList<Store> loginStore = <Store>[].obs;
  final RxList<MyStores> myStores = <MyStores>[].obs;
  final RxList<Widget> storeImages = <Widget>[].obs;
  var activeIndex = 0.obs;
  var fetchValue = false;

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
            store_address_detail: data['store_address_detail'],
            store_latitude: data['store_latitude'],
            store_longitude: data['store_longitude'],
            store_content: data['store_content'] ?? '',
            store_state: data['store_state'],
            store_business_num: data['store_business_num'],
            store_regular_holiday: data['store_regular_holiday'] ?? "",
            store_temporary_holiday: data['store_temporary_holiday'] ?? "",
            store_business_hour: data['store_business_hour'] ?? '',
            store_created_date: data['store_created_date'],
          );
        }).toList();
    loginStore.value = returnResult;
  }

  Future<void> fetchStoreImage(String storeId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/select/storeImage/${storeId}'),
    );
    final datas = json.decode(utf8.decode(res.bodyBytes));

    final List results = datas['results'];

    for (int i = 1; i < results.length; i++) {
      if (results[i] == null) {
        return;
      }
      storeImages.add(
        Image.memory(base64Decode(results[i]), fit: BoxFit.cover),
      );
    }
  }

  fetchStore(String storeId) async {
    if (fetchValue) {
      return;
    }
    await fetchStoreImage(storeId);
    await fetchLoginStore(storeId);
    fetchValue = true;
  }

  Future<void> fetchMyStores(String user_id) async {
    lastMenuNum.value = 0;
    final res = await http.get(
      Uri.parse('$baseUrl/select/mystores/${user_id}'),
    );
    final datas = json.decode(utf8.decode(res.bodyBytes));
    final List results = datas['results'];
    final List<MyStores> returnResults =
        results
            .map(
              (data) => MyStores(
                user_id: data[0],
                store_id: data[1],
                selected_date: data[2],
              ),
            )
            .toList();

    myStores.value = returnResults;
  }

  Future<void> insertMyStores(MyStores myStores) async {
    final url = Uri.parse("$baseUrl/insert/mystores");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(myStores.toMap()),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];

    return result;
  }

  Future<void> deleteMyStores(String store_id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete/mystores/${store_id}'),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];

    return result;
  }

  Future<void> updateStoreState(String store_id, int store_state) async {
    final url = Uri.parse(
      "$baseUrl/update/store${store_id}/state${store_state}",
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'store_id': store_id, 'store_state': store_state}),
    );
    final result = json.decode(utf8.decode(response.bodyBytes))['result'];
    return result;
  }
}
