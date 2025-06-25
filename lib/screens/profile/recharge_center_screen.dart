import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../../services/apple_auth_service.dart';
import '../../services/data_service.dart';
import '../../services/in_app_purchase_service.dart';
import 'account_management_screen.dart';

class RechargeCenterScreen extends StatefulWidget {
  const RechargeCenterScreen({super.key});

  @override
  State<RechargeCenterScreen> createState() => _RechargeCenterScreenState();
}

class _RechargeCenterScreenState extends State<RechargeCenterScreen> {
  int currentCoins = 0; // 当前金币
  int selectedAmount = -1; // 选中的充值金额索引
  final AppleAuthService _authService = AppleAuthService();
  final DataService _dataService = DataService.getInstance();
  final InAppPurchaseService _iapService = InAppPurchaseService.instance;
  bool _isLoggedIn = false;
  bool _isPurchasing = false;
  
  final List<Map<String, dynamic>> rechargeOptions = [
    {'price': 6, 'coins': 510, 'product_id': 'pack_coin_ios_6', 'name': '6元金币礼包', 'popular': false},
    {'price': 8, 'coins': 680, 'product_id': 'pack_coin_ios_8', 'name': '8元金币礼包', 'popular': false},
    {'price': 12, 'coins': 840, 'product_id': 'pack_coin_ios_12', 'name': '12元金币礼包', 'popular': false},
    {'price': 38, 'coins': 2660, 'product_id': 'pack_coin_ios_38', 'name': '38元金币礼包', 'popular': false},
    {'price': 68, 'coins': 4760, 'product_id': 'pack_coin_ios_68', 'name': '68元金币礼包', 'popular': true},
    {'price': 98, 'coins': 6860, 'product_id': 'pack_coin_ios_98', 'name': '98元金币礼包', 'popular': false},
    {'price': 198, 'coins': 13860, 'product_id': 'pack_coin_ios_198', 'name': '198元金币礼包', 'popular': false},
    {'price': 298, 'coins': 20860, 'product_id': 'pack_coin_ios_298', 'name': '298元金币礼包', 'popular': false},
    {'price': 598, 'coins': 41860, 'product_id': 'pack_coin_ios_598', 'name': '598元金币礼包', 'popular': false},
  ];

  @override
  void initState() {
    super.initState();
    _setupPurchaseCallbacks();
    // 检查登录状态
    _checkLoginStatus();
    _updateCurrentCoins();
    // 检查内购服务状态
    _checkInAppPurchaseService();
  }

  // 检查内购服务状态
  void _checkInAppPurchaseService() async {
    try {
      if (!_iapService.isAvailable) {
        debugPrint('⚠️ 内购服务不可用，尝试重新初始化...');
        final success = await _iapService.initialize();
        debugPrint('内购服务重新初始化${success ? "成功" : "失败"}');
        
        if (mounted) {
          setState(() {});
        }
      } else {
        debugPrint('✅ 内购服务可用');
        debugPrint('📦 已加载${_iapService.products.length}个商品');
        for (final product in _iapService.products) {
          debugPrint('商品: ${product.id} - ${product.title} - ${product.price}');
        }
      }
    } catch (e) {
      debugPrint('❌ 检查内购服务状态失败: $e');
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
        // 更新金币显示
        _updateCurrentCoins();
      }
    } catch (e) {
      debugPrint('检查登录状态失败: $e');
      // 出错时使用DataService的状态
      _isLoggedIn = _dataService.isLoggedIn();
      if (mounted) {
        setState(() {});
        _updateCurrentCoins();
      }
    }
  }



  // 更新当前金币数
  void _updateCurrentCoins() {
    final user = _dataService.getCurrentUser();
    if (mounted) {
      setState(() {
        currentCoins = user.coins;
      });
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

  // 购买商品
  Future<void> _purchaseProduct(String productId) async {
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
      final success = await _iapService.purchaseProduct(productId);
      if (!success) {
        setState(() {
          _isPurchasing = false;
        });
        _showErrorDialog('启动购买失败，请重试');
      }
      // 购买结果会在回调中处理，这里不需要手动设置_isPurchasing = false
    } catch (e) {
      setState(() {
        _isPurchasing = false;
      });
      _showErrorDialog('购买出现异常: $e');
    }
  }

  // 购买成功回调
  void _onPurchaseSuccess(PurchaseDetails purchaseDetails) {
    if (mounted) {
      setState(() {
        _isPurchasing = false;
      });

      // 根据购买的商品ID更新金币
      final productInfo = rechargeOptions.firstWhere(
        (option) => option['product_id'] == purchaseDetails.productID,
        orElse: () => {},
      );

      if (productInfo.isNotEmpty) {
        final coins = productInfo['coins'] as int;
        _dataService.addCoins(coins);
        _updateCurrentCoins();
        
        _showSuccessDialog('充值成功！获得 $coins 金币');
        
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
      _showErrorDialog('购买失败: ${purchaseDetails.error?.message ?? "未知错误"}');
    }
  }

  // 购买等待回调
  void _onPurchasePending(PurchaseDetails purchaseDetails) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正在处理支付，请稍候...'),
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
          content: Text('支付已取消'),
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
          content: const Text('请先登录后再进行充值'),
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
          title: const Text('充值失败'),
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
          '充值中心',
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
            // 余额卡片
            _buildBalanceCard(),
            const SizedBox(height: 24),
            
            // 充值选项标题
            const Text(
              '选择充值金额',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // 充值选项网格
            _buildRechargeOptions(),
            const SizedBox(height: 20),
            
            // 充值按钮
            _buildRechargeButton(),
            const SizedBox(height: 24),
            
            // 说明文字
            _buildNoticeText(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return CustomCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accent, Color(0xFF4FC3F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '当前金币',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  currentCoins.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '个',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '每次与情感助手对话消耗1个金币',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRechargeOptions() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: rechargeOptions.length,
      itemBuilder: (context, index) {
        final option = rechargeOptions[index];
        final isSelected = selectedAmount == index;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedAmount = index;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF00695C) : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 价格显示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        '${option['price']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 金币数量显示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: isSelected ? 16 : 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${option['coins']}个',
                        style: TextStyle(
                          fontSize: isSelected ? 14 : 13,
                          color: isSelected ? const Color(0xFF00695C) : AppColors.accent,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRechargeButton() {
    final isEnabled = selectedAmount >= 0 && !_isPurchasing;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _handleRecharge : null,
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
                : (selectedAmount >= 0 
                    ? '充值 ¥${rechargeOptions[selectedAmount]['price']}'
                    : '请选择充值金额'),
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
          '充值说明',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '• 充值金额将实时到账\n'
          '• 余额永久有效，无过期时间',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  void _handleRecharge() {
    if (selectedAmount < 0) return;
    
    // 检查登录状态
    if (!_isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }
    
    final option = rechargeOptions[selectedAmount];
    final productId = option['product_id'];
    
    // 直接调用购买方法
    _purchaseProduct(productId);
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
          '充值功能需要登录后才能使用，请先登录您的账户。',
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

  @override
  void dispose() {
    super.dispose();
  }
} 