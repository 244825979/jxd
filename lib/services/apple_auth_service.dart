import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

// 用户信息模型
class AppleUserInfo {
  final String userId;
  final String email;
  final String? givenName;
  final String? familyName;
  final String? nickname;
  final bool isVerified;
  final DateTime loginTime;

  AppleUserInfo({
    required this.userId,
    required this.email,
    this.givenName,
    this.familyName,
    this.nickname,
    required this.isVerified,
    required this.loginTime,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'givenName': givenName,
    'familyName': familyName,
    'nickname': nickname,
    'isVerified': isVerified,
    'loginTime': loginTime.toIso8601String(),
  };

  factory AppleUserInfo.fromJson(Map<String, dynamic> json) => AppleUserInfo(
    userId: json['userId'],
    email: json['email'],
    givenName: json['givenName'],
    familyName: json['familyName'],
    nickname: json['nickname'],
    isVerified: json['isVerified'] ?? true,
    loginTime: DateTime.parse(json['loginTime']),
  );

  String get displayName {
    if (nickname != null && nickname!.isNotEmpty) {
      return nickname!;
    }
    if (givenName != null && givenName!.isNotEmpty && familyName != null && familyName!.isNotEmpty) {
      return '$givenName $familyName'.trim();
    }
    if (givenName != null && givenName!.isNotEmpty) {
      return givenName!;
    }
    if (familyName != null && familyName!.isNotEmpty) {
      return familyName!;
    }
    if (email.isNotEmpty && email.contains('@')) {
      return email.split('@')[0]; // 使用邮箱前缀作为默认昵称
    }
    return '心灵旅者${userId.substring(0, 8)}'; // 使用用户ID作为最后的默认昵称
  }
}

// 登录结果
enum AppleSignInResult {
  success,
  cancelled,
  failed,
  unavailable,
}

class AppleAuthService {
  static final AppleAuthService _instance = AppleAuthService._internal();
  factory AppleAuthService() => _instance;
  AppleAuthService._internal();

  StorageService? _storage;

  // 初始化存储服务
  Future<StorageService> _getStorage() async {
    _storage ??= await StorageService.getInstance();
    return _storage!;
  }

  // 生成随机字符串用于安全验证
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  // 生成SHA256哈希
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 检查Apple登录是否可用 - 现在始终返回false
  Future<bool> isAppleSignInAvailable() async {
    // Apple登录功能已移除
    return false;
  }

  // 执行Apple登录 - 现在始终返回不可用
  Future<({AppleSignInResult result, AppleUserInfo? userInfo, String? error})> signInWithApple() async {
    // Apple登录功能已移除，直接返回不可用状态
    return (
      result: AppleSignInResult.unavailable,
      userInfo: null,
      error: 'Apple登录功能暂时不可用'
    );
  }

  // 保存用户信息
  Future<void> _saveUserInfo(AppleUserInfo userInfo) async {
    final storage = await _getStorage();
    final userJson = json.encode(userInfo.toJson());
    await storage.saveString('apple_user_info', userJson);
    await storage.saveString('user_id', userInfo.userId);
    await storage.saveString('user_email', userInfo.email);
    
    // 如果没有昵称，生成默认昵称
    if (userInfo.nickname == null || userInfo.nickname!.isEmpty) {
      final defaultNickname = _generateDefaultNickname(userInfo);
      await updateUserNickname(defaultNickname);
    }
  }

  // 生成默认昵称
  String _generateDefaultNickname(AppleUserInfo userInfo) {
    if (userInfo.givenName != null && userInfo.givenName!.isNotEmpty) {
      return userInfo.givenName!;
    }
    return '心灵旅者${DateTime.now().millisecondsSinceEpoch % 10000}';
  }

  // 获取当前登录的用户信息 - 始终返回null（Apple登录已移除）
  Future<AppleUserInfo?> getCurrentUser() async {
    // Apple登录功能已移除，始终返回null
    return null;
  }

  // 检查是否已登录 - 始终返回false（Apple登录已移除）
  Future<bool> isLoggedIn() async {
    // Apple登录功能已移除，始终返回false
    return false;
  }

  // 更新用户昵称
  Future<bool> updateUserNickname(String nickname) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;

      final updatedUser = AppleUserInfo(
        userId: currentUser.userId,
        email: currentUser.email,
        givenName: currentUser.givenName,
        familyName: currentUser.familyName,
        nickname: nickname,
        isVerified: currentUser.isVerified,
        loginTime: currentUser.loginTime,
      );

      await _saveUserInfo(updatedUser);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 登出
  Future<void> signOut() async {
    try {
      final storage = await _getStorage();
      await storage.remove('apple_user_info');
      await storage.remove('user_id');
      await storage.remove('user_email');
      await storage.saveBool('is_logged_in', false);
    } catch (e) {
      // 静默处理错误
    }
  }

  // 删除账户（注销）
  Future<void> deleteAccount() async {
    try {
      // 清除所有用户数据
      final storage = await _getStorage();
      await storage.clear();
    } catch (e) {
      // 静默处理错误
    }
  }

  // 获取登录凭证状态（用于检查登录是否仍然有效）- 现在始终返回false
  Future<bool> checkCredentialState() async {
    // Apple登录功能已移除，始终返回false
    return false;
  }

  // 获取用户统计信息
  Future<Map<String, dynamic>> getUserStats() async {
    final user = await getCurrentUser();
    if (user == null) return {};

    final loginDays = DateTime.now().difference(user.loginTime).inDays + 1;
    
    return {
      'loginDays': loginDays,
      'joinDate': user.loginTime.toString().split(' ')[0],
      'isVerified': user.isVerified,
      'email': user.email,
      'displayName': user.displayName,
    };
  }
} 