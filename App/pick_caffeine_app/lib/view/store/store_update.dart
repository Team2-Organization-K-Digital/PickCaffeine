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
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:pick_caffeine_app/model/Eunjun/store.dart';
import 'package:pick_caffeine_app/vm/gamseong/image_vm.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_store_update.dart';

import 'package:pick_caffeine_app/widget_class/utility/button_brown.dart';

import '../../vm/Eunjun/vm_handler_temp.dart';

class StoreUpdate extends StatelessWidget {
  StoreUpdate({super.key});

  final vm = Get.find<Vmgamseong>();
  final image = Get.find<ImageModelgamseong>();
  final box = GetStorage();
  
  
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
   final Store store = Get.arguments;

    //  handler.fetchStore(storeId);

  Uint8List originalImage = Uint8List(0);
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
      body: Obx(() =>
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Get.back(),
              ),
              const SizedBox(height: 16),
              Text(store.store_name ?? "",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              _buildImagePicker(context, originalImage),
        
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
          ButtonBrown(
                    text: "수정",
                    onPressed: () async {
                      final Map<String, dynamic> updatePayload = {
                        "store_id": store.store_id,
                        "store_name": store.store_name,
                        "store_phone": phoneController.text,
                        "store_address": addressController.text,
                        "store_address_detail": addressDetailController.text,
                        "store_latitude": vm.targetLocation.value?.latitude ?? store.store_latitude,
                        "store_longitude": vm.targetLocation.value?.longitude ?? store.store_longitude,
                        "store_content": contentController.text,
                        "store_state": store.store_state,
                        "store_business_num": store.store_business_num,
                        "store_regular_holiday": regularController.text,
                        "store_temporary_holiday": tempController.text,
                        "store_business_hour": businessnumController.text,
                      };

                        await vm.updatestore(updatePayload).then((_) async {
                          Get.back(result: true);
                          });

                    if (image.imageFile.value != null) {
                    final bytes = await image.imageFile.value!.readAsBytes();
                      final imageBase64 = base64Encode(bytes);
                    await vm.updatestoreImage(store.store_id, imageBase64);
                            }
                    })
              ],
            ),
          )),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {int maxLines = 1, bool readOnly = false,}) {
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

    Widget _buildImagePicker(BuildContext context, Uint8List originalImage) {
    final imageFile = image.imageFile;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => image.getImageFromGallery(ImageSource.gallery),
              child: Text("갤러리"),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => image.getImageFromGallery(ImageSource.camera),
              child: Text("카메라"),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          height: 200,
          color: Colors.grey[300],
          child: imageFile.value != null
              ? Image.file(File(imageFile.value!.path), fit: BoxFit.cover)
              : (originalImage.isNotEmpty
                  ? Image.memory(originalImage, fit: BoxFit.cover)
                  : Icon(Icons.image_not_supported)),
        ),
      ],
    );
  }
}
