import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../../services/apple_auth_service.dart';
import '../../services/in_app_purchase_service.dart';
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
  final InAppPurchaseService _inAppPurchaseService = InAppPurchaseService();
  final DataService _dataService = DataService.getInstance();
  bool _isLoggedIn = false;
  bool _isPurchasing = false;
  List<ProductDetails> _vipProducts = [];
  
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
    _loadVipProducts();
    
    // 设置购买成功回调
    _inAppPurchaseService.setPurchaseSuccessCallback(() {
      _onVipPurchaseSuccess();
    });
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

  // 加载VIP商品
  Future<void> _loadVipProducts() async {
    try {
      if (!_inAppPurchaseService.isAvailable) {
        print('VIP页面: 内购服务不可用，正在初始化...');
        final initialized = await _inAppPurchaseService.initialize();
        if (!initialized) {
          print('VIP页面: 内购服务初始化失败');
          return;
        }
      }

      final products = _inAppPurchaseService.getVipProducts();
      print('VIP页面: 加载到 ${products.length} 个VIP商品');
      
      for (final product in products) {
        print('  - ${product.id}: ${product.title} - ${product.price}');
      }
      
      if (mounted) {
        setState(() {
          _vipProducts = products;
        });
      }
    } catch (e) {
      print('VIP页面: 加载VIP商品失败: $e');
    }
  }

  // VIP购买成功处理
  void _onVipPurchaseSuccess() {
    if (mounted) {
      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('VIP开通成功！享受专属特权'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // 延迟一段时间后返回到账户管理页面，并传递成功标识
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context, true); // 返回true表示VIP开通成功
        }
      });
    }
  }

  // 购买VIP
  Future<void> _purchaseVip(String productId) async {
    if (!_isLoggedIn) {
      _showLoginDialog();
      return;
    }

    if (_isPurchasing) {
      return;
    }

    // 检查内购服务是否可用
    if (!_inAppPurchaseService.isAvailable) {
      _showErrorDialog('内购服务不可用，请检查网络连接后重试');
      return;
    }

    // 获取商品详情
    final productDetails = _inAppPurchaseService.getProductDetails(productId);
    if (productDetails == null) {
      // 先尝试重新加载商品信息
      await _loadVipProducts();
      final retryProductDetails = _inAppPurchaseService.getProductDetails(productId);
      if (retryProductDetails == null) {
        _showErrorDialog('商品信息获取失败(ID: $productId)，请检查网络连接后重试');
        return;
      }
      // 使用重试后的商品详情
      _proceedWithPurchase(retryProductDetails);
      return;
    }

    _proceedWithPurchase(productDetails);
  }

  // 执行购买流程
  Future<void> _proceedWithPurchase(ProductDetails productDetails) async {
    setState(() {
      _isPurchasing = true;
    });

    try {
      final success = await _inAppPurchaseService.buyProduct(productDetails);
      
      if (success) {
        _showSuccessDialog('VIP开通请求已发送，请完成支付');
        // 等待一段时间后刷新VIP状态（实际应用中通过购买回调来刷新）
        Future.delayed(const Duration(seconds: 2), () {
          // 这里可以刷新用户VIP状态
        });
      } else {
        _showErrorDialog('VIP开通失败，请重试');
      }
    } catch (e) {
      _showErrorDialog('VIP开通出错：$e');
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  // 显示登录对话框
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('需要登录'),
          content: const Text('请先登录后再开通VIP'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountManagementScreen(),
                  ),
                );
              },
              child: const Text('去登录'),
            ),
          ],
        );
      },
    );
  }

  // 显示成功对话框
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('VIP开通成功'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 显示错误对话框
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('VIP开通失败'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
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
            const SizedBox(height: 16),
            
            // 调试信息（仅在调试模式下显示）
            if (kDebugMode) _buildDebugInfo(),
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
    final isEnabled = selectedPlan >= 0 && !_isPurchasing;
    
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
        child: _isPurchasing
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '正在处理...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : Text(
              !_isLoggedIn
                ? '请先进行登录'
                : (selectedPlan >= 0 
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
          '• 到期自动取消',
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
    final productId = plan['product_id'];
    
    // 直接调用购买方法
    _purchaseVip(productId);
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
    }    );
  }

  // 调试信息组件
  Widget _buildDebugInfo() {
    return CustomCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '调试信息',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '内购服务状态: ${_inAppPurchaseService.isAvailable ? "可用" : "不可用"}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '已加载商品数: ${_vipProducts.length}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (_vipProducts.isNotEmpty)
              ...(_vipProducts.map((product) => Text(
                '  - ${product.id}: ${product.title}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ))),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await _loadVipProducts();
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                '重新加载商品',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 清理购买成功回调
    _inAppPurchaseService.setPurchaseSuccessCallback(null);
    super.dispose();
  }
}  