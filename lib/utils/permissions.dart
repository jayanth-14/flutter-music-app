import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  if (Platform.isAndroid) {
    // Only needed for Android 13+ (SDK >= 33)
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        print("✅ Notifications permission granted");
      } else {
        print("❌ Notifications permission denied");
      }
    }
  }
}
