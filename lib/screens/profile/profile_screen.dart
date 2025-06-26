import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/storage_service.dart';
import '../../services/data_service.dart';
import '../../services/apple_auth_service.dart';
import '../../models/user.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/user_avatar.dart';
import 'agreement_screen.dart';
import 'about_screen.dart';
import 'days_detail_screen.dart';
import 'my_liked_posts_screen.dart';
import 'my_bookmarked_posts_screen.dart';
import 'my_reports_screen.dart';
import 'my_blocked_posts_screen.dart';
import 'my_posts_screen.dart';
import 'my_feedbacks_screen.dart';
import 'settings_screen.dart';
import 'recharge_center_screen.dart';
import 'account_management_screen.dart';
import 'vip_subscription_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isInitialized = false;
  late User _currentUser;
  late DataService _dataService;
  late AppleAuthService _authService;
  bool _isLoggedIn = false; // 添加登录状态标记

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 页面重新进入时简单刷新状态
    if (_isInitialized) {
      _refreshUserState();
    }
  }

  // 简单刷新用户状态（从DataService获取最新状态）
  void _refreshUserState() {
    final isLoggedIn = _dataService.isLoggedIn();
    final currentUser = _dataService.getCurrentUser();
    
    if (mounted && (_isLoggedIn != isLoggedIn || _currentUser.id != currentUser.id)) {
      setState(() {
        _isLoggedIn = isLoggedIn;
        _currentUser = currentUser;
      });
      debugPrint('🔄 Profile页面状态已刷新: 登录状态=$_isLoggedIn, 昵称=${_currentUser.nickname}');
    }
  }

  Future<void> _initializeServices() async {
    await StorageService.getInstance();
    _dataService = DataService.getInstance();
    _authService = AppleAuthService();
    
    // 初始化时检查登录状态并同步数据
    await _checkLoginStatusAndSyncData();
    
    setState(() {
      _isInitialized = true;
    });
  }

  // 检查登录状态并同步用户数据
  Future<void> _checkLoginStatusAndSyncData() async {
    try {
      debugPrint('🔍 Profile页面：开始检查登录状态...');
      
      // 检查Apple登录状态
      final isAppleLoggedIn = await _authService.isLoggedIn();
      final isDataServiceLoggedIn = _dataService.isLoggedIn();
      
      debugPrint('🔍 Apple登录状态: $isAppleLoggedIn');
      debugPrint('🔍 DataService登录状态: $isDataServiceLoggedIn');
      
      _isLoggedIn = isAppleLoggedIn && isDataServiceLoggedIn;
      
      // 如果Apple已登录但DataService未同步，则同步数据
      if (isAppleLoggedIn && !isDataServiceLoggedIn) {
        debugPrint('🔄 检测到Apple已登录但数据未同步，开始同步...');
        await _syncAppleUserData();
      }
      
      // 如果Apple已登录，确保用户数据是最新的
      if (isAppleLoggedIn) {
        await _refreshUserDataFromApple();
      }
      
      // 更新当前用户数据
      _currentUser = _dataService.getCurrentUser();
      
      if (mounted) {
        setState(() {});
      }
      
      debugPrint('🏁 Profile页面：登录状态检查完成，最终状态: $_isLoggedIn');
      debugPrint('👤 当前用户昵称: ${_currentUser.nickname}');
      debugPrint('💎 VIP状态: ${_currentUser.isVip}');
      
    } catch (e) {
      debugPrint('❌ Profile页面检查登录状态失败: $e');
      // 出错时使用DataService的状态
      _isLoggedIn = _dataService.isLoggedIn();
      _currentUser = _dataService.getCurrentUser();
      if (mounted) {
        setState(() {});
      }
    }
  }

  // 同步Apple用户数据到DataService
  Future<void> _syncAppleUserData() async {
    try {
      final appleUser = await _authService.getCurrentUser();
      if (appleUser != null) {
        debugPrint('📥 开始同步Apple用户数据...');
        
        // 设置登录状态
        _dataService.setLoginStatus(
          true,
          email: appleUser.email,
          nickname: appleUser.displayName,
        );
        
        // 生成随机头像（如果没有的话）
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
      }
    } catch (e) {
      debugPrint('❌ 同步Apple用户数据失败: $e');
    }
  }

  // 从Apple刷新用户数据
  Future<void> _refreshUserDataFromApple() async {
    try {
      final appleUser = await _authService.getCurrentUser();
      if (appleUser != null) {
        final currentUser = _dataService.getCurrentUser();
        
        // 只有昵称或邮箱发生变化时才更新
        if (currentUser.nickname != appleUser.displayName || 
            currentUser.email != appleUser.email) {
          debugPrint('🔄 检测到Apple用户数据变化，更新本地数据...');
          
          final updatedUser = currentUser.copyWith(
            nickname: appleUser.displayName,
            email: appleUser.email,
          );
          
          _dataService.setCurrentUser(updatedUser);
          debugPrint('✅ 用户数据已更新');
        }
      }
    } catch (e) {
      debugPrint('❌ 刷新Apple用户数据失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息卡片
            CustomCard(
              child: Column(
                children: [
                  // 用户头像和基本信息
                  Row(
                    children: [
                      // 用户头像
                      GestureDetector(
                        onLongPress: () {
                          // 长按头像切换VIP状态（用于测试）
                          _dataService.setVipStatus(!_currentUser.isVip);
                          setState(() {
                            _currentUser = _dataService.getCurrentUser();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_currentUser.isVip ? 'VIP已开通' : 'VIP已关闭'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: UserAvatar(
                          avatarPath: _isLoggedIn ? _currentUser.avatar : 'assets/images/avatars/user_1.png', // 未登录时使用默认头像
                          size: 80,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // 用户信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _isLoggedIn ? _currentUser.nickname : '游客', // 未登录时显示"游客"
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    // 点击VIP按钮跳转到VIP开通页面
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const VipSubscriptionScreen(),
                                      ),
                                    ).then((_) {
                                      // 从VIP页面返回后刷新用户数据
                                      setState(() {
                                        _currentUser = _dataService.getCurrentUser();
                                        _isLoggedIn = _dataService.isLoggedIn();
                                      });
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _currentUser.isVip 
                                        ? const Color(0xFFFFD700).withOpacity(0.2)
                                        : AppColors.textHint.withOpacity(0.1), // 非VIP时置灰
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _currentUser.isVip 
                                          ? const Color(0xFFFFD700)
                                          : AppColors.textHint, // 非VIP时置灰
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.diamond,
                                          size: 12,
                                          color: _currentUser.isVip 
                                            ? const Color(0xFFFFD700)
                                            : AppColors.textHint, // 非VIP时置灰
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          _currentUser.isVip ? 'VIP会员' : '普通用户', // 根据VIP状态显示
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: _currentUser.isVip 
                                              ? const Color(0xFFFFD700)
                                              : AppColors.textHint, // 非VIP时置灰
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_isLoggedIn && _currentUser.mood.isNotEmpty) // 只有登录时才显示心情
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.textSecondary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _currentUser.mood,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // 数据统计
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!_isLoggedIn) {
                              // 未登录时提示需要登录
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('请先登录后查看'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyLikedPostsScreen(),
                              ),
                            ).then((_) {
                              // 刷新状态
                              setState(() {
                                _currentUser = _dataService.getCurrentUser();
                                _isLoggedIn = _dataService.isLoggedIn();
                              });
                            });
                          },
                          child: _buildStatItem(
                            '获赞',
                            _isLoggedIn ? _currentUser.likeCount.toString() : '0',
                            Icons.favorite,
                            _isLoggedIn ? Colors.red.shade400 : AppColors.textHint,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!_isLoggedIn) {
                              // 未登录时提示需要登录
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('请先登录后查看'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyBookmarkedPostsScreen(),
                              ),
                            ).then((_) {
                              // 从收藏页面返回时刷新用户数据
                              setState(() {
                                _currentUser = _dataService.getCurrentUser();
                                _isLoggedIn = _dataService.isLoggedIn();
                              });
                            });
                          },
                          child: _buildStatItem(
                            '收藏',
                            _isLoggedIn ? _currentUser.collectionCount.toString() : '0',
                            Icons.bookmark,
                            _isLoggedIn ? AppColors.accent : AppColors.textHint,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!_isLoggedIn) {
                              // 未登录时提示需要登录
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('请先登录后查看'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyPostsScreen(),
                              ),
                            ).then((_) {
                              // 从我的发布页面返回时刷新用户数据
                              setState(() {
                                _currentUser = _dataService.getCurrentUser();
                                _isLoggedIn = _dataService.isLoggedIn();
                              });
                            });
                          },
                          child: _buildStatItem(
                            '发布',
                            _isLoggedIn ? _currentUser.postCount.toString() : '0',
                            Icons.article,
                            _isLoggedIn ? const Color(0xFF27AE60) : AppColors.textHint,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!_isLoggedIn) {
                              // 未登录时提示需要登录
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('请先登录后查看'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DaysDetailScreen(user: _currentUser),
                              ),
                            ).then((_) {
                              // 刷新状态
                              setState(() {
                                _currentUser = _dataService.getCurrentUser();
                                _isLoggedIn = _dataService.isLoggedIn();
                              });
                            });
                          },
                          child: _buildStatItem(
                            '天数',
                            _isLoggedIn ? _currentUser.daysSinceJoin.toString() : '0',
                            Icons.calendar_today,
                            _isLoggedIn ? const Color(0xFF8E44AD) : AppColors.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 功能菜单区域
            Column(
              children: [
                // 第一行：充值中心、账户管理
                Row(
                  children: [
                    Expanded(
                      child: _buildFunctionCard(
                        '充值中心',
                        '余额充值管理',
                        Icons.account_balance_wallet_outlined,
                        const Color(0xFF4CAF50),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RechargeCenterScreen(),
                            ),
                          ).then((_) {
                            // 从充值中心返回时刷新状态
                            setState(() {
                              _currentUser = _dataService.getCurrentUser();
                              _isLoggedIn = _dataService.isLoggedIn();
                            });
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFunctionCard(
                        '账户管理',
                        '安全设置中心',
                        Icons.manage_accounts_outlined,
                        const Color(0xFF2196F3),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AccountManagementScreen(),
                            ),
                          ).then((_) {
                            // 从账户管理页面返回时刷新用户数据
                            setState(() {
                              _currentUser = _dataService.getCurrentUser();
                              _isLoggedIn = _dataService.isLoggedIn();
                            });
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 第二行：我的设置、我的举报
                Row(
                  children: [
                    Expanded(
                      child: _buildFunctionCard(
                        '我的设置',
                        '个人偏好设置',
                        Icons.settings_outlined,
                        const Color(0xFF3498DB),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFunctionCard(
                        '我的举报',
                        '违规内容举报',
                        Icons.flag_outlined,
                        const Color(0xFFE74C3C),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyReportsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 第三行：我的屏蔽、意见反馈
                Row(
                  children: [
                    Expanded(
                      child: _buildFunctionCard(
                        '我的屏蔽',
                        '屏蔽用户管理',
                        Icons.block_outlined,
                        const Color(0xFF95A5A6),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyBlockedPostsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFunctionCard(
                        '我的反馈',
                        '查看反馈历史',
                        Icons.feedback_outlined,
                        const Color(0xFF27AE60),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyFeedbacksScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 第四行：我的协议、关于我们
                Row(
                  children: [
                    Expanded(
                                             child: _buildFunctionCard(
                         '我的协议',
                         '用户协议条款',
                         Icons.description_outlined,
                         const Color(0xFF9B59B6),
                         () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => const AgreementScreen(),
                             ),
                           );
                         },
                       ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                                             child: _buildFunctionCard(
                         '关于我们',
                         '了解静心岛',
                         Icons.info_outlined,
                         AppColors.accent,
                         () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => const AboutScreen(),
                             ),
                           );
                         },
                       ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建功能卡片
  Widget _buildFunctionCard(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderColor.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图标区域
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 12),
            
            // 标题
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            
            // 副标题
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 构建统计项目
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }
} 