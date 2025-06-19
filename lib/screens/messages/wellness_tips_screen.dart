import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';

class WellnessTipsScreen extends StatelessWidget {
  const WellnessTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          '健康贴士',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTipCard(
            '🧘‍♀️ 每日冥想',
            '研究表明，每天10分钟的冥想可以显著减少焦虑，提高注意力和情绪稳定性。',
            Colors.blue.shade100,
            Colors.blue.shade400,
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            '🌱 深呼吸练习',
            '使用4-7-8呼吸法：吸气4秒，屏息7秒，呼气8秒。这个简单的技巧能快速缓解压力。',
            Colors.green.shade100,
            Colors.green.shade400,
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            '☀️ 阳光与运动',
            '每天至少30分钟的自然光照射和适量运动，能有效改善心情，增强身心健康。',
            Colors.orange.shade100,
            Colors.orange.shade400,
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            '🛌 优质睡眠',
            '保持规律的睡眠时间，睡前1小时避免电子设备，创造安静舒适的睡眠环境。',
            Colors.purple.shade100,
            Colors.purple.shade400,
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            '🤝 社交连接',
            '保持与朋友家人的联系，分享感受和想法。良好的人际关系是心理健康的重要支柱。',
            Colors.pink.shade100,
            Colors.pink.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, String content, Color bgColor, Color accentColor) {
    return CustomCard(
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 