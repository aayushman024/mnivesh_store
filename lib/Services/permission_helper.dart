import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {

  static Future<void> requestAll() async {
    if (!Platform.isAndroid) return;

    // 1. Request Notification Permission (Android 13+)
    // This shows a standard Allow/Deny dialog
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // 2. Request Storage Permission
    // On Android 13+, this usually isn't needed for app-specific files,
    // but we request it for older versions.
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }

    // Also request Manage External Storage if strictly needed (Android 11+)
    // usually not needed for basic downloads, skipping to avoid rejection by Play Store.

    // 3. Request Install Packages Permission
    // CRITICAL: This opens a Settings Screen, not a dialog.
    // We check if it's already granted first to avoid annoying the user.
    if (await Permission.requestInstallPackages.isDenied) {
      await Permission.requestInstallPackages.request();
    }
  }
}