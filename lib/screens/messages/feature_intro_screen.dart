import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';

class FeatureIntroScreen extends StatelessWidget {
  final String? feature;
  
  const FeatureIntroScreen({super.key, this.feature});

  @override
  Widget build(BuildContext context) {
    final featureData = _getFeatureData(feature);
    
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          featureData['title'],
          style: const TextStyle(
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 功能封面
          _buildFeatureHeader(featureData),
          const SizedBox(height: 20),
          
          // 功能特色
          _buildFeatureHighlights(featureData['highlights']),
          const SizedBox(height: 20),
          
          // 使用指南
          _buildUserGuide(featureData['guide']),
          const SizedBox(height: 20),
          
          // 体验按钮
          _buildActionButton(context, featureData),
        ],
      ),
    );
  }

  Map<String, dynamic> _getFeatureData(String? feature) {
    switch (feature) {
      case 'mood_diary':
        return {
          'title': '情绪日记',
          'subtitle': '记录心情，见证成长',
          'description': '全新的情绪日记功能，让您更好地了解和管理自己的情感世界。',
          'icon': '📝',
          'color': Colors.purple.shade400,
          'highlights': [
            {'icon': '🎤', 'title': '语音记录', 'desc': '支持语音输入，记录更自然'},
            {'icon': '🤖', 'title': 'AI智能分析', 'desc': '专业情绪分析，提供个性化建议'},
            {'icon': '📊', 'title': '趋势追踪', 'desc': '可视化图表，追踪情绪变化'},
            {'icon': '🔒', 'title': '隐私保护', 'desc': '端到端加密，保护您的隐私'},
          ],
          'guide': [
            '点击"+"按钮开始记录',
            '选择当前心情状态',
            '记录具体的情感体验',
            '查看AI分析和建议',
          ],
        };
      default:
        return {
          'title': '新功能介绍',
          'subtitle': '探索更多可能',
          'description': '我们持续为您带来更好的使用体验。',
          'icon': '✨',
          'color': Colors.blue.shade400,
          'highlights': [
            {'icon': '🎯', 'title': '精准功能', 'desc': '针对性解决您的需求'},
            {'icon': '🚀', 'title': '高效体验', 'desc': '简单操作，快速上手'},
            {'icon': '💡', 'title': '智能建议', 'desc': '基于数据的个性化推荐'},
            {'icon': '🔄', 'title': '持续更新', 'desc': '功能不断优化和完善'},
          ],
          'guide': [
            '探索新功能入口',
            '按照引导完成设置',
            '开始使用核心功能',
            '查看使用效果反馈',
          ],
        };
    }
  }

  Widget _buildFeatureHeader(Map<String, dynamic> data) {
    return CustomCard(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [data['color'], data['color'].withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              data['icon'],
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              data['subtitle'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data['description'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureHighlights(List<Map<String, String>> highlights) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '功能特色',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...highlights.map((highlight) => _buildHighlightItem(
              highlight['icon']!,
              highlight['title']!,
              highlight['desc']!,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightItem(String icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserGuide(List<String> steps) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '使用指南',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...steps.asMap().entries.map((entry) => _buildGuideStep(
              entry.key + 1,
              entry.value,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideStep(int step, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, Map<String, dynamic> data) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // 跳转到具体功能页面
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('正在为您打开${data['title']}...'),
                  backgroundColor: data['color'],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: data['color'],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '立即体验 ${data['title']}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 