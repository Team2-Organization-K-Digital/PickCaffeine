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
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';

class CustomerHomeMap extends StatelessWidget {
  CustomerHomeMap({super.key});

  final vmgpshandleer = Get.find<Vmgamseong>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SizedBox.expand(
        child: Stack(
          children: [
            FlutterMap(
              mapController: vmgpshandleer.mapController,
              options: MapOptions(
                onTap: (tapPosition, point) {},
                initialCenter: LatLng(
                  vmgpshandleer.currentlat.value,
                  vmgpshandleer.currentlong.value,
                ),
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(markers: vmgpshandleer.markers),
                // MarkerLayer(markers: vmgpshandleer.loadlikeMarkers,
                // ),
              ],
            ),
            IconButton(
              onPressed: () async {
                if (vmgpshandleer.likeStore.value) {
                  vmgpshandleer.likeStore.value = false;
                  await vmgpshandleer.loadStoresAndMarkers();
                } else {
                  vmgpshandleer.likeStore.value = true;
                  await vmgpshandleer.loadStoresAndMarkers();
                }
                vmgpshandleer.mapController.move(
                  LatLng(
                    vmgpshandleer.currentlat.value,
                    vmgpshandleer.currentlong.value,
                  ),
                  15,
                );
              },
              icon: CircleAvatar(
                backgroundColor: AppColors.brown,
                foregroundColor: AppColors.lightpick,
                radius: 20,
                child: Icon(Icons.favorite),
              ),
            ),
          ],
        ),
      );
    });
  }
}
