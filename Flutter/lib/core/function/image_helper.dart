import 'package:image_picker/image_picker.dart';
import '../cache/cache_helper.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();
  static const String imgbbAlbumUrl = 'https://ibb.co/album/nPFBWq';
  static bool _isBusy = false;

  /// يلتقط صورة الوجه فقط (الكاميرا الأمامية افتراضياً) بأبعاد خفيفة ويرفعها للـ AI ليقيس ملامح الوجه
  static Future<XFile?> pickImage(ImageSource source) async {
    if (_isBusy) return null;
    _isBusy = true;
    try {
      await CacheHelper.setPendingCameraCapture(true);
      await CacheHelper.setSavedTabIndex(2);

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 640,
        maxHeight: 640,
        imageQuality: 70,
        requestFullMetadata: false,
      );

      await CacheHelper.setPendingCameraCapture(false);
      return pickedFile;
    } catch (_) {
      await CacheHelper.setPendingCameraCapture(false);
      return null;
    } finally {
      _isBusy = false;
    }
  }

  /// يسترجع صورة الوجه الملتقطة إذا قام نظام الأندرويد بإعادة تشغيل الواجهة بعد إغلاق الكاميرا
  static Future<XFile?> recoverKilledCameraImage() async {
    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      await CacheHelper.setPendingCameraCapture(false);
      if (!response.isEmpty && response.file != null) {
        return response.file;
      }
      return null;
    } catch (_) {
      await CacheHelper.setPendingCameraCapture(false);
      return null;
    }
  }

  /// يولد رابط الصورة المرتبط بألبوم المهمة https://ibb.co/album/nPFBWq
  static String buildAlbumImageUrl(XFile file) {
    final cleanName = file.name.isNotEmpty
        ? file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')
        : 'face_scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return '$imgbbAlbumUrl/$cleanName';
  }
}
