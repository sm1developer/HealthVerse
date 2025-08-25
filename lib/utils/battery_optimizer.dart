import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class BatteryOptimizer {
  static const MethodChannel _channel = MethodChannel('battery_optimizer');

  /// Request battery optimization exemption for sleep tracking
  static Future<bool> requestBatteryOptimizationExemption() async {
    try {
      final bool result = await _channel.invokeMethod(
        'requestBatteryOptimizationExemption',
      );
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Check if app is ignoring battery optimizations
  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final bool result = await _channel.invokeMethod(
        'isIgnoringBatteryOptimizations',
      );
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Start sleep tracking service with battery optimization
  static Future<bool> startSleepTrackingService() async {
    try {
      final bool result = await _channel.invokeMethod(
        'startSleepTrackingService',
      );
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Stop sleep tracking service
  static Future<bool> stopSleepTrackingService() async {
    try {
      final bool result = await _channel.invokeMethod(
        'stopSleepTrackingService',
      );
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Request all necessary permissions for sleep tracking
  static Future<Map<ph.Permission, ph.PermissionStatus>>
      requestSleepTrackingPermissions() async {
    final Map<ph.Permission, ph.PermissionStatus> statuses = {};

    // Request activity recognition permission
    statuses[ph.Permission.activityRecognition] =
        await ph.Permission.activityRecognition.request();

    // Request body sensors permission
    statuses[ph.Permission.sensors] = await ph.Permission.sensors.request();

    // Request notification permission for Android 13+
    if (await ph.Permission.notification.isDenied) {
      statuses[ph.Permission.notification] =
          await ph.Permission.notification.request();
    }

    return statuses;
  }

  /// Check if all required permissions are granted
  static Future<bool> hasAllRequiredPermissions() async {
    final activityRecognition = await ph.Permission.activityRecognition.status;
    final sensors = await ph.Permission.sensors.status;
    // Notification permission is helpful but NOT required for core sleep tracking
    return activityRecognition.isGranted && sensors.isGranted;
  }

  /// Open app settings for manual permission granting
  static Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }
}
