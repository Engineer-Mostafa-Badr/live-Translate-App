import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'offline_manager_controller.dart';

/// Offline Manager Page
/// Manages OCR models and offline translation language packs
class OfflineManagerPage extends GetView<OfflineManagerController> {
  const OfflineManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OfflineManagerController());
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المحتوى دون اتصال'),
          centerTitle: true,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Storage Info Card
                _buildStorageInfo(context),
                
                SizedBox(height: 24.h),
                
                // OCR Models Section
                _buildOCRSection(context),
                
                SizedBox(height: 24.h),
                
                // Language Packs Section
                _buildLanguagePacksSection(context),
              ],
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildStorageInfo(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: Theme.of(context).primaryColor,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'مساحة التخزين',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المستخدم:',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      controller.usedStorage.value,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                )),
            SizedBox(height: 8.h),
            Obx(() => LinearProgressIndicator(
                  value: controller.storagePercentage.value,
                  minHeight: 8.h,
                  borderRadius: BorderRadius.circular(4.r),
                )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOCRSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.document_scanner,
              color: Theme.of(context).primaryColor,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              'نماذج OCR',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        
        // PaddleOCR Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.text_fields,
                        color: Colors.blue,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PaddleOCR v5',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: 4.h),
                          Obx(() => Text(
                                controller.ocrModelsDownloaded.value
                                    ? 'محمّل • 120 MB'
                                    : 'غير محمّل • 120 MB',
                                style: Theme.of(context).textTheme.bodySmall,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Obx(() {
                  if (controller.isDownloadingOCR.value) {
                    return Column(
                      children: [
                        LinearProgressIndicator(
                          value: controller.ocrDownloadProgress.value,
                          minHeight: 6.h,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '${(controller.ocrDownloadProgress.value * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    );
                  }
                  
                  if (controller.ocrModelsDownloaded.value) {
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.deleteOCRModels,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('حذف'),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.testOCR,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('اختبار'),
                          ),
                        ),
                      ],
                    );
                  }
                  
                  return ElevatedButton.icon(
                    onPressed: controller.downloadOCRModels,
                    icon: const Icon(Icons.download),
                    label: const Text('تحميل نماذج OCR'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48.h),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLanguagePacksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.language,
              color: Theme.of(context).primaryColor,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              'حزم اللغات للترجمة دون اتصال',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        
        Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.languagePacks.length,
              itemBuilder: (context, index) {
                final pack = controller.languagePacks[index];
                return _buildLanguagePackCard(context, pack, index);
              },
            )),
      ],
    );
  }
  
  Widget _buildLanguagePackCard(BuildContext context, dynamic pack, int index) {
    final isDownloaded = pack.isDownloaded as bool;
    final isDownloading = controller.downloadingLanguage.value == pack.code;
    
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: _getLanguageColor(pack.code).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      pack.code.toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: _getLanguageColor(pack.code),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pack.name as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${pack.nativeName} • ${pack.size}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (isDownloaded && !isDownloading)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24.sp,
                  ),
              ],
            ),
            
            if (isDownloading) ...[
              SizedBox(height: 12.h),
              Obx(() => Column(
                    children: [
                      LinearProgressIndicator(
                        value: controller.languageDownloadProgress.value,
                        minHeight: 6.h,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '${(controller.languageDownloadProgress.value * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  )),
            ] else if (!isDownloaded) ...[
              SizedBox(height: 12.h),
              ElevatedButton.icon(
                onPressed: () => controller.downloadLanguagePack(pack.code as String),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('تحميل'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 40.h),
                ),
              ),
            ] else ...[
              SizedBox(height: 12.h),
              OutlinedButton.icon(
                onPressed: () => controller.deleteLanguagePack(pack.code as String),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('حذف'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 40.h),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Color _getLanguageColor(String code) {
    final colors = {
      'ar': Colors.green,
      'en': Colors.blue,
      'fr': Colors.purple,
      'es': Colors.orange,
      'de': Colors.red,
      'zh': Colors.pink,
      'ja': Colors.teal,
      'ko': Colors.indigo,
    };
    return colors[code] ?? Colors.grey;
  }
}
