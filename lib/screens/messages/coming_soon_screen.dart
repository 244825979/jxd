import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          '敬请期待',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 主标题区域
            CustomCard(
              child: Column(
                children: [
                  // 图标
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 60,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 标题
                  const Text(
                    '更多精彩功能即将上线',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  // 副标题
                  const Text(
                    '我们正在精心打造更多贴心功能\n让您的心灵之旅更加丰富多彩',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 即将推出的功能列表
            const Text(
              '即将推出',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // 功能卡片列表
            _buildFeatureCard(
              icon: Icons.book_outlined,
              title: '情绪日记',
              description: '记录每日心情变化，AI智能分析情绪趋势',
              color: Colors.blue.shade400,
            ),
            const SizedBox(height: 12),
            
            _buildFeatureCard(
              icon: Icons.self_improvement_outlined,
              title: '冥想指导',
              description: '专业冥想课程，帮助您找到内心的平静',
              color: Colors.green.shade400,
            ),
            const SizedBox(height: 12),
            
            _buildFeatureCard(
              icon: Icons.psychology_outlined,
              title: '心理测评',
              description: '科学心理测试，深入了解自己的内心世界',
              color: Colors.purple.shade400,
            ),
            const SizedBox(height: 12),
            
            _buildFeatureCard(
              icon: Icons.groups_outlined,
              title: '心理社群',
              description: '与志同道合的朋友分享心得，互相支持',
              color: Colors.orange.shade400,
            ),
            const SizedBox(height: 12),
            
            _buildFeatureCard(
              icon: Icons.timeline_outlined,
              title: '成长轨迹',
              description: '可视化展示您的心理健康成长历程',
              color: Colors.teal.shade400,
            ),
            
            const SizedBox(height: 32),
            
            // 底部提示
            CustomCard(
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_active_outlined,
                    size: 32,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '我们会在新功能上线时第一时间通知您',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '敬请期待',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return CustomCard(
      child: Row(
        children: [
          // 图标
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          
          // 状态标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '开发中',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 