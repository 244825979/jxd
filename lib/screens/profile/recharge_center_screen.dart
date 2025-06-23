import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';

class RechargeCenterScreen extends StatefulWidget {
  const RechargeCenterScreen({super.key});

  @override
  State<RechargeCenterScreen> createState() => _RechargeCenterScreenState();
}

class _RechargeCenterScreenState extends State<RechargeCenterScreen> {
  int currentCoins = 0; // 当前金币
  int selectedAmount = -1; // 选中的充值金额索引
  
  final List<Map<String, dynamic>> rechargeOptions = [
    {'amount': 10, 'bonus': 0, 'popular': false},
    {'amount': 30, 'bonus': 2, 'popular': false},
    {'amount': 68, 'bonus': 8, 'popular': true},
    {'amount': 128, 'bonus': 20, 'popular': false},
    {'amount': 268, 'bonus': 50, 'popular': false},
    {'amount': 588, 'bonus': 120, 'popular': false},
  ];

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
            const SizedBox(height: 32),
            
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: rechargeOptions.length,
      itemBuilder: (context, index) {
        final option = rechargeOptions[index];
        final isSelected = selectedAmount == index;
        final isPopular = option['popular'] == true;
        
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
                color: isSelected ? AppColors.accent : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                // 热门标签
                if (isPopular)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '热门',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                
                // 主要内容
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                            '${option['amount']}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (option['bonus'] > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '赠送¥${option['bonus']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRechargeButton() {
    final isEnabled = selectedAmount >= 0;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _handleRecharge : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.accent : AppColors.textHint,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          isEnabled 
            ? '充值 ¥${rechargeOptions[selectedAmount]['amount']}'
            : '请选择充值金额',
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
          '• 余额永久有效，无过期时间\n'
          '• 支持微信支付、支付宝等多种支付方式\n'
          '• 如有问题请联系客服',
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
    
    final option = rechargeOptions[selectedAmount];
    final amount = option['amount'];
    final bonus = option['bonus'] ?? 0;
    
    // 这里应该调用支付接口
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text(
          '确认充值',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '确认充值 ¥$amount${bonus > 0 ? '（赠送¥$bonus）' : ''}？',
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
              _processRecharge(amount, bonus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
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

  void _processRecharge(int amount, int bonus) {
    // 模拟充值成功
    setState(() {
      currentCoins += amount + bonus;
      selectedAmount = -1;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('充值成功！到账金币：${amount + bonus}个'),
        backgroundColor: AppColors.accent,
      ),
    );
  }
} 