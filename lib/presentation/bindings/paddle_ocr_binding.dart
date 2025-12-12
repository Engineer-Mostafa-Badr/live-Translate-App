import 'package:get/get.dart';
import '../controllers/paddle_ocr_controller.dart';

class PaddleOCRBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaddleOCRController>(() => PaddleOCRController());
  }
}
