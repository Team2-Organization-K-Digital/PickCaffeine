import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pick_caffeine_app/app_colors.dart';
import 'package:pick_caffeine_app/vm/eunjun/vm_handler_temp.dart';

class MenuUtility {
  Widget unsaleContainer() {
    return Container(
      width: double.infinity,
      height: 200,
      color: AppColors.greyopac,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, size: 70, color: AppColors.brown),
            Text('품절', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  Widget flutterMap(VmHandlerTemp hander) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(
          hander.loginStore.first.store_latitude,
          hander.loginStore.first.store_longitude,
        ),
        initialZoom: 17.5,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80,
              height: 80,
              point: LatLng(
                hander.loginStore.first.store_latitude,
                hander.loginStore.first.store_longitude,
              ),
              child: Icon(Icons.pin_drop, size: 50, color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }
}
