import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:pick_caffeine_app/model/store_home.dart';
import 'package:pick_caffeine_app/vm/image_vm_dart';

class VmGpsHandller extends ImageModel {

  final baseUrl = "http://127.0.0.1:8000/seong";
  final latitude = ''.obs;
  final longitude = ''.obs;
  final targetLocation = Rx<LatLng?>(null);
  var storeList = <StoreHome>[].obs;  // 서버에서 받아올 매장 데이터
  var markers = <Marker>[].obs;       // 지도에 표시할 마커 리스트



  // 전체 매장 목록 빨강색
  Future<void> loadStoresAndMarkers() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/selectstore"));
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (data['results'] != null) {
        storeList.value = (data['results'] as List)
            .map((e) => StoreHome.fromMap(e))
            .toList();

        markers.value = storeList.map((store) {
          return Marker(
            point: LatLng(store.store_latitude, store.store_longitude),
            width: 40,
            height: 40,
            child: Tooltip(
              message: store.store_name,
              child: Icon(Icons.store, color: Colors.red),
            ),
          );
        }).toList();
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

    final likedStoreIds = (myStoreData['results'] as List)
        .map((e) => e['store_id'].toString())
        .toList();

    // 3. 전체 매장 정보 요청
    final response = await http.get(Uri.parse("$baseUrl/selectstore")); 
    final data = jsonDecode(utf8.decode(response.bodyBytes));

    // 4. 필터링하여 마커 생성
    if (data['results'] != null) {
      storeList.value = (data['results'] as List)
          .map((e) => StoreHome.fromMap(e))
          .where((store) => likedStoreIds.contains(store.store_id))
          .toList();

      markers.value = storeList.map((store) {
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







  Future<void> checkLocationPermission()async{
    // 위치권한확인
    LocationPermission permission = await Geolocator.checkPermission(); 

    // 권한이 없으면 요청하는것. 앱사용중 위치정보 허용하시겟습니까? 그거임
    if(
      permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }
  
  //권한이 영구적으로 거부된경우 종료한다.
  if (
    permission == LocationPermission.deniedForever) return;

  // 권한이 허용되었을경우 위처정보를 가져온다.
  if(
    permission == LocationPermission.whileInUse || permission == LocationPermission.always){
    final position = await Geolocator.getCurrentPosition();
    latitude.value = position.latitude.toString();
    longitude.value = position.longitude.toString();
  }
  }

  Future<void> fetchLatLngFromAddress(String inputAddress)async{
    
    try{
      List<Location> locations = await locationFromAddress(inputAddress);
      if(locations.isNotEmpty){
        double lat = locations.first.latitude;
        double lng = locations.first.longitude;

        latitude.value = lat.toString();
        longitude.value = lng.toString();
        targetLocation.value = LatLng(lat, lng);

        markers.add(Marker(point: LatLng(lat, lng), child: Icon(
          Icons.my_location, color: Colors.red, size: 30,
        )));

      }
    }catch(e){
      Get.snackbar("오류","주소변환실패 : $e");
    }

      }

    
    
    
  }
