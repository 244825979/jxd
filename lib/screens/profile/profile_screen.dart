import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/storage_service.dart';
import '../../services/data_service.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await StorageService.getInstance();
    _dataService = DataService.getInstance();
    _currentUser = _dataService.getCurrentUser();
    setState(() {
      _isInitialized = true;
    });
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
                          avatarPath: _currentUser.avatar,
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
                                  _currentUser.nickname,
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
                                        : AppColors.textHint.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _currentUser.isVip 
                                          ? const Color(0xFFFFD700)
                                          : AppColors.textHint,
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
                                            : AppColors.textHint,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          _currentUser.userLevel,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: _currentUser.isVip 
                                              ? const Color(0xFFFFD700)
                                              : AppColors.textHint,
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
                            if (_currentUser.mood.isNotEmpty)
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyLikedPostsScreen(),
                              ),
                            );
                          },
                          child: _buildStatItem(
                            '获赞',
                            _currentUser.likeCount.toString(),
                            Icons.favorite,
                            Colors.red.shade400,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyBookmarkedPostsScreen(),
                              ),
                            ).then((_) {
                              // 从收藏页面返回时刷新用户数据
                              setState(() {
                                _currentUser = _dataService.getCurrentUser();
                              });
                            });
                          },
                          child: _buildStatItem(
                            '收藏',
                            _currentUser.collectionCount.toString(),
                            Icons.bookmark,
                            AppColors.accent,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyPostsScreen(),
                              ),
                            ).then((_) {
                              // 从我的发布页面返回时刷新用户数据
                              setState(() {
                                _currentUser = _dataService.getCurrentUser();
                              });
                            });
                          },
                          child: _buildStatItem(
                            '发布',
                            _currentUser.postCount.toString(),
                            Icons.article,
                            const Color(0xFF27AE60),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DaysDetailScreen(user: _currentUser),
                              ),
                            );
                          },
                          child: _buildStatItem(
                            '天数',
                            _currentUser.daysSinceJoin.toString(),
                            Icons.calendar_today,
                            const Color(0xFF8E44AD),
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
                          );
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