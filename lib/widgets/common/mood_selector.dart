import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';

class MoodSelector extends StatefulWidget {
  final int selectedMood;
  final ValueChanged<int> onMoodChanged;
  final ValueChanged<String>? onMoodContentChanged;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodChanged,
    this.onMoodContentChanged,
  });

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> {
  // 从心情最好(10)到最差(0)排序
  final List<Map<String, dynamic>> _moods = [
    {
      'value': 10, 
      'icon': AppImages.mood5, 
      'label': '很开心', 
      'emoji': '😊',
      'content': '今天心情特别好！阳光明媚，一切都很顺利，感觉生活充满了美好和希望。'
    },
    {
      'value': 8, 
      'icon': AppImages.mood4, 
      'label': '还不错', 
      'emoji': '🙂',
      'content': '今天状态不错，虽然没有特别兴奋，但内心很平静，对未来充满期待。'
    },
    {
      'value': 5, 
      'icon': AppImages.mood3, 
      'label': '一般', 
      'emoji': '😐',
      'content': '今天感觉平平常常，没有特别的起伏，就是普通的一天，希望明天会更好。'
    },
    {
      'value': 3, 
      'icon': AppImages.mood2, 
      'label': '有点难过', 
      'emoji': '😔',
      'content': '今天有些不太顺心，遇到了一些小困难，心情有点低落，需要调整一下。'
    },
    {
      'value': 0, 
      'icon': AppImages.mood1, 
      'label': '很难过', 
      'emoji': '😢',
      'content': '今天过得很艰难，感觉压力很大，心情很沉重，希望这种状态快点过去。'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _moods.map((mood) => _buildMoodItem(mood)).toList(),
      ),
    );
  }

  Widget _buildMoodItem(Map<String, dynamic> mood) {
    final isSelected = mood['value'] == widget.selectedMood;
    
    return GestureDetector(
      onTap: () {
        widget.onMoodChanged(mood['value']);
        if (widget.onMoodContentChanged != null) {
          widget.onMoodContentChanged!(mood['content']);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标容器
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.cardBackground.withOpacity(0.95)
                  : AppColors.cardBackground.withOpacity(0.6),
              shape: BoxShape.circle,
              border: isSelected 
                  ? Border.all(color: AppColors.accent.withOpacity(0.3), width: 2)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.cardShadow.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: _buildIcon(mood, isSelected),
            ),
          ),
          const SizedBox(height: 8),
          // 文字标签
          Text(
            mood['label'],
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(Map<String, dynamic> mood, bool isSelected) {
    // 优先使用图片图标，如果图片不存在则使用emoji
    return Image.asset(
      mood['icon'],
      width: isSelected ? 28 : 24,
      height: isSelected ? 28 : 24,
      errorBuilder: (context, error, stackTrace) {
        // 如果图片加载失败，使用emoji作为备用
        return Text(
          mood['emoji'],
          style: TextStyle(
            fontSize: isSelected ? 24 : 20,
          ),
        );
      },
    );
  }
} 