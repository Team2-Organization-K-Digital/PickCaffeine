import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:pick_caffeine_app/model/changjun/model/stores.dart';
import 'package:pick_caffeine_app/vm/changjun/chart_handler.dart';

class StoreHandler extends ChartHandler {
  final RxList<Stores> storeData = <Stores>[].obs;
  final RxList<Stores> sortedByDistance = <Stores>[].obs;
  final RxList<Stores> sortedByReview = <Stores>[].obs;
  final RxList<Stores> sortedByZzim = <Stores>[].obs;
  // final box = GetStorage();
  final RxBool isLoading = false.obs;

  double currentLatitude = 0.0;
  double currentLongitude = 0.0;
  // ---------------------------------------------------------------------------- //
  // 전체 매장을 불러오는 함수
  Future<void> fetchStore() async {
    print('fetchStore 시작');
    isLoading.value = true;
    await getCurrentLocation();
    print('위치 정보 획득 완료');
    
    try {
      final res = await http.get(Uri.parse("$baseUrl/select/store"));
      print('서버 응답 받음');
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];
      // print(results);
      // print(currentLatitude);
      // print(currentLongitude);
      final List<Stores> returnResult =
          results.map((data) {
            double storeLat = data[2];
            double storeLng = data[3];
            // print(storeLat);
            // print(storeLng);
            double distanceKm = Distance().as(
              LengthUnit.Kilometer,
              LatLng(storeLat, storeLng),
              LatLng(currentLatitude, currentLongitude),
            );
            // print(distanceKm);
            // print(data["zzim"].runtimeType); 
            // print(data["review"].runtimeType); 
            // print(data["store_state"].runtimeType); 
            // print(data["image_1"]);
            // print(data["image_1"].runtimeType);
            return Stores(
              storeId: data[0].toString(),
              storeName: data[1],
              myStoreCount: data[4],
              reviewCount: data[5],
              distance: distanceKm,
              storeState: data[6],
              storeImage: data[7]
            );
          }).toList();
      // print(returnResult);

      storeData.value = returnResult;
      sortAllStoreLists();
      // print(storeData.value);
    } catch (e, stack) {
      print('Error fetching store: $e');
      print(stack);
    } finally {
      isLoading.value = false;
      print('fetchStore 종료');
    }
  }

  // ---------------------------------------------------------------------------- //
  // 사용자의 현재 위치를 불러오는 함수
  Future<void> getCurrentLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.snackbar("권한 오류", "위치 권한이 필요합니다.");
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    currentLatitude = position.latitude;
    currentLongitude = position.longitude;
  }

  // ---------------------------------------------------------------------------- //
  // list 를 각각의 조건에 맞게 정렬
  sortAllStoreLists() {
    sortedByDistance.value = [...storeData]
      ..sort((a, b) => a.distance.compareTo(b.distance));
    sortedByReview.value = [...storeData]
      ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    sortedByZzim.value = [...storeData]
      ..sort((a, b) => b.myStoreCount.compareTo(a.myStoreCount));
  }

  // ---------------------------------------------------------------------------- //
}// class