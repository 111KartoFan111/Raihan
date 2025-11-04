import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SettingsService {
  static const _kSosVibration = 'sos_vibration';
  static const _kAutoLocationSharing = 'auto_location_sharing';
  static const _kEmergencyNotifications = 'emergency_notifications';
  static const _kSoundAlerts = 'sound_alerts';

  static final ValueNotifier<bool> sosVibration = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> autoLocationSharing = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> emergencyNotifications = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> soundAlerts = ValueNotifier<bool>(false);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    sosVibration.value = prefs.getBool(_kSosVibration) ?? true;
    autoLocationSharing.value = prefs.getBool(_kAutoLocationSharing) ?? true;
    emergencyNotifications.value = prefs.getBool(_kEmergencyNotifications) ?? true;
    soundAlerts.value = prefs.getBool(_kSoundAlerts) ?? false;
  }

  static Future<void> setSosVibration(bool v) async {
    sosVibration.value = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSosVibration, v);
  }

  static Future<void> setAutoLocationSharing(bool v) async {
    autoLocationSharing.value = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoLocationSharing, v);
  }

  static Future<void> setEmergencyNotifications(bool v) async {
    emergencyNotifications.value = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEmergencyNotifications, v);
  }

  static Future<void> setSoundAlerts(bool v) async {
    soundAlerts.value = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSoundAlerts, v);
  }
}
