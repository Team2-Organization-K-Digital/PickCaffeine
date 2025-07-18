import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pick_caffeine_app/vm/eunjun/store_main_tabbar.dart';

class ImageModel extends StoreMainTabbar {
  final imageFile = Rx<XFile?>(null);
  final ImagePicker picker = ImagePicker();

  Future<void> getImageFromGallery(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      imageFile.value = pickedFile;
    }
  }

  void clearImage() {
    imageFile.value = null;
  }
}
