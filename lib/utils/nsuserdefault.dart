import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NSUserDefault{
  NSUserDefault._internal();

  factory NSUserDefault() => _instance;

  static late final NSUserDefault _instance = NSUserDefault._internal();

  static SharedPreferences? _preferences;

  static SharedPreferences get _prefs {
    if (_preferences == null) {
      throw StateError('NSUserDefault 尚未初始化，请先调用 await NSUserDefault.getInstance()');
    }
    return _preferences!;
  }

  static Future<NSUserDefault> getInstance() async {
    _preferences ??= await SharedPreferences.getInstance();
    return _instance;
  }

  Future<bool> setString(String key, String value){
    return _prefs.setString(key, value);
  }

  Future<bool> setInt(String key, int value){
    return _prefs.setInt(key, value);
  }

  Future<bool> setDouble(String key, double value){
    return _prefs.setDouble(key, value);
  }

  Future<bool> setBool(String key, bool value){
    return _prefs.setBool(key, value);
  }

  Future<bool> setStringList(String key, List<String> value){
    return _prefs.setStringList(key, value);
  }

  Future<bool> setMap(String key, Map value){
    return _prefs.setString(key, json.encode(value));
  }

  Future<void> setValueForKey<T>(String key, T value) async {
    if (value is String) {
      await setString(key, value);
    } else if (value is int) {
      await setInt(key, value);
    } else if (value is bool) {
      await setBool(key, value);
    } else if (value is double) {
      await setDouble(key, value);
    } else if (value is List<String>) {
      await setStringList(key, value);
    } else if (value is Map) {
      await setMap(key, value);
    }
  }

  dynamic getValueForKey(String key){
    return _prefs.get(key);
  }

  Map? getMapValueForKey(String key){
    String? value = _prefs.getString(key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map;
    } catch(e) {
      return null;
    }
  }

  Future<void> removeValueForKey(String key) async {
    await _prefs.remove(key);
  }

  Future<void> removeAllValue() async {
    await _prefs.clear();
  }
}
