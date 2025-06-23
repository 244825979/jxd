import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../../services/apple_auth_service.dart';
import '../../services/data_service.dart';
import 'account_management_screen.dart';

class VipSubscriptionScreen extends StatefulWidget {
  const VipSubscriptionScreen({super.key});

  @override
  State<VipSubscriptionScreen> createState() => _VipSubscriptionScreenState();
}

class _VipSubscriptionScreenState extends State<VipSubscriptionScreen> {
  int selectedPlan = -1; // 选中的VIP套餐索引
  final AppleAuthService _authService = AppleAuthService();
  final DataService _dataService = DataService.getInstance();
  bool _isLoggedIn = false;
  
  final List<Map<String, dynamic>> vipPlans = [
    {
      'price': 68,
      'duration': '1个月',
      'product_id': 'lelelvip68',
      'name': '1个月会员服务',
      'popular': false,
    },
    {
      'price': 168,
      'duration': '3个月',
      'product_id': 'lelelvip168',
      'name': '3个月会员服务',
      'popular': true,
    },
    {
      'price': 399,
      'duration': '12个月',
      'product_id': 'lelelvip399',
      'name': '12个月会员服务',
      'popular': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // 检查登录状态
  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
      });
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
          'VIP会员',
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
            // VIP特权介绍卡片
            _buildVipBenefitsCard(),
            const SizedBox(height: 24),
            
            // 套餐选择标题
            const Text(
              '选择VIP套餐',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // VIP套餐选项
            _buildVipPlans(),
            const SizedBox(height: 20),
            
            // 开通按钮
            _buildSubscribeButton(),
            const SizedBox(height: 24),
            
            // 说明文字
            _buildNoticeText(),
          ],
        ),
      ),
    );
  }

  Widget _buildVipBenefitsCard() {
    return CustomCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.diamond,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'VIP专享特权',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
                         const SizedBox(height: 16),
             _buildBenefitItem('🤖', '与AI情感助手无限对话'),
             _buildBenefitItem('🎨', '专属VIP头像框和标识'),
             _buildBenefitItem('⚡', '优先体验最新功能'),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVipPlans() {
    return Column(
             children: List.generate(vipPlans.length, (index) {
         final plan = vipPlans[index];
         final isSelected = selectedPlan == index;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedPlan = index;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF00695C) : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
            ),
                         child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // 选择圆圈
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF00695C) : AppColors.divider,
                            width: 2,
                          ),
                          color: isSelected ? const Color(0xFF00695C) : Colors.transparent,
                        ),
                        child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                      ),
                      const SizedBox(width: 16),
                      
                      // 套餐信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan['name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? const Color(0xFF00695C) : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plan['duration'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                                             // 价格
                       Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           const Text(
                             '¥',
                             style: TextStyle(
                               fontSize: 16,
                               fontWeight: FontWeight.w600,
                               color: AppColors.textPrimary,
                             ),
                           ),
                           Text(
                             '${plan['price']}',
                             style: const TextStyle(
                               fontSize: 24,
                               fontWeight: FontWeight.w700,
                               color: AppColors.textPrimary,
                             ),
                           ),
                         ],
                       ),
                     ],
                   ),
                 ),
          ),
        );
      }),
    );
  }

  Widget _buildSubscribeButton() {
    final isEnabled = selectedPlan >= 0;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _handleSubscribe : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? const Color(0xFF00695C) : AppColors.textHint,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          !_isLoggedIn
            ? '请先进行登录'
            : (isEnabled 
                ? '开通VIP ¥${vipPlans[selectedPlan]['price']}'
                : '请选择VIP套餐'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VIP说明',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '• VIP会员服务立即生效\n'
          '• 自动续费可在设置中管理\n'
          '• 支持随时取消订阅',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  void _handleSubscribe() {
    if (selectedPlan < 0) return;
    
    // 检查登录状态
    if (!_isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }
    
    final plan = vipPlans[selectedPlan];
    final price = plan['price'];
    final duration = plan['duration'];
    
    // 这里应该调用VIP订阅接口
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text(
          '确认开通VIP',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '确认支付 ¥$price 开通 $duration VIP会员？',
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
              _processSubscription(price, duration);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00695C),
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

  // 显示登录提示对话框
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text(
          '需要登录',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'VIP订阅功能需要登录后才能使用，请先登录您的账户。',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _goToLogin();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00695C),
            ),
            child: const Text(
              '去登录',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 跳转到登录页面
  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountManagementScreen(),
      ),
    ).then((_) {
      // 从登录页面返回后重新检查登录状态
      _checkLoginStatus();
    });
  }

  void _processSubscription(int price, String duration) {
    // 模拟订阅成功
    _dataService.setVipStatus(true); // 设置VIP状态为true
    
    setState(() {
      selectedPlan = -1;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('VIP开通成功！有效期：$duration'),
        backgroundColor: const Color(0xFF00695C),
      ),
    );
  }
} 