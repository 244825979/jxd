import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class InAppPurchaseService {
  static InAppPurchaseService? _instance;
  static InAppPurchaseService get instance {
    _instance ??= InAppPurchaseService._internal();
    return _instance!;
  }
  
  InAppPurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // 充值商品ID
  static const Set<String> _rechargeProductIds = {
    'pack_coin_ios_12',
    'pack_coin_ios_38',
    'pack_coin_ios_68',
    'pack_coin_ios_98',
    'pack_coin_ios_198',
    'pack_coin_ios_298',
    'pack_coin_ios_598',
  };
  
  // VIP商品ID
  static const Set<String> _vipProductIds = {
    'pack_vip_68',
    'pack_vip_168',
    'pack_vip_399',
  };
  
  static const Set<String> _allProductIds = {
    ..._rechargeProductIds,
    ..._vipProductIds,
  };
  
  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;
  
  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;
  
  // 购买状态回调
  Function(PurchaseDetails)? onPurchaseSuccess;
  Function(PurchaseDetails)? onPurchaseFailed;
  Function(PurchaseDetails)? onPurchasePending;
  Function(PurchaseDetails)? onPurchaseCanceled;
  Function(String)? onError;

  /// 初始化内购服务
  Future<bool> initialize() async {
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      
      if (!_isAvailable) {
        onError?.call('内购服务不可用');
        return false;
      }

      // iOS特定配置
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
      }

      // 监听购买更新
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription.cancel(),
        onError: (error) => onError?.call('购买流程错误: $error'),
      );

      // 加载商品信息
      await _loadProducts();
      
      // 移除自动恢复购买，避免触发Apple ID验证弹窗
      // await _restorePurchases();
      
      return true;
    } catch (e) {
      onError?.call('初始化内购服务失败: $e');
      return false;
    }
  }
  
  /// 加载商品信息
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(_allProductIds);
      
      if (response.error != null) {
        onError?.call('加载商品信息失败: ${response.error!.message}');
        return;
      }
      
      _products = response.productDetails;
      
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('未找到的商品ID: ${response.notFoundIDs}');
      }
    } catch (e) {
      onError?.call('加载商品信息异常: $e');
    }
  }
  
  /// 购买商品
  Future<bool> purchaseProduct(String productId) async {
    try {
      if (!_isAvailable) {
        onError?.call('内购服务不可用');
        return false;
      }
      
      final ProductDetails? productDetails = _products
          .where((product) => product.id == productId)
          .firstOrNull;
      
      if (productDetails == null) {
        onError?.call('商品不存在: $productId');
        return false;
      }
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );
      
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      
      return success;
    } catch (e) {
      onError?.call('购买失败: $e');
      return false;
    }
  }
  
  /// 购买VIP订阅
  Future<bool> purchaseSubscription(String productId) async {
    try {
      if (!_isAvailable) {
        onError?.call('内购服务不可用');
        return false;
      }
      
      final ProductDetails? productDetails = _products
          .where((product) => product.id == productId)
          .firstOrNull;
      
      if (productDetails == null) {
        onError?.call('订阅商品不存在: $productId');
        return false;
      }
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );
      
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      
      return success;
    } catch (e) {
      onError?.call('订阅失败: $e');
      return false;
    }
  }
  
  /// 处理购买更新
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }
  
  /// 处理单个购买
  void _handlePurchase(PurchaseDetails purchaseDetails) {
    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        onPurchasePending?.call(purchaseDetails);
        break;
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        // 验证购买并完成交易
        _completePurchase(purchaseDetails);
        break;
      case PurchaseStatus.error:
        onPurchaseFailed?.call(purchaseDetails);
        _inAppPurchase.completePurchase(purchaseDetails);
        break;
      case PurchaseStatus.canceled:
        onPurchaseCanceled?.call(purchaseDetails);
        break;
    }
  }
  
  /// 完成购买
  Future<void> _completePurchase(PurchaseDetails purchaseDetails) async {
    try {
      // 这里可以添加服务器验证逻辑
      // await _verifyPurchaseOnServer(purchaseDetails);
      
      onPurchaseSuccess?.call(purchaseDetails);
      
      // 完成交易
      await _inAppPurchase.completePurchase(purchaseDetails);
    } catch (e) {
      onError?.call('完成购买失败: $e');
    }
  }
  
  /// 恢复购买
  Future<void> _restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('恢复购买失败: $e');
    }
  }
  
  /// 根据商品ID获取商品详情
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }
  
  /// 获取所有充值商品
  List<ProductDetails> getRechargeProducts() {
    return _products.where((product) => 
        _rechargeProductIds.contains(product.id)).toList();
  }
  
  /// 获取所有VIP商品
  List<ProductDetails> getVipProducts() {
    return _products.where((product) => 
        _vipProductIds.contains(product.id)).toList();
  }
  
  /// 销毁服务
  void dispose() {
    _subscription.cancel();
  }
}

/// iOS支付队列代理
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
} 