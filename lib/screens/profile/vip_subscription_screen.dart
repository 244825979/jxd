import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../../services/apple_auth_service.dart';
import '../../services/data_service.dart';
import '../../services/in_app_purchase_service.dart';
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
  final InAppPurchaseService _iapService = InAppPurchaseService.instance;
  bool _isLoggedIn = false;
  bool _isPurchasing = false;
  
  final List<Map<String, dynamic>> vipPlans = [
    {
      'price': 38,
      'duration': '1个月',
      'product_id': 'pack_vip_38',
      'name': '1个月会员服务 尝鲜',
      'popular': false,
    },
    {
      'price': 68,
      'duration': '1个月',
      'product_id': 'pack_vip_68',
      'name': '1个月会员服务',
      'popular': false,
    },
    {
      'price': 168,
      'duration': '3个月',
      'product_id': 'pack_vip_168',
      'name': '3个月会员服务',
      'popular': true,
    },
    {
      'price': 399,
      'duration': '12个月',
      'product_id': 'pack_vip_399',
      'name': '12个月会员服务',
      'popular': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupPurchaseCallbacks();
    // 检查登录状态
    _checkLoginStatus();
    // 检查内购服务状态
    _checkInAppPurchaseService();
  }

  // 检查内购服务状态
  void _checkInAppPurchaseService() async {
    try {
      if (!_iapService.isAvailable) {
        debugPrint('⚠️ VIP页面：内购服务不可用，尝试重新初始化...');
        final success = await _iapService.initialize();
        debugPrint('VIP页面：内购服务重新初始化${success ? "成功" : "失败"}');
        
        if (mounted) {
          setState(() {});
        }
      } else {
        debugPrint('✅ VIP页面：内购服务可用');
        debugPrint('📦 VIP页面：已加载${_iapService.products.length}个商品');
        for (final product in _iapService.products) {
          debugPrint('VIP商品: ${product.id} - ${product.title} - ${product.price}');
        }
      }
    } catch (e) {
      debugPrint('❌ VIP页面：检查内购服务状态失败: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 页面重新进入时检查登录状态
    _checkLoginStatus();
  }

  // 检查登录状态 - 异步检查Apple登录状态
  void _checkLoginStatus() async {
    try {
      final isAppleLoggedIn = await _authService.isLoggedIn();
      final isDataServiceLoggedIn = _dataService.isLoggedIn();
      
      _isLoggedIn = isAppleLoggedIn && isDataServiceLoggedIn;
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('检查登录状态失败: $e');
      // 出错时使用DataService的状态
      _isLoggedIn = _dataService.isLoggedIn();
      if (mounted) {
        setState(() {});
      }
    }
  }





  // 设置购买回调
  void _setupPurchaseCallbacks() {
    _iapService.onPurchaseSuccess = _onPurchaseSuccess;
    _iapService.onPurchaseFailed = _onPurchaseFailed;
    _iapService.onPurchasePending = _onPurchasePending;
    _iapService.onPurchaseCanceled = _onPurchaseCanceled;
    _iapService.onError = _onPurchaseError;
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

    if (!_iapService.isAvailable) {
      _showErrorDialog('内购服务不可用，请稍后重试');
      return;
    }

    setState(() {
      _isPurchasing = true;
    });

    try {
      final success = await _iapService.purchaseSubscription(productId);
      if (!success) {
        setState(() {
          _isPurchasing = false;
        });
        _showErrorDialog('启动VIP购买失败，请重试');
      }
      // 购买结果会在回调中处理，这里不需要手动设置_isPurchasing = false
    } catch (e) {
      setState(() {
        _isPurchasing = false;
      });
      _showErrorDialog('VIP购买出现异常: $e');
    }
  }

  // 购买成功回调
  void _onPurchaseSuccess(PurchaseDetails purchaseDetails) {
    if (mounted) {
      setState(() {
        _isPurchasing = false;
      });

      // 根据购买的商品ID更新VIP状态
      final productInfo = vipPlans.firstWhere(
        (plan) => plan['product_id'] == purchaseDetails.productID,
        orElse: () => {},
      );

      if (productInfo.isNotEmpty) {
        final duration = productInfo['duration'] as String;
        _dataService.activateVip();
        
        _showSuccessDialog('VIP开通成功！已开通$duration会员');
        
        // 延迟返回上一页面
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      }
    }
  }

  // 购买失败回调
  void _onPurchaseFailed(PurchaseDetails purchaseDetails) {
    if (mounted) {
      setState(() {
        _isPurchasing = false;
      });
      _showErrorDialog('VIP购买失败: ${purchaseDetails.error?.message ?? "未知错误"}');
    }
  }

  // 购买等待回调
  void _onPurchasePending(PurchaseDetails purchaseDetails) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正在处理VIP订阅支付，请稍候...'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // 购买取消回调
  void _onPurchaseCanceled(PurchaseDetails purchaseDetails) {
    if (mounted) {
      setState(() {
        _isPurchasing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('VIP订阅支付已取消'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // 购买错误回调
  void _onPurchaseError(String error) {
    if (mounted) {
      setState(() {
        _isPurchasing = false;
      });
      _showErrorDialog(error);
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
                ).then((_) {
                  // 从登录页面返回后重新检查状态
                  _checkLoginStatus();
                });
              },
              child: const Text('去登录'),
            ),
          ],
        );
      },
    );
  }

  // 显示信息对话框
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
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



  @override
  void dispose() {
    super.dispose();
  }
}  