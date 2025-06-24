import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'data_service.dart';

/// 苹果内购服务类
class InAppPurchaseService {
  static final InAppPurchaseService _instance = InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final DataService _dataService = DataService.getInstance();
  
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];
  
  // 购买成功回调
  VoidCallback? _onPurchaseSuccess;

  // 充值商品ID列表
  static const List<String> _rechargeProductIds = [
    'lelele_12',
    'lelele_38', 
    'lelele_68',
    'lelele_98',
    'lelele_198',
    'lelele_298',
    'lelele_598',
  ];

  // VIP订阅商品ID列表
  static const List<String> _vipProductIds = [
    'lelelvip68',
    'lelelvip168',
    'lelelvip399',
  ];

  // 所有商品ID
  static const List<String> _allProductIds = [
    ..._rechargeProductIds,
    ..._vipProductIds,
  ];

  // 商品价格对应的金币数
  static const Map<String, int> _productCoins = {
    'lelele_12': 840,
    'lelele_38': 2660,
    'lelele_68': 4760,
    'lelele_98': 6860,
    'lelele_198': 13860,
    'lelele_298': 20860,
    'lelele_598': 41860,
  };

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  List<PurchaseDetails> get purchases => _purchases;
  
  /// 设置购买成功回调
  void setPurchaseSuccessCallback(VoidCallback? callback) {
    _onPurchaseSuccess = callback;
  }

  /// 初始化内购服务
  Future<bool> initialize() async {
    try {
      if (kDebugMode) {
        print('InAppPurchase: 开始初始化内购服务...');
      }

      _isAvailable = await _inAppPurchase.isAvailable();
      
      if (!_isAvailable) {
        if (kDebugMode) {
          print('InAppPurchase: 内购服务不可用');
        }
        return false;
      }

      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
      }

      // 监听购买更新
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () {
          if (kDebugMode) {
            print('InAppPurchase: 购买流监听结束');
          }
        },
        onError: (error) {
          if (kDebugMode) {
            print('InAppPurchase: 购买流错误: $error');
          }
        },
      );

      // 查询商品信息
      await _queryProducts();

      // 恢复购买
      await _restorePurchases();

      if (kDebugMode) {
        print('InAppPurchase: 内购服务初始化成功');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('InAppPurchase: 初始化失败: $e');
      }
      return false;
    }
  }

  /// 查询商品信息
  Future<void> _queryProducts() async {
    try {
      if (kDebugMode) {
        print('InAppPurchase: 开始查询商品信息...');
      }

      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_allProductIds.toSet());
      
      if (response.notFoundIDs.isNotEmpty) {
        if (kDebugMode) {
          print('InAppPurchase: 未找到的商品ID: ${response.notFoundIDs}');
        }
      }

      _products = response.productDetails;
      
      if (kDebugMode) {
        print('InAppPurchase: 成功查询到 ${_products.length} 个商品');
        for (final product in _products) {
          print('  - ${product.id}: ${product.title} - ${product.price}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('InAppPurchase: 查询商品失败: $e');
      }
    }
  }

  /// 恢复购买
  Future<void> _restorePurchases() async {
    try {
      if (kDebugMode) {
        print('InAppPurchase: 开始恢复购买...');
      }
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      if (kDebugMode) {
        print('InAppPurchase: 恢复购买失败: $e');
      }
    }
  }

  /// 处理购买更新
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    if (kDebugMode) {
      print('InAppPurchase: 收到购买更新，共 ${purchaseDetailsList.length} 个');
    }

    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (kDebugMode) {
        print('InAppPurchase: 处理购买 ${purchaseDetails.productID}, 状态: ${purchaseDetails.status}');
      }

      if (purchaseDetails.status == PurchaseStatus.pending) {
        _handlePendingPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _handleFailedPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        _handleSuccessfulPurchase(purchaseDetails);
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// 处理待处理的购买
  void _handlePendingPurchase(PurchaseDetails purchaseDetails) {
    if (kDebugMode) {
      print('InAppPurchase: 购买待处理: ${purchaseDetails.productID}');
    }
    // 可以在这里显示加载指示器
  }

  /// 处理失败的购买
  void _handleFailedPurchase(PurchaseDetails purchaseDetails) {
    if (kDebugMode) {
      print('InAppPurchase: 购买失败: ${purchaseDetails.productID}, 错误: ${purchaseDetails.error}');
    }
    // 可以在这里显示错误消息
  }

  /// 处理成功的购买
  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    if (kDebugMode) {
      print('InAppPurchase: 购买成功: ${purchaseDetails.productID}');
    }

    try {
      // 验证购买
      if (await _verifyPurchase(purchaseDetails)) {
        // 发放商品
        await _deliverProduct(purchaseDetails);
        if (kDebugMode) {
          print('InAppPurchase: 商品发放完成: ${purchaseDetails.productID}');
        }
        
        // 调用购买成功回调
        if (_onPurchaseSuccess != null) {
          _onPurchaseSuccess!();
        }
      } else {
        if (kDebugMode) {
          print('InAppPurchase: 购买验证失败: ${purchaseDetails.productID}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('InAppPurchase: 处理成功购买时出错: $e');
      }
    }
  }

  /// 验证购买（简化版本，实际应用中应该在服务器端验证）
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // 在生产环境中，应该将收据发送到您的服务器进行验证
    // 这里只是简单返回 true 作为示例
    if (kDebugMode) {
      print('InAppPurchase: 验证购买: ${purchaseDetails.productID}');
    }
    return true;
  }

  /// 发放商品
  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;
    
    if (_rechargeProductIds.contains(productId)) {
      // 充值商品 - 增加金币
      final coins = _productCoins[productId] ?? 0;
      if (coins > 0) {
        final currentUser = _dataService.getCurrentUser();
        final newCoins = currentUser.coins + coins;
        
        // 更新用户金币
        _dataService.updateUserCoins(newCoins);
        
        if (kDebugMode) {
          print('InAppPurchase: 充值成功，增加 $coins 金币');
        }
      }
    } else if (_vipProductIds.contains(productId)) {
      // VIP订阅 - 开通VIP
      // 计算VIP到期时间
      DateTime vipExpireDate = DateTime.now();
      switch (productId) {
        case 'lelelvip68':
          vipExpireDate = vipExpireDate.add(const Duration(days: 30));
          break;
        case 'lelelvip168':
          vipExpireDate = vipExpireDate.add(const Duration(days: 90));
          break;
        case 'lelelvip399':
          vipExpireDate = vipExpireDate.add(const Duration(days: 365));
          break;
      }
      
      // 更新用户VIP状态
      _dataService.updateUser(isVip: true);
      _dataService.updateUserVipExpireDate(vipExpireDate);
      
      if (kDebugMode) {
        print('InAppPurchase: VIP开通成功，到期时间: $vipExpireDate');
      }
    }
  }

  /// 购买商品
  Future<bool> buyProduct(ProductDetails productDetails) async {
    try {
      if (!_isAvailable) {
        if (kDebugMode) {
          print('InAppPurchase: 内购服务不可用，无法购买');
        }
        return false;
      }

      if (kDebugMode) {
        print('InAppPurchase: 开始购买商品: ${productDetails.id}');
      }

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
      
      if (_vipProductIds.contains(productDetails.id)) {
        // VIP订阅
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // 充值商品（消耗型商品）
        await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('InAppPurchase: 购买失败: $e');
      }
      return false;
    }
  }

  /// 根据商品ID获取商品详情
  ProductDetails? getProductDetails(String productId) {
    try {
      if (kDebugMode) {
        print('InAppPurchase: 查找商品 $productId，当前已加载 ${_products.length} 个商品');
        print('InAppPurchase: 已加载的商品ID: ${_products.map((p) => p.id).toList()}');
      }
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      if (kDebugMode) {
        print('InAppPurchase: 未找到商品: $productId');
        print('InAppPurchase: 可用商品列表: ${_products.map((p) => p.id).toList()}');
      }
      return null;
    }
  }

  /// 获取充值商品列表
  List<ProductDetails> getRechargeProducts() {
    return _products.where((product) => _rechargeProductIds.contains(product.id)).toList();
  }

  /// 获取VIP商品列表
  List<ProductDetails> getVipProducts() {
    return _products.where((product) => _vipProductIds.contains(product.id)).toList();
  }

  /// 销毁服务
  void dispose() {
    _subscription.cancel();
  }
}

/// iOS支付队列委托
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
} 