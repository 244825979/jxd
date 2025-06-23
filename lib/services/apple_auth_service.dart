import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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

  // 检查Apple登录是否可用
  Future<bool> isAppleSignInAvailable() async {
    try {
      return await SignInWithApple.isAvailable();
    } catch (e) {
      if (kDebugMode) {
        print('检查Apple登录可用性失败: $e');
      }
      return false;
    }
  }

  // 执行Apple登录
  Future<({AppleSignInResult result, AppleUserInfo? userInfo, String? error})> signInWithApple() async {
    try {
      if (kDebugMode) {
        print('开始Apple登录流程...');
      }

      // 检查是否支持Apple登录
      final isAvailable = await isAppleSignInAvailable();
      if (kDebugMode) {
        print('Apple登录可用性: $isAvailable');
      }
      
      if (!isAvailable) {
        return (
          result: AppleSignInResult.unavailable,
          userInfo: null,
          error: 'Apple登录在此设备上不可用'
        );
      }

      // 生成nonce用于安全验证
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);
      
      if (kDebugMode) {
        print('生成nonce完成，准备发起Apple登录请求...');
      }

      // 发起Apple登录请求
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      if (kDebugMode) {
        print('获取Apple凭证成功: userId=${credential.userIdentifier}, email=${credential.email}');
      }

      // 处理用户信息
      final email = credential.email ?? '';
      final userId = credential.userIdentifier ?? '';
      
      if (userId.isEmpty) {
        if (kDebugMode) {
          print('Apple登录失败: 用户ID为空');
        }
        return (
          result: AppleSignInResult.failed,
          userInfo: null,
          error: '获取用户信息失败，请重试'
        );
      }
      
      final userInfo = AppleUserInfo(
        userId: userId,
        email: email,
        givenName: credential.givenName,
        familyName: credential.familyName,
        isVerified: email.isNotEmpty,
        loginTime: DateTime.now(),
      );

      // 保存登录信息
      await _saveUserInfo(userInfo);
      final storage = await _getStorage();
      await storage.saveBool('is_logged_in', true);

      if (kDebugMode) {
        print('Apple登录成功: ${userInfo.displayName}');
      }

      return (
        result: AppleSignInResult.success,
        userInfo: userInfo,
        error: null
      );

    } on SignInWithAppleAuthorizationException catch (e) {
      if (kDebugMode) {
        print('Apple登录授权异常: ${e.code} - ${e.message}');
      }

      // 处理Apple特定的异常
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          return (
            result: AppleSignInResult.cancelled,
            userInfo: null,
            error: '用户取消了登录'
          );
        case AuthorizationErrorCode.failed:
          return (
            result: AppleSignInResult.failed,
            userInfo: null,
            error: '登录验证失败，请重试'
          );
        case AuthorizationErrorCode.invalidResponse:
          return (
            result: AppleSignInResult.failed,
            userInfo: null,
            error: '登录响应无效，请重试'
          );
        case AuthorizationErrorCode.notHandled:
          return (
            result: AppleSignInResult.failed,
            userInfo: null,
            error: '登录请求未处理，请重试'
          );
        case AuthorizationErrorCode.unknown:
        default:
          return (
            result: AppleSignInResult.failed,
            userInfo: null,
            error: '登录失败，未知错误'
          );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Apple登录出现异常: $e');
        print('异常类型: ${e.runtimeType}');
      }

      // 处理其他类型的错误
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('canceled') || errorString.contains('cancelled')) {
        return (
          result: AppleSignInResult.cancelled,
          userInfo: null,
          error: '用户取消了登录'
        );
      }

      return (
        result: AppleSignInResult.failed,
        userInfo: null,
        error: '登录过程中发生错误，请重试'
      );
    }
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

  // 获取当前登录的用户信息
  Future<AppleUserInfo?> getCurrentUser() async {
    try {
      final storage = await _getStorage();
      final isLoggedIn = await storage.getBool('is_logged_in', defaultValue: false);
      if (!isLoggedIn) return null;

      final userJson = await storage.getString('apple_user_info');
      if (userJson == null || userJson.isEmpty) return null;

      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return AppleUserInfo.fromJson(userMap);
    } catch (e) {
      if (kDebugMode) {
        print('获取用户信息失败: $e');
      }
      return null;
    }
  }

  // 检查是否已登录
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
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
      if (kDebugMode) {
        print('更新昵称失败: $e');
      }
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
      
      if (kDebugMode) {
        print('用户已登出');
      }
    } catch (e) {
      if (kDebugMode) {
        print('登出失败: $e');
      }
    }
  }

  // 删除账户（注销）
  Future<void> deleteAccount() async {
    try {
      // 清除所有用户数据
      final storage = await _getStorage();
      await storage.clear();
      
      if (kDebugMode) {
        print('账户已注销');
      }
    } catch (e) {
      if (kDebugMode) {
        print('注销账户失败: $e');
      }
    }
  }

  // 获取登录凭证状态（用于检查登录是否仍然有效）
  Future<bool> checkCredentialState() async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;

      final credentialState = await SignInWithApple.getCredentialState(
        currentUser.userId,
      );

      switch (credentialState) {
        case CredentialState.authorized:
          return true;
        case CredentialState.revoked:
        case CredentialState.notFound:
          // 凭证已被撤销或不存在，需要重新登录
          await signOut();
          return false;
        default:
          return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('检查凭证状态失败: $e');
      }
      return false;
    }
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