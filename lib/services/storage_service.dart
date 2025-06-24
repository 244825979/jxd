import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_record.dart';
import '../models/user_data.dart';
import '../models/user.dart';

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
  static const String _keyUserId = 'user_id';
  static const String _keyNickname = 'user_nickname';
  static const String _keyAvatar = 'user_avatar';
  static const String _keyCoins = 'user_coins';
  static const String _keyIsVip = 'user_is_vip';
  static const String _keyVipExpireDate = 'user_vip_expire_date';
  static const String _keyLikeCount = 'user_like_count';
  static const String _keyCollectionCount = 'user_collection_count';
  static const String _keyPostCount = 'user_post_count';
  static const String _keyJoinDate = 'user_join_date';
  static const String _keyMood = 'user_mood';
  static const String _keyHasLocalData = 'has_local_user_data';


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

  // 保存用户数据到本地
  static Future<void> saveUserBackup(User user) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_keyUserId, user.id);
    await prefs.setString(_keyNickname, user.nickname);
    await prefs.setString(_keyAvatar, user.avatar);
    await prefs.setInt(_keyCoins, user.coins);
    await prefs.setBool(_keyIsVip, user.isVip);
    await prefs.setInt(_keyLikeCount, user.likeCount);
    await prefs.setInt(_keyCollectionCount, user.collectionCount);
    await prefs.setInt(_keyPostCount, user.postCount);
    await prefs.setString(_keyJoinDate, user.joinDate.toIso8601String());
    await prefs.setString(_keyMood, user.mood);
    await prefs.setBool(_keyHasLocalData, true);
    
    // VIP过期时间可能为null
    if (user.vipExpireDate != null) {
      await prefs.setString(_keyVipExpireDate, user.vipExpireDate!.toIso8601String());
    } else {
      await prefs.remove(_keyVipExpireDate);
    }
    
    print('📱 用户数据已保存到本地: ${user.nickname}, 金币: ${user.coins}, VIP: ${user.isVip}');
  }

  // 从本地加载用户数据
  static Future<User?> loadUserBackup() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 检查是否有本地数据
    if (!(prefs.getBool(_keyHasLocalData) ?? false)) {
      print('📱 本地无用户数据');
      return null;
    }

    try {
      final userId = prefs.getString(_keyUserId);
      final nickname = prefs.getString(_keyNickname);
      final avatar = prefs.getString(_keyAvatar);
      final coins = prefs.getInt(_keyCoins);
      final isVip = prefs.getBool(_keyIsVip);
      final likeCount = prefs.getInt(_keyLikeCount);
      final collectionCount = prefs.getInt(_keyCollectionCount);
      final postCount = prefs.getInt(_keyPostCount);
      final joinDateStr = prefs.getString(_keyJoinDate);
      final mood = prefs.getString(_keyMood);
      final vipExpireDateStr = prefs.getString(_keyVipExpireDate);

      if (userId == null || nickname == null || avatar == null || 
          coins == null || isVip == null || likeCount == null || 
          collectionCount == null || postCount == null || joinDateStr == null || mood == null) {
        print('📱 本地数据不完整，忽略');
        return null;
      }

      final joinDate = DateTime.parse(joinDateStr);
      final vipExpireDate = vipExpireDateStr != null ? DateTime.parse(vipExpireDateStr) : null;

      final user = User(
        id: userId,
        nickname: nickname,
        avatar: avatar,
        coins: coins,
        isVip: isVip,
        likeCount: likeCount,
        collectionCount: collectionCount,
        postCount: postCount,
        joinDate: joinDate,
        mood: mood,
        vipExpireDate: vipExpireDate,
      );

      print('📱 从本地加载用户数据: ${user.nickname}, 金币: ${user.coins}, VIP: ${user.isVip}');
      return user;
    } catch (e) {
      print('📱 加载本地用户数据失败: $e');
      return null;
    }
  }

  // 清除本地用户数据（完全删除，用于注销账户）
  static Future<void> clearUserBackup() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyNickname);
    await prefs.remove(_keyAvatar);
    await prefs.remove(_keyCoins);
    await prefs.remove(_keyIsVip);
    await prefs.remove(_keyVipExpireDate);
    await prefs.remove(_keyLikeCount);
    await prefs.remove(_keyCollectionCount);
    await prefs.remove(_keyPostCount);
    await prefs.remove(_keyJoinDate);
    await prefs.remove(_keyMood);
    await prefs.remove(_keyHasLocalData);
    
    print('📱 本地用户数据已清除');
  }

  // 检查是否有本地用户数据
  static Future<bool> hasLocalUserBackup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasLocalData) ?? false;
  }

  // 更新特定字段
  static Future<void> updateCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCoins, coins);
    print('📱 本地金币已更新: $coins');
  }

  static Future<void> updateVipStatus(bool isVip, DateTime? vipExpireDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsVip, isVip);
    
    if (vipExpireDate != null) {
      await prefs.setString(_keyVipExpireDate, vipExpireDate.toIso8601String());
    } else {
      await prefs.remove(_keyVipExpireDate);
    }
    
    print('📱 本地VIP状态已更新: $isVip');
  }
} 