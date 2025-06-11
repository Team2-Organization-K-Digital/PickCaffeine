// 홈 페이지 (매장, info)
/*
// ----------------------------------------------------------------- //
  - title         : Information Home Page (Store)
  - Description   :
  - Author        : gamseong
  - Created Date  : 2025.06.05
  - Last Modified : 2025.06.05
  - package       :

// ----------------------------------------------------------------- //
  [Changelog]
  - 2025.06.05 v1.0.0  :
// ----------------------------------------------------------------- //
*/
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:pick_caffeine_app/vm/image_vm_dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';
import 'package:pick_caffeine_app/view/store/store_update.dart'; // 업데이트 페이지 import

class StoreHomeInfo extends StatelessWidget {
  StoreHomeInfo({super.key});

  final vm = Get.find<VmStoreUpdate>();
  final imageModel = Get.find<ImageModel>();
  final mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final store = vm.getStorehome;
        if (store == null) {
          return Center(child: Text('스토어 정보가 없습니다'));
        }

        return Column(
          children: [
            const SizedBox(height: 40),

            Center(
              child: SizedBox(
                height: 150,
                child: Obx(() => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: imageModel.imageFileList.length + 1,
                      itemBuilder: (context, index) {
                        if (index < imageModel.imageFileList.length) {
                          final file = imageModel.imageFileList[index];
                          return Container(
                            margin: EdgeInsets.all(8),
                            child: Image.file(
                              File(file.path),
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () async =>
                                await imageModel.getImageFromGallerylist(ImageSource.gallery),
                            child: Container(
                              width: 150,
                              margin: EdgeInsets.all(8),
                              color: Colors.grey[300],
                              child: Icon(Icons.add),
                            ),
                          );
                        }
                      },
                    )),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("매장명: ${store.store_name}"),
                    SizedBox(height: 4),
                    Text("설명: ${store.store_content}"),
                    SizedBox(height: 4),
                    Text("영업시간: ${store.store_business_hour}"),
                    SizedBox(height: 4),
                    Text("정기휴무: ${store.store_regular_holiday}"),
                    SizedBox(height: 4),
                    Text("임시휴무: ${store.store_temporary_holiday}"),
                    SizedBox(height: 4),
                    Text("전화번호: ${store.store_phone}"),
                    SizedBox(height: 12),

                    Container(
                      height: 300,
                      margin: EdgeInsets.only(bottom: 20),
                      child: FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter: LatLng(
                            store.store_latitude ?? 37.4979,
                            store.store_longitude ?? 127.0276,
                          ),
                          initialZoom: 15,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(
                                  store.store_latitude ?? 37.4979,
                                  store.store_longitude ?? 127.0276,
                                ),
                                width: 40,
                                height: 40,
                                child: Icon(Icons.location_on, color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ElevatedButton(
                onPressed: () => Get.to(() => StoreUpdate()),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                child: Text("정보 수정하기"),
              ),
            ),
          ],
        );
      }),
    );
  }
}
