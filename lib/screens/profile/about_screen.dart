import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '关于我们',
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
          children: [
            // 品牌标识区域
            _buildBrandSection(),
            const SizedBox(height: 24),

            // 理念愿景
            _buildVisionSection(),
            const SizedBox(height: 20),

            // 核心功能
            _buildFeaturesSection(),
            const SizedBox(height: 20),

            // 版本信息
            _buildVersionSection(),
            const SizedBox(height: 20),

            // 感谢用户
            _buildThankYouSection(),
          ],
        ),
      ),
    );
  }

  // 品牌标识区域
  Widget _buildBrandSection() {
    return CustomCard(
      child: Column(
        children: [
          // Logo区域 (可以替换为实际logo)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.spa,
              size: 50,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 16),

          // App名称
          const Text(
            '静心岛',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // 副标题
          Text(
            '心灵的港湾，情感的归宿',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),

          // 简介
          Text(
            '专注于心理健康和情感支持的移动应用\n为每一个需要温暖的心灵提供安全的栖息地',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 理念愿景区域
  Widget _buildVisionSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: Colors.red.shade400,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '我们的理念',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildBeliefItem(
            '💚 温暖陪伴',
            '每个人都值得被理解和关爱，我们致力于为用户提供温暖的情感陪伴',
          ),
          _buildBeliefItem(
            '🌱 健康成长',
            '通过科学的方法和工具，帮助用户建立积极的心理状态和生活习惯',
          ),
          _buildBeliefItem(
            '🤝 安全社区',
            '营造一个无判断、无偏见的安全空间，让每个人都能自由表达真实的自己',
          ),
          _buildBeliefItem(
            '🌟 持续创新',
            '不断探索和改进，为用户带来更好的心理健康服务体验',
          ),
        ],
      ),
    );
  }

  // 核心功能区域
  Widget _buildFeaturesSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '核心功能',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  Icons.self_improvement,
                  '冥想引导',
                  '专业音频',
                  const Color(0xFF27AE60),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureCard(
                  Icons.nightlight_round,
                  '白噪音',
                  '助眠放松',
                  const Color(0xFF3498DB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
                             Expanded(
                 child: _buildFeatureCard(
                   Icons.forum,
                   '情感广场',
                   '心情分享',
                   const Color(0xFFE67E22),
                 ),
               ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureCard(
                  Icons.psychology,
                  'AI陪伴',
                  '智能对话',
                  const Color(0xFF9B59B6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  // 版本信息区域
  Widget _buildVersionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade100,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.verified,
              size: 24,
              color: Colors.blue.shade600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '当前版本',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '最新版',
              style: TextStyle(
                fontSize: 11,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 感谢用户区域
  Widget _buildThankYouSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withOpacity(0.1),
            AppColors.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            size: 40,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 12),
          
          const Text(
            '感谢每一位用户',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            '是您的信任让静心岛不断成长\n是您的陪伴让我们充满动力\n愿静心岛成为您心灵路上的温暖伙伴',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '愿你被世界温柔以待 💚',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建理念项目
  Widget _buildBeliefItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.split(' ')[0],
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.substring(title.indexOf(' ') + 1),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建功能卡片
  Widget _buildFeatureCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
} 