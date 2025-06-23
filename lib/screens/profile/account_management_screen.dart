import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  // 模拟用户数据
  Map<String, dynamic> userInfo = {
    'nickname': '心灵旅者',
    'phone': '138****8888',
    'email': 'user@example.com',
    'joinDate': '2024-01-01',
    'avatar': 'assets/images/avatars/user_1.png',
    'vipLevel': '普通用户',
    'balance': 58.88,
  };

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息卡片
            _buildUserInfoCard(),
            const SizedBox(height: 24),
            
            // 账户信息
            _buildSectionTitle('账户信息'),
            const SizedBox(height: 12),
            _buildAccountInfoSection(),
            const SizedBox(height: 24),
            
            // 安全设置
            _buildSectionTitle('安全设置'),
            const SizedBox(height: 12),
            _buildSecuritySection(),
            const SizedBox(height: 24),
            
            // 会员服务
            _buildSectionTitle('会员服务'),
            const SizedBox(height: 12),
            _buildMembershipSection(),
            const SizedBox(height: 24),
            
            // 其他操作
            _buildSectionTitle('其他操作'),
            const SizedBox(height: 12),
            _buildOtherActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return CustomCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // 头像
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.accent.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                size: 36,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 16),
            
            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userInfo['nickname'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userInfo['vipLevel'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '余额：¥${userInfo['balance']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 编辑按钮
            IconButton(
              onPressed: _editProfile,
              icon: const Icon(
                Icons.edit,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildAccountInfoSection() {
    return Column(
      children: [
        _buildInfoTile(
          icon: Icons.person_outline,
          title: '昵称',
          value: userInfo['nickname'],
          onTap: _editNickname,
        ),
        _buildInfoTile(
          icon: Icons.phone_outlined,
          title: '手机号',
          value: userInfo['phone'],
          onTap: _editPhone,
        ),
        _buildInfoTile(
          icon: Icons.email_outlined,
          title: '邮箱',
          value: userInfo['email'],
          onTap: _editEmail,
        ),
        _buildInfoTile(
          icon: Icons.calendar_today_outlined,
          title: '注册时间',
          value: userInfo['joinDate'],
          showArrow: false,
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      children: [
        _buildInfoTile(
          icon: Icons.lock_outline,
          title: '修改密码',
          value: '点击修改登录密码',
          onTap: _changePassword,
        ),
        _buildInfoTile(
          icon: Icons.fingerprint,
          title: '生物识别',
          value: '指纹/面容登录',
          onTap: _biometricSettings,
        ),
        _buildInfoTile(
          icon: Icons.security,
          title: '账户安全',
          value: '安全等级：高',
          onTap: _securitySettings,
        ),
        _buildInfoTile(
          icon: Icons.devices,
          title: '设备管理',
          value: '管理登录设备',
          onTap: _deviceManagement,
        ),
      ],
    );
  }

  Widget _buildMembershipSection() {
    return Column(
      children: [
        _buildInfoTile(
          icon: Icons.workspace_premium,
          title: 'VIP 会员',
          value: '升级至高级会员',
          onTap: _upgradeVip,
          valueColor: AppColors.accent,
        ),
        _buildInfoTile(
          icon: Icons.card_giftcard,
          title: '兑换码',
          value: '输入兑换码',
          onTap: _redeemCode,
        ),
        _buildInfoTile(
          icon: Icons.history,
          title: '消费记录',
          value: '查看充值消费记录',
          onTap: _viewTransactionHistory,
        ),
      ],
    );
  }

  Widget _buildOtherActionsSection() {
    return Column(
      children: [
        _buildInfoTile(
          icon: Icons.download,
          title: '数据导出',
          value: '导出个人数据',
          onTap: _exportData,
        ),
        _buildInfoTile(
          icon: Icons.logout,
          title: '退出登录',
          value: '退出当前账户',
          onTap: _logout,
          valueColor: const Color(0xFFFF6B6B),
        ),
        _buildInfoTile(
          icon: Icons.delete_forever,
          title: '注销账户',
          value: '永久删除账户',
          onTap: _deleteAccount,
          valueColor: const Color(0xFFFF6B6B),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
    Color? valueColor,
    bool showArrow = true,
  }) {
    return CustomCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      color: valueColor ?? AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow && onTap != null)
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textHint,
              ),
          ],
        ),
      ),
    );
  }

  // 各种操作方法
  void _editProfile() {
    _showComingSoonDialog('编辑资料');
  }

  void _editNickname() {
    _showEditDialog('昵称', userInfo['nickname'], (value) {
      setState(() {
        userInfo['nickname'] = value;
      });
    });
  }

  void _editPhone() {
    _showComingSoonDialog('修改手机号');
  }

  void _editEmail() {
    _showComingSoonDialog('修改邮箱');
  }

  void _changePassword() {
    _showComingSoonDialog('修改密码');
  }

  void _biometricSettings() {
    _showComingSoonDialog('生物识别设置');
  }

  void _securitySettings() {
    _showComingSoonDialog('安全设置');
  }

  void _deviceManagement() {
    _showComingSoonDialog('设备管理');
  }

  void _upgradeVip() {
    _showComingSoonDialog('升级VIP');
  }

  void _redeemCode() {
    _showComingSoonDialog('兑换码');
  }

  void _viewTransactionHistory() {
    _showComingSoonDialog('消费记录');
  }

  void _exportData() {
    _showComingSoonDialog('数据导出');
  }

  void _logout() {
    _showConfirmDialog(
      '退出登录',
      '确定要退出当前账户吗？',
      () {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已退出登录'),
            backgroundColor: AppColors.accent,
          ),
        );
      },
    );
  }

  void _deleteAccount() {
    _showConfirmDialog(
      '注销账户',
      '注销账户将永久删除所有数据，此操作不可恢复。确定要继续吗？',
      () {
        _showComingSoonDialog('账户注销');
      },
    );
  }

  void _showEditDialog(String title, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          '修改$title',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '请输入$title',
            hintStyle: const TextStyle(color: AppColors.textHint),
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.accent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onSave(controller.text);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title修改成功'),
                  backgroundColor: AppColors.accent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
            ),
            child: const Text(
              '保存',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          title,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          content,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
            ),
            child: const Text(
              '确认',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text(
          '功能开发中',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '$feature功能正在开发中，敬请期待！',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
            ),
            child: const Text(
              '知道了',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
} 