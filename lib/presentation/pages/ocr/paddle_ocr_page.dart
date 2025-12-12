import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/paddle_ocr_controller.dart';

class PaddleOCRPage extends GetView<PaddleOCRController> {
  const PaddleOCRPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Paddle OCR Test'),
        backgroundColor: const Color(0xFF1D1E33),
        elevation: 0,
        actions: [
          Obx(
            () => controller.ocrResult.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: controller.clearResult,
                    tooltip: 'Clear Result',
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildModelStatus(),
              SizedBox(height: 16.h),
              _buildImagePreview(),
              SizedBox(height: 24.h),
              _buildActionButtons(),
              SizedBox(height: 24.h),
              _buildProcessingIndicator(),
              SizedBox(height: 24.h),
              _buildResultSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelStatus() {
    return Obx(() {
      final isLoaded = controller.isModelLoaded.value;
      final isProcessing = controller.isProcessing.value && !isLoaded;

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isLoaded
              ? const Color(0xFF4CAF50).withOpacity(0.1)
              : const Color(0xFFFF9800).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isLoaded
                ? const Color(0xFF4CAF50).withOpacity(0.3)
                : const Color(0xFFFF9800).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (isProcessing)
              SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
                ),
              )
            else
              Icon(
                isLoaded ? Icons.check_circle : Icons.warning,
                color: isLoaded
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF9800),
                size: 20.sp,
              ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                isProcessing
                    ? 'Loading PaddleOCR model...'
                    : isLoaded
                    ? 'PaddleOCR model ready'
                    : 'Model not loaded',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildImagePreview() {
    return Obx(() {
      final image = controller.selectedImage.value;

      return Container(
        height: 250.h,
        decoration: BoxDecoration(
          color: const Color(0xFF1D1E33),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.file(image, fit: BoxFit.contain),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 64.sp,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'No image selected',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }

  Widget _buildActionButtons() {
    return Obx(() {
      final isProcessing = controller.isProcessing.value;
      final isModelLoaded = controller.isModelLoaded.value;
      final isDisabled = isProcessing || !isModelLoaded;

      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isDisabled ? null : controller.pickImageFromGallery,
              icon: const Icon(Icons.photo_library),
              label: Text('Gallery', style: TextStyle(fontSize: 16.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                disabledBackgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isDisabled ? null : controller.pickImageFromCamera,
              icon: const Icon(Icons.camera_alt),
              label: Text('Camera', style: TextStyle(fontSize: 16.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                disabledBackgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildProcessingIndicator() {
    return Obx(() {
      final isProcessing = controller.isProcessing.value;
      final isModelLoaded = controller.isModelLoaded.value;

      if (!isProcessing || !isModelLoaded) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1E33),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            ),
            SizedBox(height: 16.h),
            Text(
              'Processing with PaddleOCR...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Detecting and recognizing text',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildResultSection() {
    return Obx(() {
      final result = controller.ocrResult.value;
      final errorMessage = controller.errorMessage.value;
      final detectedBlocks = controller.detectedBlocks;

      if (errorMessage.isNotEmpty) {
        return _buildErrorCard(errorMessage);
      }

      if (result.isEmpty) {
        return _buildEmptyState();
      }

      return _buildResultCard(result, detectedBlocks);
    });
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.text_fields,
            size: 64.sp,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No text extracted yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Select an image to start OCR with PaddleOCR',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 32.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  error,
                  style: TextStyle(
                    color: Colors.red.withOpacity(0.8),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String result, RxList detectedBlocks) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: const Color(0xFF4CAF50),
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Extracted Text',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${detectedBlocks.length} blocks',
                  style: TextStyle(
                    color: const Color(0xFF6C63FF),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E21),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: SelectableText(
              result,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: result));
                    Get.snackbar(
                      'Copied',
                      'Text copied to clipboard',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Text'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6C63FF),
                    side: const BorderSide(color: Color(0xFF6C63FF)),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (detectedBlocks.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              'Detected Text Blocks:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            ...detectedBlocks.map((block) => _buildTextBlock(block)),
          ],
        ],
      ),
    );
  }

  Widget _buildTextBlock(dynamic block) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E21),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            block.text,
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.verified, size: 14.sp, color: Colors.green),
              SizedBox(width: 4.w),
              Text(
                'Confidence: ${(block.confidence * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
