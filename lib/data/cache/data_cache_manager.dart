import 'dart:ui';

import 'package:hive_flutter/adapters.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/response/user.dart';
import 'cache_manager.dart';

const _authCache = 'AuthCache';
const _userCache = 'UserCache';
const _settingsCache = 'SettingsCache';

const _refreshTokenKey = 'RefreshTokenKey';
const _accessTokenKey = 'AccessTokenKey';
const _refreshTokenTime = 'RefreshTokenTime';
const _localeKey = 'LocaleKey';

const _userKey = 'UserKey';
const _firstOpen = 'FirstOpen';
late final Box settingsBox;

class DataCacheManager implements CacheManager {
  final Future<Box> _authBox = Hive.openBox(_authCache);
  final Future<Box> _userBox = Hive.openBox(_userCache);
  final Future<Box> _settingsBox = Hive.openBox(_settingsCache);

  @override
  Future<String?> getAccessToken() async {
    final box = await _authBox;
    return box.get(_accessTokenKey);
  }

  @override
  Future<void> saveAccessToken(String token) async {
    final box = await _authBox;
    await box.put(_accessTokenKey, token);
  }

  @override
  Future<int> getRefreshTokenTime() async {
    final box = await _authBox;
    return box.get(_refreshTokenTime, defaultValue: 0);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    final box = await _authBox;
    return box.put(_refreshTokenKey, token);
  }

  @override
  Future<String?> getRefreshToken() async {
    final box = await _authBox;
    return box.get(_refreshTokenKey);
  }

  @override
  Future<void> saveRefreshTokenTime(int expiresIn) async {
    final box = await _authBox;
    return box.put(
        _refreshTokenTime, DateTime.now().millisecondsSinceEpoch + expiresIn);
  }

  @override
  Future<void> clear() async {
    final box = await _authBox;
    await box.clear();
    final userBox = await _userBox;
    await userBox.clear();
  }


  @override
  Future<void> saveUser(User userDetails) async {
    final box = await _userBox;
    return box.put(_userKey, userDetails);
  }

  @override
  Stream<User?> get userDetails async* {
    final box = await _userBox;
    yield* box.watch(key: _userKey).map((event) {
      return event.value as User?;
    }).startWith(box.get(_userKey));
  }


  @override
  Future<bool> isFirstOpen() async {
    final box = await _settingsBox;
    return box.get(_firstOpen, defaultValue: true);
  }

  @override
  Future<void> setIsFirstOpen() async {
    final box = await _settingsBox;
    return box.put(_firstOpen, false);
  }

  @override
  Future<int?> getUserId() async {
    try {
      final box = await _userBox;
      final user = box.get(_userKey);
      if (user != null && user is User) {
        return user.id;
      }
      return null;
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await getAccessToken();
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }


  @override
  Stream<Locale?> get locale async* {
    final box = await _settingsBox;
    yield* box.watch(key: _localeKey).map((event) {
      final currentLanguageCode = event.value as String?;
      return currentLanguageCode == null ? null : Locale((currentLanguageCode));
    }).startWith(
      box.get(_localeKey) == null
          ? null
          : Locale(
        box.get(_localeKey),
      ),
    );
  }

  @override
  Future<void> saveLocale(Locale locale) async {
    final box = await _settingsBox;
    return box.put(_localeKey, locale.languageCode);
  }

  @override
  Locale? getLocale() {
    return Locale(
      settingsBox.get(_localeKey),
    );
  }

  // ДОБАВИТЬ ЭТОТ МЕТОД
  @override
  Future<Locale?> getLocaleAsync() async {
    final box = await _settingsBox;
    final languageCode = box.get(_localeKey);
    return languageCode == null ? null : Locale(languageCode);
  }
}
