import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pick_caffeine_app/vm/Eunjun/image_provider.dart';
import 'package:pick_caffeine_app/vm/Eunjun/vm_handler_selectoption.dart';

class StoreController extends VmHandlerSelectoption {
  final RxList<TextEditingController> titleControllers =
      <TextEditingController>[].obs;
  RxList<RxList<TextEditingController>> optionControllers =
      <RxList<TextEditingController>>[].obs;
  RxList<RxList<TextEditingController>> optPriceControllers =
      <RxList<TextEditingController>>[].obs;
  RxMap<String, bool> optionValue = <String, bool>{}.obs;
  var titles = <String>[].obs;
  var selected = <bool>[].obs;
  var updateSelected = <bool>[].obs;
  var editIndex = "".obs;

  void addTitle() {
    titleControllers.add(TextEditingController());
    optionControllers.add(<TextEditingController>[].obs);
    optPriceControllers.add(<TextEditingController>[].obs);
    selected.add(false);
  }

  void addOption(int titleIndex) {
    optionControllers[titleIndex].add(TextEditingController());
    optPriceControllers[titleIndex].add(TextEditingController());
  }

  void clearAll() {
    titles.clear();
    titleControllers.clear();
    optionControllers.clear();
    optPriceControllers.clear();
    selected.clear();
  }

  void removeTitle(int i) {
    titleControllers.removeAt(i);
    optionControllers.removeAt(i);
    optPriceControllers.removeAt(i);
    selected.removeAt(i);
  }

  void removeOption(int i, int index) {
    optionControllers[i].removeAt(index);
    optPriceControllers[i].removeAt(index);
  }
}
