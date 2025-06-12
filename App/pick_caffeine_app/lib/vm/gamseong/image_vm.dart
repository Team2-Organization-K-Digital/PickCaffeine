import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pick_caffeine_app/vm/gamseong/vm_inforemation.dart';


class ImageModel extends VmInformation{
  final imageFileList = <XFile>[].obs;
  final imageFile = Rx<XFile?>(null);
  final ImagePicker picker = ImagePicker();

  Future<void> getImageFromGallery(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      imageFile.value = pickedFile;
    }
  }

  
  Future<void> getImageFromGallerylist(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
    if(imageFileList.length < 5){
      imageFileList.add(pickedFile);
    }else{
      Get.snackbar("오류", "최대5개까지추가하세요");
    }
    }
  }

  void clearImagelist(int index) {
    if( index >= 0 && index < imageFileList.length){
      imageFileList.removeAt(index);
    }
  }
    void clearImage() {
    imageFile.value = null;}


  }

