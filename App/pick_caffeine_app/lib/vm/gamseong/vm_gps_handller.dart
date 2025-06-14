import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/model/gamseong/store_home.dart';
import 'package:pick_caffeine_app/view/customer/customer_store_detail.dart';
import 'package:pick_caffeine_app/vm/gamseong/image_vm.dart';

class VmGpsHandller extends ImageModel {
  final baseUrl = "http://127.0.0.1:8000/seong";
  var latitude = ''.obs;
  var longitude = ''.obs;
  var currentlat = 0.0.obs;
  var currentlong = 0.0.obs;
  var selectStore = "".obs;
  var likeStore = false.obs;
  final targetLocation = Rx<LatLng?>(null);
  var storeList = <StoreHome>[].obs; // 서버에서 받아올 매장 데이터
  RxList<dynamic> likeStores = <dynamic>[].obs;
  var markers = <Marker>[].obs; // 지도에 표시할 마커 리스트

  // 전체 매장 목록 빨강색
  Future<void> loadStoresAndMarkers() async {
    final box = GetStorage();
    final userId = box.read('loginId');

    try {
      final response = await http.get(Uri.parse("$baseUrl/selectstore"));
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (data['results'] != null) {
        if (likeStore.value) {
          // await fetchLikeStore(userId);
          // storeList.value =
          //     (data['results'] as List)
          //         .map((e) => StoreHome.fromMap(e)).where((element) {
          //           element.store_id ==
          //         },)
          //         .toList();
        } else {
          storeList.value =
              (data['results'] as List)
                  .map((e) => StoreHome.fromMap(e))
                  .toList();
        }

        markers.value =
            storeList.map((store) {
              return Marker(
                point: LatLng(store.store_latitude, store.store_longitude),
                width: 300,
                height: 200,
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.brown,
                        backgroundColor: AppColors.white,
                        textStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          inherit: true,
                        ),
                      ),
                      onPressed: () async {
                        await box.write('storeId', store.store_id);
                        Get.to(CustomerStoreDetail());
                      },
                      child: Text(store.store_name),
                    ),
                    Tooltip(
                      message: store.store_name,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.white,
                        child: Icon(Icons.coffee, color: AppColors.brown),
                      ),
                    ),
                  ],
                ),
              );
            }).toList();

        markers.add(
          Marker(
            point: LatLng(currentlat.value, currentlong.value),
            width: 100,
            height: 100,
            child: Column(
              children: [
                Tooltip(
                  message: '현 위치',
                  child: Icon(Icons.pin_drop, color: Colors.blue, size: 35),
                ),
              ],
            ),
          ),
        );
      } else {
        print("'results' 키가 응답에 없음");
      }
    } catch (e) {
      print(" 오류 발생: $e");
    }
  }

  Future<void> loadlikeMarkers(String userId) async {
    try {
      // 1. 찜한 매장 목록 요청
      final myStoreRes = await http.get(Uri.parse("$baseUrl/"));
      final myStoreData = jsonDecode(utf8.decode(myStoreRes.bodyBytes));

      final likedStoreIds =
          (myStoreData['results'] as List)
              .map((e) => e['store_id'].toString())
              .toList();

      // 3. 전체 매장 정보 요청
      final response = await http.get(Uri.parse("$baseUrl/selectstore"));
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      // 4. 필터링하여 마커 생성
      if (data['results'] != null) {
        storeList.value =
            (data['results'] as List)
                .map((e) => StoreHome.fromMap(e))
                .where((store) => likedStoreIds.contains(store.store_id))
                .toList();

        markers.value =
            storeList.map((store) {
              return Marker(
                point: LatLng(store.store_latitude, store.store_longitude),
                width: 50,
                height: 50,
                child: Tooltip(
                  message: store.store_name,
                  child: Icon(Icons.store, color: Colors.blue),
                ),
              );
            }).toList();
      } else {
        print("'results' 키가 응답에 없음");
      }
    } catch (e) {
      print("오류 발생: $e");
    }
  }

  Future<void> checkLocationPermission() async {
    // 위치권한확인
    LocationPermission permission = await Geolocator.checkPermission();

    // 권한이 없으면 요청하는것. 앱사용중 위치정보 허용하시겟습니까? 그거임
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    //권한이 영구적으로 거부된경우 종료한다.
    if (permission == LocationPermission.deniedForever) return;

    // 권한이 허용되었을경우 위처정보를 가져온다.
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      final position = await Geolocator.getCurrentPosition();
      currentlat.value = position.latitude;
      currentlong.value = position.longitude;
    }
  }

  Future<void> fetchLatLngFromAddress(String inputAddress) async {
    try {
      List<Location> locations = await locationFromAddress(inputAddress);
      if (locations.isNotEmpty) {
        double lat = locations.first.latitude;
        double lng = locations.first.longitude;

        latitude.value = lat.toString();
        longitude.value = lng.toString();
        targetLocation.value = LatLng(lat, lng);

        markers.add(
          Marker(
            point: LatLng(lat, lng),
            child: Icon(Icons.my_location, color: Colors.red, size: 30),
          ),
        );
      }
    } catch (e) {
      Get.snackbar("오류", "주소변환실패 : $e");
    }
  }

  Future<void> fetchLikeStore(String userId) async {
    likeStores.clear();
    final res = await http.get(
      Uri.parse('$baseUrl/select/likeStore/${userId}'),
    );

    final datas = await json.decode(utf8.decode(res.bodyBytes));
    final List results = datas['results'];

    for (int i = 0; i < results.length; i++) {
      likeStores.add(results[i]['my_store']);
    }
  }
}
