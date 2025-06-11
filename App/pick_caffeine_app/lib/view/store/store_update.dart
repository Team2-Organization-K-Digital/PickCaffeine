// 매장 정보 수정 페이지 
/*
// ----------------------------------------------------------------- //
  - title         : Update Store Page
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
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:pick_caffeine_app/vm/image_vm_dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';
import 'package:pick_caffeine_app/model/gamseong/store_home.dart';

class StoreUpdate extends StatelessWidget {
  StoreUpdate({super.key});

  final vm = Get.find<VmStoreUpdate>();
  final image = Get.find<ImageModel>();

  final mapController = MapController();
  final contentController = TextEditingController();
  final businessnumController = TextEditingController();
  final regularController = TextEditingController();
  final tempController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final addressDetailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final store = vm.getStorehome;
    if (store == null) {
      return Scaffold(body: Center(child: Text('스토어 정보가 없습니다')));
    }

    contentController.text = store.store_content;
    businessnumController.text = store.store_business_hour;
    regularController.text = store.store_regular_holiday;
    tempController.text = store.store_temporary_holiday;
    phoneController.text = store.store_phone;
    addressController.text = store.store_address;
    addressDetailController.text = store.store_address_detail;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: image.imageFileList.length + 1,
                    itemBuilder: (context, index) {
                      if (index < image.imageFileList.length) {
                        final file = image.imageFileList[index];
                        return Container(
                          margin: EdgeInsets.only(right: 8),
                          child: Image.file(
                            File(file.path),
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onTap: () =>
                              image.getImageFromGallerylist(ImageSource.gallery),
                          child: Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: Icon(Icons.add),
                          ),
                        );
                      }
                    },
                  ),
                )),
            const SizedBox(height: 16),

            Text(store.store_name ?? "",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            const SizedBox(height: 16),




            const SizedBox(height: 12),

            _buildField("가게 설명", contentController, maxLines: 3),
            _buildField("영업 시간", businessnumController),
            _buildField("정기 휴무", regularController),
            _buildField("임시 휴무", tempController),
            _buildField("전화 번호", phoneController),

            const SizedBox(height: 12),

            // 지도
            Container(
              height: 250,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Obx(() => FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: vm.targetLocation.value ??
                          LatLng(store.store_latitude, store.store_longitude),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: vm.targetLocation.value ??
                                LatLng(store.store_latitude, store.store_longitude),
                            width: 40,
                            height: 40,
                            child:
                                Icon(Icons.location_on, color: Colors.red),
                          )
                        ],
                      )
                    ],
                  )),
            ),
                        _buildField("주소", addressController),
            _buildField("상세 주소", addressDetailController),

            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await vm.fetchLatLngFromAddress(addressController.text);
                    final target = vm.targetLocation.value;
                    if (target != null) {
                      mapController.move(target, 15);
                      Get.snackbar("주소 검색 완료", "지도 위치가 이동되었습니다");
                    } else {
                      Get.snackbar("오류", "위치를 찾을 수 없습니다");
                    }
                  },
                  child: Text("주소 검색"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Get.snackbar("위치 반영", "해당 위치가 등록에 반영됩니다");
                  },
                  child: Text("지도 반영"),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text("사업자 정보"),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(store.store_business_num.toString()),
            ),

            const SizedBox(height: 20),

            // 정보 수정 버튼
            Row(
              children: [
                Center(
                  child: ElevatedButton(
                  onPressed: () async {
                    print('수정 버튼 눌림');
                
                    final updated = StoreHome(
                      store_id: store.store_id,
                      store_password: store.store_password,
                      store_name: store.store_name,
                      store_phone: phoneController.text,
                      store_business_num: store.store_business_num,
                      store_address: addressController.text,
                      store_address_detail: addressDetailController.text,
                      store_latitude: vm.targetLocation.value?.latitude ?? store.store_latitude,
                      store_longitude: vm.targetLocation.value?.longitude ?? store.store_longitude,
                      store_content: contentController.text,
                      store_state: store.store_state,
                      store_regular_holiday: regularController.text,
                      store_temporary_holiday: tempController.text,
                      store_business_hour: businessnumController.text,
                    );
                
                    try {
                      final result = await vm.updateStorelist(updated);
                      print(" 결과: $result");
                
                      if (result == 'OK') {
                        vm.setStore(updated);
                        Get.snackbar("완료", "정보가 수정되었습니다");
                        Get.back();
                      } else {
                        Get.snackbar("오류", result);
                      }
                    } catch (e) {
                      print(" 예외 발생: $e");
                    }
                  },
                  child: Text("정보 수정"),
                ),
                
                ),ElevatedButton(
                  onPressed: () => Get.back(), child: Text("매장으로돌아가기"))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
