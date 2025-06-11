import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:pick_caffeine_app/model/changjun/model/stores.dart';
import 'package:pick_caffeine_app/vm/changjun/chart_handler.dart';
// ---------------------------------------------------------------------------- //
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
// 1. 전체 매장을 불러오는 함수
  Future<void> fetchStore() async {
    isLoading.value = true;
    await getCurrentLocation();
    try {
      final res = await http.get(Uri.parse("$baseUrl/select/store"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];
      final List<Stores> returnResult =
          results.map((data) {
            double storeLat = data[2];
            double storeLng = data[3];
            double distanceKm = Distance().as(
              LengthUnit.Kilometer,
              LatLng(storeLat, storeLng),
              LatLng(currentLatitude, currentLongitude),
            );
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
      storeData.value = returnResult;
      sortAllStoreLists();
    } catch (e, stack) {
      print('Error fetching store: $e');
      print(stack);
    } finally {
      isLoading.value = false;
    }
  }
// ---------------------------------------------------------------------------- //
// 2. 사용자의 현재 위치를 불러오는 함수
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
// 3. 각각 용도에 맞는 정렬 방식으로 data 를 list 에 각각 추가하는 함수
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