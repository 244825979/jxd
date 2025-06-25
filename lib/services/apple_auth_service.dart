import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'storage_service.dart';
import 'data_service.dart';

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
      final emailPrefix = email.split('@')[0];
      // 过滤掉Apple的私人邮箱中的随机字符串
      if (emailPrefix.length <= 8 && !emailPrefix.contains('privaterelay')) {
        return emailPrefix;
      }
    }
    // 生成简洁的默认昵称，不包含随机数字
    return '心灵旅者';
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
  DataService? _dataService;

  // 初始化存储服务
  Future<StorageService> _getStorage() async {
    _storage ??= await StorageService.getInstance();
    return _storage!;
  }

  // 获取数据服务
  DataService _getDataService() {
    _dataService ??= DataService.getInstance();
    return _dataService!;
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
      debugPrint('检查Apple登录可用性失败: $e');
      return false;
    }
  }

  // 执行Apple登录
  Future<({AppleSignInResult result, AppleUserInfo? userInfo, String? error})> signInWithApple() async {
    try {
      // 检查是否支持Apple登录
      if (!await isAppleSignInAvailable()) {
        return (
          result: AppleSignInResult.unavailable,
          userInfo: null,
          error: '此设备不支持Apple登录'
        );
      }

      debugPrint('🍎 开始Apple登录流程...');

      // 生成安全随机数
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      debugPrint('🔐 生成安全随机数完成');

      // 请求授权（添加超时处理）
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏰ Apple登录请求超时');
          throw Exception('登录请求超时，请检查网络连接');
        },
      );

      debugPrint('🍎 Apple登录成功');
      debugPrint('User ID: ${credential.userIdentifier}');
      debugPrint('Email: ${credential.email}');
      debugPrint('Given Name: ${credential.givenName}');
      debugPrint('Family Name: ${credential.familyName}');

      // 创建用户信息
      final userInfo = AppleUserInfo(
        userId: credential.userIdentifier ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}',
        email: credential.email ?? '', // Apple可能返回空邮箱
        givenName: credential.givenName,
        familyName: credential.familyName,
        nickname: null, // 初始为空，后续可以设置
        isVerified: true, // Apple登录默认已验证
        loginTime: DateTime.now(),
      );

      // 保存用户信息
      await _saveUserInfo(userInfo);

      // 同步到DataService
      await _syncToDataService(userInfo);

      return (
        result: AppleSignInResult.success,
        userInfo: userInfo,
        error: null
      );

    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint('Apple登录授权异常: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          return (
            result: AppleSignInResult.cancelled,
            userInfo: null,
            error: '用户取消登录'
          );
        case AuthorizationErrorCode.failed:
          return (
            result: AppleSignInResult.failed,
            userInfo: null,
            error: '登录失败，请重试'
          );
        case AuthorizationErrorCode.invalidResponse:
          return (
            result: AppleSignInResult.failed,
            userInfo: null,
            error: '登录响应无效'
          );
        case AuthorizationErrorCode.notHandled:
          return (
            result: AppleSignInResult.failed,
            userInfo: null,
            error: '登录请求未处理'
          );
        case AuthorizationErrorCode.unknown:
        default:
          return (
            result: AppleSignInResult.failed,
            userInfo: null,
            error: '未知错误，请重试'
          );
      }
    } catch (e) {
      debugPrint('Apple登录未知错误: $e');
      
      // 检查是否是网络相关错误
      String errorMessage = '登录失败';
      if (e.toString().contains('timeout') || 
          e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = '网络连接超时，请检查网络后重试';
      } else if (e.toString().contains('server')) {
        errorMessage = 'Apple服务器暂时不可用，请稍后重试';
      } else {
        errorMessage = '登录失败，请重试';
      }
      
      return (
        result: AppleSignInResult.failed,
        userInfo: null,
        error: errorMessage
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
    await storage.saveBool('is_apple_logged_in', true);
    
    debugPrint('💾 Apple用户信息已保存');
  }

  // 同步到DataService
  Future<void> _syncToDataService(AppleUserInfo userInfo) async {
    final dataService = _getDataService();
    
    // 生成随机头像
    final avatarIndex = Random().nextInt(30) + 1;
    final avatarPath = 'assets/images/avatars/user_$avatarIndex.png';
    
    // 设置登录状态和用户信息
    dataService.setLoginStatus(
      true,
      email: userInfo.email,
      nickname: userInfo.displayName,
    );
    
    // 更新用户的其他信息
    final currentUser = dataService.getCurrentUser();
    final updatedUser = currentUser.copyWith(
      nickname: userInfo.displayName,
      email: userInfo.email,
      avatar: avatarPath,
      // 可以根据需要设置VIP状态，这里暂时保持原状态
    );
    
    // 保存更新后的用户数据
    dataService.setCurrentUser(updatedUser);
    
    debugPrint('🔄 用户数据已同步到DataService');
    debugPrint('昵称: ${userInfo.displayName}');
    debugPrint('邮箱: ${userInfo.email}');
    debugPrint('头像: $avatarPath');
  }

  // 获取当前登录的用户信息
  Future<AppleUserInfo?> getCurrentUser() async {
    try {
      final storage = await _getStorage();
      final userJson = await storage.getString('apple_user_info');
      if (userJson == null) return null;
      
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return AppleUserInfo.fromJson(userMap);
    } catch (e) {
      debugPrint('获取当前Apple用户信息失败: $e');
      return null;
    }
  }

  // 检查是否已登录
  Future<bool> isLoggedIn() async {
    try {
      final storage = await _getStorage();
      final isAppleLoggedIn = await storage.getBool('is_apple_logged_in') ?? false;
      
      if (!isAppleLoggedIn) return false;
      
      // 检查用户信息是否存在
      final userInfo = await getCurrentUser();
      if (userInfo == null) {
        // 如果用户信息不存在，清除登录状态
        await storage.saveBool('is_apple_logged_in', false);
        return false;
      }
      
      // 验证凭证状态（可选）
      return await checkCredentialState(userInfo.userId);
      
    } catch (e) {
      debugPrint('检查Apple登录状态失败: $e');
      return false;
    }
  }

  // 检查登录凭证状态
  Future<bool> checkCredentialState(String userId) async {
    try {
      final credentialState = await SignInWithApple.getCredentialState(userId);
      
      switch (credentialState) {
        case CredentialState.authorized:
          return true;
        case CredentialState.revoked:
        case CredentialState.notFound:
          // 凭证已撤销或不存在，清除本地登录状态
          await signOut();
          return false;
        // 移除 CredentialState.transferred，因为在当前版本中可能不存在
        default:
          // 其他状态默认认为仍然有效
          return true;
      }
    } catch (e) {
      debugPrint('检查凭证状态失败: $e');
      // 如果检查失败，假设仍然有效
      return true;
    }
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
      
      // 同时更新DataService中的用户信息
      final dataService = _getDataService();
      final user = dataService.getCurrentUser();
      final newUser = user.copyWith(nickname: nickname);
      dataService.setCurrentUser(newUser);
      
      return true;
    } catch (e) {
      debugPrint('更新用户昵称失败: $e');
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
      await storage.saveBool('is_apple_logged_in', false);
      
      // 同时更新DataService的登录状态
      final dataService = _getDataService();
      dataService.setLoginStatus(false);
      
      debugPrint('🚪 Apple登录已登出');
    } catch (e) {
      debugPrint('Apple登出失败: $e');
    }
  }

  // 删除账户（注销）
  Future<void> deleteAccount() async {
    try {
      // 清除所有用户数据
      final storage = await _getStorage();
      await storage.clear();
      
      // 重置DataService
      final dataService = _getDataService();
      dataService.resetUserData();
      
      debugPrint('🗑️ Apple账户已删除');
    } catch (e) {
      debugPrint('删除Apple账户失败: $e');
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