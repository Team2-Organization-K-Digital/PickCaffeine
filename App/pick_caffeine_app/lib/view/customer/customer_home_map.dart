// 홈 페이지 (고객, map)
/*
// ----------------------------------------------------------------- //
  - title         : Map Home Page (Customer)
  - Description   :
  - Author        : Gam Sung
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.05
  - package       :

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  :
// ----------------------------------------------------------------- //
*/
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';

class CustomerHomeMap extends StatelessWidget {
  CustomerHomeMap({super.key});

  final vmgpshandleer = Get.find<Vmgamseong>();
  final mapController = MapController();



  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      vmgpshandleer.loadStoresAndMarkers();
      vmgpshandleer.checkLocationPermission();
      // vmgpshandleer.loadlikeMarkers();
    });

    return Scaffold(
      // appBar: AppBar(title: Text('고객용 매장 지도')),
      body: Obx(() {
        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            onTap:(tapPosition, point) {
          
          },
            initialCenter: vmgpshandleer.targetLocation.value ?? LatLng(37.5665, 126.9780),
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: vmgpshandleer.markers,
            ),
            // MarkerLayer(markers: vmgpshandleer.loadlikeMarkers,
            // ),
          ],
        );
      }),
    );
  }

  }


