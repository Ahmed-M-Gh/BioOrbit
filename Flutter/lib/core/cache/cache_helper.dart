import 'package:shared_preferences/shared_preferences.dart';
import 'cache_keys.dart';

class CacheHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? get accessToken => _prefs?.getString(CacheKeys.accessToken);
  static String? get crewName => _prefs?.getString(CacheKeys.crewName);
  static String get crewRole =>
      _prefs?.getString(CacheKeys.crewRole) ?? 'Astro';
  static String get lastRecordId =>
      _prefs?.getString(CacheKeys.lastRecordId) ?? '6af7b2f91d64b08c0813a2be';
  static String get astronautId =>
      _prefs?.getString(CacheKeys.astronautId) ?? '6af76cba28fa0cba6ce16113';
  static bool get isArabic => _prefs?.getBool(CacheKeys.isArabic) ?? true;
  static bool get pendingCameraCapture =>
      _prefs?.getBool(CacheKeys.pendingCameraCapture) ?? false;
  static int get savedTabIndex => _prefs?.getInt(CacheKeys.savedTabIndex) ?? 0;

  static Future<void> saveAuthSession({
    required String token,
    required String username,
    required String role,
    String? astroId,
  }) async {
    await _prefs?.setString(CacheKeys.accessToken, token);
    await _prefs?.setString(CacheKeys.crewName, username);
    await _prefs?.setString(CacheKeys.crewRole, role);
    if (astroId != null && astroId.isNotEmpty) {
      await _prefs?.setString(CacheKeys.astronautId, astroId);
    }
  }

  static Future<void> setCrewRole(String role) async {
    await _prefs?.setString(CacheKeys.crewRole, role);
  }

  static Future<void> setLastRecordId(String id) async {
    await _prefs?.setString(CacheKeys.lastRecordId, id);
  }

  static Future<void> setIsArabic(bool isAr) async {
    await _prefs?.setBool(CacheKeys.isArabic, isAr);
  }

  static Future<void> setPendingCameraCapture(bool pending) async {
    await _prefs?.setBool(CacheKeys.pendingCameraCapture, pending);
  }

  static Future<void> setSavedTabIndex(int index) async {
    await _prefs?.setInt(CacheKeys.savedTabIndex, index);
  }

  static Future<void> logout() async {
    await _prefs?.remove(CacheKeys.accessToken);
    await _prefs?.remove(CacheKeys.crewName);
    await _prefs?.remove(CacheKeys.lastRecordId);
    await _prefs?.remove(CacheKeys.pendingCameraCapture);
    await _prefs?.remove(CacheKeys.savedTabIndex);
  }
}
