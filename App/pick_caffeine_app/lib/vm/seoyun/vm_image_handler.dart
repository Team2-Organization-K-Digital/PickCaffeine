import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class VmImageHandler extends GetxController{
  //이미지 파일
  final imageFile = Rx<XFile?>(null);
  final ImagePicker picker = ImagePicker();

  Future<void> getImagefromGallery(ImageSource source) async{
    final pickedFile = await picker.pickImage(source: source);
    if(pickedFile != null){
      imageFile.value = pickedFile;
    }
  }

}