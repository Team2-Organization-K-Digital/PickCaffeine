import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:pick_caffeine_app/model/changjun/model/stores.dart';
import 'package:pick_caffeine_app/vm/changjun/chart_handler.dart';

class StoreHandler extends ChartHandler{
  final RxList<Stores> storeData = <Stores>[].obs;
  final RxList<Stores> sortedByDistance = <Stores>[].obs;
  final RxList<Stores> sortedByReview = <Stores>[].obs;
  final RxList<Stores> sortedByZzim = <Stores>[].obs;
  // final box = GetStorage();


  double currentLatitude = 0.0;
  double currentLongitude = 0.0;

// ---------------------------------------------------------------------------- //
// 전체 매장을 불러오는 함수
  Future<void> fetchStore()async{
    await getCurrentLocation();
    // print('start fetchStore');
    
      storeData.clear();
      final res = await http.get(Uri.parse("$baseUrl/select/store"));
      // print('end res');
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];
      // print(results);
      // print(currentLatitude);
      // print(currentLongitude);

      final List<Stores> returnResult = 
          results.map((data) {
          double storeLat = data["store_latitude"];
          double storeLng = data["store_longitude"];
          // print(storeLat);
          // print(storeLng);
            double distanceKm =  Distance().as(
            LengthUnit.Kilometer,
            LatLng(storeLat, storeLng),
            LatLng(currentLatitude, currentLongitude),
            );
            // print(distanceKm);
            return Stores(
              storeId: data["store_id"], 
              storeName: data["store_name"], 
              myStoreCount: data["zzim"], 
              reviewCount: data["review"], 
              distance: distanceKm,
              storeState: data['store_state'],
              storeImage: data["image_1"]
            );
          }).toList();
          // print(returnResult);
          
          storeData.value = returnResult;
          sortAllStoreLists();
          // print(storeData.value);
}
// ---------------------------------------------------------------------------- //
// 사용자의 현재 위치를 불러오는 함수
  Future<void> getCurrentLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
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
  sortedByDistance.value = [...storeData]..sort((a, b) => a.distance.compareTo(b.distance));
  sortedByReview.value = [...storeData]..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
  sortedByZzim.value = [...storeData]..sort((a, b) => b.myStoreCount.compareTo(a.myStoreCount));
}
// ---------------------------------------------------------------------------- //
}// class