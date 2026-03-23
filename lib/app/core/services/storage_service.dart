import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:najahapp/app/core/constants/app_constants.dart';
import 'dart:convert';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Auth Token Management
  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.storageKeyToken, token);
  }

  Future<String?> getToken() async {
    return _prefs.getString(AppConstants.storageKeyToken);
  }

  /// Synchronous variant – safe to call after [init] has completed.
  String? getTokenSync() {
    return _prefs.getString(AppConstants.storageKeyToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(AppConstants.storageKeyRefreshToken, token);
  }

  Future<String?> getRefreshToken() async {
    return _prefs.getString(AppConstants.storageKeyRefreshToken);
  }

  Future<void> clearAuth() async {
    await _prefs.remove(AppConstants.storageKeyToken);
    await _prefs.remove(AppConstants.storageKeyRefreshToken);
    await _prefs.remove(AppConstants.storageKeyUser);
  }

  // User Data Management
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(AppConstants.storageKeyUser, json.encode(userData));
  }

  Map<String, dynamic>? getUserData() {
    final userData = _prefs.getString(AppConstants.storageKeyUser);
    if (userData != null) {
      return json.decode(userData);
    }
    return null;
  }

  // Language Management
  Future<void> saveLanguage(String languageCode) async {
    await _prefs.setString(AppConstants.storageKeyLanguage, languageCode);
  }

  String getLanguage() {
    return _prefs.getString(AppConstants.storageKeyLanguage) ?? 'en';
  }

  // Theme Management
  Future<void> saveTheme(bool isDark) async {
    await _prefs.setBool(AppConstants.storageKeyTheme, isDark);
  }

  bool isDarkTheme() {
    return _prefs.getBool(AppConstants.storageKeyTheme) ?? false;
  }

  // Onboarding Status
  Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(AppConstants.storageKeyOnboarding, true);
  }

  bool isOnboardingCompleted() {
    return _prefs.getBool(AppConstants.storageKeyOnboarding) ?? false;
  }

  // FCM Token Management
  Future<void> saveFCMToken(String token) async {
    await _prefs.setString('fcm_token', token);
  }

  String? getFCMToken() {
    return _prefs.getString('fcm_token');
  }

  Future<void> deleteFCMToken() async {
    await _prefs.remove('fcm_token');
  }

  // Generic Methods
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
}
