import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../../services/apple_auth_service.dart';
import '../../services/data_service.dart';
import 'recharge_center_screen.dart';
import 'vip_subscription_screen.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final AppleAuthService _authService = AppleAuthService();
  late final DataService _dataService;
  
  // 登录状态
  bool _isLoggedIn = false;
  bool _isLoading = true;
  
  // 用户数据
  AppleUserInfo? _currentUser;
  Map<String, dynamic> userInfo = {
    'nickname': '心灵旅者',
    'appleId': 'user@privaterelay.appleid.com',
    'joinDate': '2024-01-01',
    'avatar': 'assets/images/avatars/user_1.png',
    'isVip': false,
    'vipExpireDate': null,
    'coins': 0,
    'totalCoins': 0,
  };

  @override
  void initState() {
    super.initState();
    _dataService = DataService.getInstance();
    _checkLoginStatus();
  }

  // 检查登录状态
  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      final currentUser = await _authService.getCurrentUser();
      
      // 获取个人中心的用户数据作为默认昵称和金币
      final profileUser = _dataService.getCurrentUser();
      
      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _currentUser = currentUser;
          _isLoading = false;
          
          // 同步个人中心的数据
          userInfo['coins'] = profileUser.coins;
          userInfo['isVip'] = profileUser.isVip;
          userInfo['vipExpireDate'] = profileUser.vipExpireDate;
          
          // 更新用户信息
          if (currentUser != null) {
            final email = currentUser.email.isNotEmpty 
              ? currentUser.email 
              : '${currentUser.userId.substring(0, 8)}***@privaterelay.appleid.com';
            
            // 昵称优先级：Apple登录的昵称 > 个人中心昵称 > 默认昵称
            String displayNickname;
            if (currentUser.nickname != null && currentUser.nickname!.isNotEmpty) {
              displayNickname = currentUser.nickname!;
            } else {
              displayNickname = profileUser.nickname;
            }
            
            userInfo.addAll({
              'nickname': displayNickname,
              'appleId': email,
              'joinDate': currentUser.loginTime.toString().split(' ')[0],
              'userId': currentUser.userId,
              'isVerified': currentUser.isVerified,
            });
          } else {
            // 未登录时使用个人中心的昵称
            userInfo['nickname'] = profileUser.nickname;
          }
        });
      }
      
      // 检查凭证状态
      if (isLoggedIn && currentUser != null) {
        final isValid = await _authService.checkCredentialState();
        if (!isValid && mounted) {
          setState(() {
            _isLoggedIn = false;
            _currentUser = null;
          });
          _showErrorMessage('登录已过期，请重新登录');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('检查登录状态失败: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '账户管理',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
        ? _buildLoadingContent()
        : (_isLoggedIn ? _buildLoggedInContent() : _buildLoginContent()),
    );
  }

  // 加载状态界面
  Widget _buildLoadingContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.accent),
          SizedBox(height: 16),
          Text(
            '正在检查登录状态...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // 未登录界面
  Widget _buildLoginContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          
          // 应用图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.account_circle,
              size: 80,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 32),
          
          // 欢迎文案
          const Text(
            '欢迎来到静心岛',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '登录后享受更多个性化服务',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 60),
          
          // 登录按钮卡片
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    '安全登录',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Apple登录按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleAppleLogin,
                      icon: const Icon(
                        Icons.apple,
                        color: Colors.white,
                        size: 24,
                      ),
                      label: const Text(
                        '使用 Apple ID 登录',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 登录说明
                  const Text(
                    '我们使用Apple ID安全登录，保护您的隐私',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          
          // 服务条款
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '登录即表示同意',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
              GestureDetector(
                onTap: () => _showServiceTerms(),
                child: const Text(
                  '《用户协议》',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.accent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Text(
                '和',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
              GestureDetector(
                onTap: () => _showPrivacyPolicy(),
                child: const Text(
                  '《隐私政策》',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.accent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 已登录界面
  Widget _buildLoggedInContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 用户信息卡片
          _buildUserInfoCard(),
          const SizedBox(height: 16),
          
          // 快捷操作区域
          _buildQuickActionsSection(),
          const SizedBox(height: 16),
          
          // 账户管理
          _buildAccountManagementSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF667EEA), // 深紫蓝色
            Color(0xFF764BA2), // 深紫色
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头像和基本信息
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFF8F9FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: Color(0xFF667EEA),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            userInfo['nickname'] ?? '未设置',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (userInfo['isVip']) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.diamond, size: 12, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'VIP',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${userInfo['coins']} 金币',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _editNickname,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 快捷操作区域
  Widget _buildQuickActionsSection() {
    return Row(
      children: [
        // 充值按钮
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_circle_outline,
            title: '充值',
            subtitle: '购买金币',
            color: const Color(0xFF10B981), // 翠绿色
            onTap: _goToRecharge,
          ),
        ),
        const SizedBox(width: 12),
        // VIP升级按钮
        Expanded(
          child: _buildActionButton(
            icon: userInfo['isVip'] ? Icons.diamond : Icons.upgrade,
            title: userInfo['isVip'] ? 'VIP会员' : '升级VIP',
            subtitle: userInfo['isVip'] ? '已开通' : '解锁特权',
            color: userInfo['isVip'] ? const Color(0xFF8B5CF6) : const Color(0xFFF59E0B), // VIP紫色 / 金黄色
            onTap: userInfo['isVip'] ? null : _upgradeToVip,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 账户管理区域
  Widget _buildAccountManagementSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '账户设置',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Apple ID 信息
          Row(
            children: [
              const Icon(
                Icons.apple,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDisplayAppleId(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // 账户类型标签
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getAccountTypeDescription().contains('真实') 
                              ? Colors.green.shade50 
                              : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getAccountTypeDescription().contains('真实') 
                                ? Colors.green.shade200 
                                : Colors.blue.shade200,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            _getAccountTypeDescription(),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getAccountTypeDescription().contains('真实') 
                                ? Colors.green.shade700 
                                : Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (_isLoggedIn && _currentUser != null && _currentUser!.isVerified) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.verified,
                            size: 12,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '已验证',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                                        if (_getAccountTypeDescription().contains('隐私')) ...[
                      const SizedBox(height: 4),
                      const Text(
                        '此邮箱可正常接收邮件，苹果会转发到您的真实邮箱',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textHint,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 操作按钮
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: _buildSimpleButton(
                  title: '退出登录',
                  icon: Icons.logout,
                  color: const Color(0xFF6B7280), // 温和的灰蓝色
                  onTap: _logout,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _buildSimpleButton(
                  title: '注销账户',
                  icon: Icons.delete_outline,
                  color: const Color(0xFFEF4444), // 温和的红色
                  onTap: _deleteAccount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: color,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }



  // === 事件处理方法 ===

  // Apple登录处理
  Future<void> _handleAppleLogin() async {
    // 检查Apple登录是否可用
    final isAvailable = await _authService.isAppleSignInAvailable();
    if (!isAvailable) {
      _showErrorMessage('Apple登录在此设备上不可用');
      return;
    }

    // 显示加载提示
    _showLoadingDialog('正在登录...');

    try {
      // 执行Apple登录
      final result = await _authService.signInWithApple();
      
      // 关闭加载对话框
      _safeCloseLoadingDialog();
      
      if (mounted) {
        switch (result.result) {
          case AppleSignInResult.success:
            if (result.userInfo != null) {
              setState(() {
                _isLoggedIn = true;
                _currentUser = result.userInfo;
                
                // 更新用户信息
                final email = result.userInfo!.email.isNotEmpty 
                  ? result.userInfo!.email 
                  : '${result.userInfo!.userId.substring(0, 8)}***@privaterelay.appleid.com';
                
                // 获取个人中心的当前昵称
                final profileUser = _dataService.getCurrentUser();
                
                // 昵称优先级：Apple登录的昵称 > 个人中心昵称
                String finalNickname;
                if (result.userInfo!.nickname != null && result.userInfo!.nickname!.isNotEmpty) {
                  finalNickname = result.userInfo!.nickname!;
                } else if (result.userInfo!.displayName.isNotEmpty && result.userInfo!.displayName != '心灵旅者${result.userInfo!.userId.substring(0, 8)}') {
                  finalNickname = result.userInfo!.displayName;
                } else {
                  finalNickname = profileUser.nickname;
                }
                
                // 同步昵称到个人中心
                _dataService.updateUser(nickname: finalNickname);
                
                userInfo.addAll({
                  'nickname': finalNickname,
                  'appleId': email,
                  'joinDate': result.userInfo!.loginTime.toString().split(' ')[0],
                  'userId': result.userInfo!.userId,
                  'isVerified': result.userInfo!.isVerified,
                });
                
                if (kDebugMode) {
                  print('更新用户信息: nickname=$finalNickname, appleId=$email');
                }
              });
              
              _showSuccessMessage('登录成功，欢迎使用静心岛！');
            }
            break;
            
          case AppleSignInResult.cancelled:
            // 用户取消登录，不显示错误信息
            break;
            
          case AppleSignInResult.failed:
            _showErrorMessage(result.error ?? '登录失败，请重试');
            break;
            
          case AppleSignInResult.unavailable:
            _showErrorMessage('Apple登录不可用');
            break;
        }
      }
    } catch (e) {
      // 关闭加载对话框
      _safeCloseLoadingDialog();
      
      if (mounted) {
        _showErrorMessage('登录过程中发生错误: $e');
      }
    }
  }

  // 编辑昵称
  void _editNickname() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: userInfo['nickname']);
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text(
            '修改昵称',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: '请输入新昵称（最多8个字符）',
              hintStyle: TextStyle(color: AppColors.textHint),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.accent),
              ),
              helperText: '昵称长度限制为8个字符',
              helperStyle: TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
            maxLength: 8,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newNickname = controller.text.trim();
                if (newNickname.isEmpty) {
                  _showErrorMessage('昵称不能为空');
                  return;
                }
                if (newNickname.length > 8) {
                  _showErrorMessage('昵称长度不能超过8个字符');
                  return;
                }
                Navigator.pop(context);
                _showLoadingDialog('正在保存昵称...');
                
                try {
                  final success = await _authService.updateUserNickname(newNickname);
                  
                  // 关闭加载对话框
                  _safeCloseLoadingDialog();
                  
                  if (mounted) {
                    if (success) {
                      // 同步昵称到个人中心
                      _dataService.updateUser(nickname: newNickname);
                      
                      setState(() {
                        userInfo['nickname'] = newNickname;
                        if (_currentUser != null) {
                          // 更新当前用户信息
                          _currentUser = AppleUserInfo(
                            userId: _currentUser!.userId,
                            email: _currentUser!.email,
                            givenName: _currentUser!.givenName,
                            familyName: _currentUser!.familyName,
                            nickname: newNickname,
                            isVerified: _currentUser!.isVerified,
                            loginTime: _currentUser!.loginTime,
                          );
                        }
                      });
                      _showSuccessMessage('昵称修改成功');
                    } else {
                      _showErrorMessage('昵称修改失败，请重试');
                    }
                  }
                } catch (e) {
                  _safeCloseLoadingDialog();
                  if (mounted) {
                    _showErrorMessage('昵称修改失败: $e');
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              child: const Text('确定', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }



    // 获取显示的用户邮箱
  String _getDisplayAppleId() {
    if (!_isLoggedIn || _currentUser == null) {
      return '未登录Apple账户';
    }
    
    final email = _currentUser!.email;
    
    // 如果邮箱为空，生成隐私邮箱格式
    if (email.isEmpty) {
      return '***@privaterelay.appleid.com';
    }
    
    // 如果邮箱已经是隐私格式（包含***），处理后返回
    if (email.contains('***')) {
      // 如果是Apple隐私邮箱格式，去掉前面的数字部分
      if (email.contains('@privaterelay.appleid.com')) {
        return '***@privaterelay.appleid.com';
      }
      return email;
    }
    
    // 格式化普通邮箱，隐藏中间部分
    if (email.contains('@')) {
      final parts = email.split('@');
      final localPart = parts[0];
      final domain = parts[1];
      
      if (localPart.length > 6) {
        // 显示前3位和后2位，中间用*号替代
        final prefix = localPart.substring(0, 3);
        final suffix = localPart.substring(localPart.length - 2);
        return '$prefix***$suffix@$domain';
      } else if (localPart.length > 3) {
        // 显示前2位和后1位
        final prefix = localPart.substring(0, 2);
        final suffix = localPart.substring(localPart.length - 1);
        return '$prefix**$suffix@$domain';
      } else {
        // 太短的话显示第一位加*号
        final prefix = localPart.substring(0, 1);
        return '$prefix**@$domain';
      }
    }
    
    return email; // 如果不是邮箱格式，直接返回
  }
  
  // 获取账户类型描述
  String _getAccountTypeDescription() {
    if (!_isLoggedIn || _currentUser == null) {
      return '';
    }
    
    final email = _currentUser!.email;
    final displayEmail = _getDisplayAppleId();
    
    // 如果原始邮箱为空，或显示的邮箱是隐私格式
    if (email.isEmpty || displayEmail.contains('***') || displayEmail.contains('privaterelay.appleid.com')) {
      return '苹果隐私邮箱';
    }
    
    // 检查是否是真实邮箱
    if (email.contains('@') && !email.contains('***')) {
      return '真实邮箱账户';
    }
    
    return 'Apple账户';
  }


  // 去充值
  void _goToRecharge() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RechargeCenterScreen(),
      ),
    );
    
    // 充值返回后刷新金币数据
    if (result == true) {
      _refreshUserData();
    }
  }

  // 升级VIP
  void _upgradeToVip() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VipSubscriptionScreen(),
      ),
    );
    
    // VIP购买返回后刷新用户数据
    if (result == true) {
      _refreshUserData();
    }
  }

  // 刷新用户数据
  void _refreshUserData() {
    if (mounted) {
      final profileUser = _dataService.getCurrentUser();
      setState(() {
        // 更新金币数据
        userInfo['coins'] = profileUser.coins;
        userInfo['isVip'] = profileUser.isVip;
        userInfo['vipExpireDate'] = profileUser.vipExpireDate;
        
        // 同步昵称（如果个人中心有更新的话）
        if (_currentUser?.nickname == null || _currentUser!.nickname!.isEmpty) {
          userInfo['nickname'] = profileUser.nickname;
        }
      });
      
      if (kDebugMode) {
        print('账户管理页面: 用户数据已刷新 - 金币: ${profileUser.coins}, VIP: ${profileUser.isVip}');
      }
    }
  }



  // 退出登录
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          '退出登录',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '确定要退出当前账户吗？',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _showLoadingDialog('正在退出...');
              
              try {
                await _authService.signOut();
                
                // 关闭加载对话框
                _safeCloseLoadingDialog();
                
                if (mounted) {
                  setState(() {
                    _isLoggedIn = false;
                    _currentUser = null;
                    // 重置用户信息
                    userInfo = {
                      'nickname': '心灵旅者',
                      'appleId': 'user@privaterelay.appleid.com',
                      'joinDate': '2024-01-01',
                      'avatar': 'assets/images/avatars/user_1.png',
                      'isVip': false,
                      'vipExpireDate': null,
                      'coins': 1280,
                      'totalCoins': 5680,
                    };
                  });
                  _showSuccessMessage('已退出登录');
                }
              } catch (e) {
                _safeCloseLoadingDialog();
                if (mounted) {
                  _showErrorMessage('退出登录失败: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('确定', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 注销账户
  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          '注销账户',
          style: TextStyle(color: AppColors.error),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '注意：此操作不可恢复！',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '注销账户将会：\n• 永久删除您的所有数据\n• 清除所有个人信息\n• 无法恢复任何内容',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('确认注销', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 确认注销账户
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text(
            '最后确认',
            style: TextStyle(color: AppColors.error),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '请输入 "确认注销" 来确认此操作：',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: '请输入：确认注销',
                  hintStyle: TextStyle(color: AppColors.textHint),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim() == '确认注销') {
                  Navigator.pop(context);
                  _showLoadingDialog('正在注销账户...');
                  
                  try {
                    await _authService.deleteAccount();
                    
                    // 关闭加载对话框
                    _safeCloseLoadingDialog();
                    
                    if (mounted) {
                      setState(() {
                        _isLoggedIn = false;
                        _currentUser = null;
                        // 重置用户信息
                        userInfo = {
                          'nickname': '心灵旅者',
                          'appleId': 'user@privaterelay.appleid.com',
                          'joinDate': '2024-01-01',
                          'avatar': 'assets/images/avatars/user_1.png',
                          'isVip': false,
                          'vipExpireDate': null,
                          'coins': 1280,
                          'totalCoins': 5680,
                        };
                      });
                      _showSuccessMessage('账户已注销');
                    }
                  } catch (e) {
                    _safeCloseLoadingDialog();
                    if (mounted) {
                      _showErrorMessage('注销账户失败: $e');
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('输入不正确，请重新输入'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('确认注销', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // 显示服务条款
  void _showServiceTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          '用户协议',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const SizedBox(
          width: 300,
          height: 300,
          child: SingleChildScrollView(
            child: Text(
              '这里是用户协议的内容...\n\n1. 服务条款\n2. 用户权责\n3. 隐私保护\n4. 免责声明\n\n详细条款请查看完整版协议。',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('确定', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 显示隐私政策
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          '隐私政策',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const SizedBox(
          width: 300,
          height: 300,
          child: SingleChildScrollView(
            child: Text(
              '这里是隐私政策的内容...\n\n1. 信息收集\n2. 信息使用\n3. 信息保护\n4. 第三方服务\n\n我们承诺保护您的隐私安全。',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('确定', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 显示加载对话框
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: AppColors.cardBackground,
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.accent),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 安全关闭加载对话框
  void _safeCloseLoadingDialog() {
    try {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      // 忽略关闭对话框时的错误
      if (kDebugMode) {
        print('关闭加载对话框失败: $e');
      }
    }
  }

  // 显示成功消息
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 显示错误消息
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


}