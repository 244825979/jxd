import 'package:flutter/foundation.dart';
import 'apple_auth_service.dart';
import 'data_service.dart';
import 'storage_service.dart';

class AppInitializationService {
  static final AppInitializationService _instance = AppInitializationService._internal();
  factory AppInitializationService() => _instance;
  AppInitializationService._internal();

  bool _isInitialized = false;
  late AppleAuthService _authService;
  late DataService _dataService;

  /// 初始化应用，检查登录状态并同步数据
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🚀 开始应用初始化...');

      // 初始化服务
      await StorageService.getInstance();
      _authService = AppleAuthService();
      _dataService = DataService.getInstance();

      // 检查Apple登录状态
      await _checkAndSyncLoginStatus();

      _isInitialized = true;
      debugPrint('✅ 应用初始化完成');

    } catch (e) {
      debugPrint('❌ 应用初始化失败: $e');
      // 即使初始化失败也要设置为已初始化，避免重复初始化
      _isInitialized = true;
    }
  }

  /// 检查并同步登录状态
  Future<void> _checkAndSyncLoginStatus() async {
    try {
      debugPrint('🔍 检查Apple登录状态...');

      // 检查Apple登录状态
      final isAppleLoggedIn = await _authService.isLoggedIn();
      final isDataServiceLoggedIn = _dataService.isLoggedIn();

      debugPrint('🔍 Apple登录状态: $isAppleLoggedIn');
      debugPrint('🔍 DataService登录状态: $isDataServiceLoggedIn');

      if (isAppleLoggedIn) {
        // Apple已登录，获取用户信息
        final appleUser = await _authService.getCurrentUser();
        if (appleUser != null) {
          debugPrint('👤 获取到Apple用户信息: ${appleUser.displayName}');

          if (!isDataServiceLoggedIn) {
            // DataService未登录，同步Apple用户数据
            debugPrint('🔄 同步Apple用户数据到DataService...');
            await _syncAppleUserToDataService(appleUser);
          } else {
            // 两边都已登录，确保数据一致性
            debugPrint('🔄 检查数据一致性...');
            await _ensureDataConsistency(appleUser);
          }

          // 恢复或保存用户数据到本地
          await _dataService.saveUserDataToLocal();
          
          debugPrint('✅ 登录状态同步完成');
        } else {
          debugPrint('⚠️ Apple登录状态有效但无法获取用户信息');
          // Apple登录有问题，重置状态
          _dataService.setLoginStatus(false);
        }
      } else {
        // Apple未登录
        if (isDataServiceLoggedIn) {
          debugPrint('🔄 Apple已退出，重置DataService登录状态');
          _dataService.setLoginStatus(false);
        }
        debugPrint('ℹ️ 用户未登录，保持游客状态');
      }

    } catch (e) {
      debugPrint('❌ 检查登录状态失败: $e');
      // 出错时确保数据一致性
      _dataService.setLoginStatus(false);
    }
  }

  /// 同步Apple用户数据到DataService
  Future<void> _syncAppleUserToDataService(appleUser) async {
    try {
      // 设置登录状态
      _dataService.setLoginStatus(
        true,
        email: appleUser.email,
        nickname: appleUser.displayName,
      );

      // 生成随机头像（如果需要的话）
      final currentUser = _dataService.getCurrentUser();
      if (currentUser.avatar.contains('user_1.png')) {
        final random = DateTime.now().millisecondsSinceEpoch % 30 + 1;
        final avatarPath = 'assets/images/avatars/user_$random.png';
        
        final updatedUser = currentUser.copyWith(
          nickname: appleUser.displayName,
          email: appleUser.email,
          avatar: avatarPath,
        );
        
        _dataService.setCurrentUser(updatedUser);
      }

      debugPrint('✅ Apple用户数据同步完成');

    } catch (e) {
      debugPrint('❌ 同步Apple用户数据失败: $e');
    }
  }

  /// 确保Apple用户数据和DataService数据一致性
  Future<void> _ensureDataConsistency(appleUser) async {
    try {
      final currentUser = _dataService.getCurrentUser();
      
      // 检查是否需要更新用户信息
      bool needsUpdate = false;
      if (currentUser.nickname != appleUser.displayName) {
        debugPrint('🔄 检测到昵称变化: ${currentUser.nickname} -> ${appleUser.displayName}');
        needsUpdate = true;
      }
      if (currentUser.email != appleUser.email) {
        debugPrint('🔄 检测到邮箱变化: ${currentUser.email} -> ${appleUser.email}');
        needsUpdate = true;
      }

      if (needsUpdate) {
        final updatedUser = currentUser.copyWith(
          nickname: appleUser.displayName,
          email: appleUser.email,
        );
        
        _dataService.setCurrentUser(updatedUser);
        debugPrint('✅ 用户数据已更新');
      }

    } catch (e) {
      debugPrint('❌ 确保数据一致性失败: $e');
    }
  }

  /// 获取初始化状态
  bool get isInitialized => _isInitialized;

  /// 强制重新初始化（用于登录状态变化后）
  Future<void> reinitialize() async {
    _isInitialized = false;
    await initialize();
  }
} 