import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImageModel extends GetxController {
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
