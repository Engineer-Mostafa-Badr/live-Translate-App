import 'package:get/get.dart';
import '../controllers/ocr_controller.dart';

class OCRBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OCRController>(() => OCRController());
  }
}
