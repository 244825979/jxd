import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_record.dart';
import '../models/user_data.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // 存储键
  static const String _moodRecordsKey = 'mood_records';
  static const String _userDataKey = 'user_data';


  // 心情记录相关
  Future<void> saveMoodRecords(List<MoodRecord> records) async {
    final jsonList = records.map((record) => record.toJson()).toList();
    await _prefs!.setString(_moodRecordsKey, jsonEncode(jsonList));
  }

  Future<List<MoodRecord>> getMoodRecords() async {
    final jsonString = _prefs!.getString(_moodRecordsKey);
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => MoodRecord.fromJson(json)).toList();
  }

  Future<void> addMoodRecord(MoodRecord record) async {
    final records = await getMoodRecords();
    records.add(record);
    await saveMoodRecords(records);
  }

  // 用户数据相关
  Future<void> saveUserData(UserData userData) async {
    await _prefs!.setString(_userDataKey, jsonEncode(userData.toJson()));
  }

  Future<UserData> getUserData() async {
    final jsonString = _prefs!.getString(_userDataKey);
    if (jsonString == null) return UserData();
    
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return UserData.fromJson(json);
  }

  // 通用存储方法
  Future<void> saveString(String key, String value) async {
    await _prefs!.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _prefs!.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs!.setBool(key, value);
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    return _prefs!.getBool(key) ?? defaultValue;
  }

  Future<void> saveInt(String key, int value) async {
    await _prefs!.setInt(key, value);
  }

  Future<int> getInt(String key, {int defaultValue = 0}) async {
    return _prefs!.getInt(key) ?? defaultValue;
  }

  Future<void> saveDouble(String key, double value) async {
    await _prefs!.setDouble(key, value);
  }

  Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    return _prefs!.getDouble(key) ?? defaultValue;
  }

  Future<void> saveStringList(String key, List<String> value) async {
    await _prefs!.setStringList(key, value);
  }

  Future<List<String>> getStringList(String key) async {
    return _prefs!.getStringList(key) ?? [];
  }

  // 清理数据
  Future<void> clear() async {
    await _prefs!.clear();
  }

  Future<void> remove(String key) async {
    await _prefs!.remove(key);
  }

  // 检查键是否存在
  bool containsKey(String key) {
    return _prefs!.containsKey(key);
  }

  // 获取所有键
  Set<String> getKeys() {
    return _prefs!.getKeys();
  }
} 