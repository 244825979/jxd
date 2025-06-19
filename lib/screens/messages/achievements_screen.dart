import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../../services/data_service.dart';
import '../../models/achievement.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final DataService _dataService = DataService.getInstance();
  List<Achievement> _achievements = [];
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _achievements = _dataService.getAchievements();
      _stats = _dataService.getAchievementStats();
    });
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          '成就徽章',
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
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 统计概览
            _buildStatsOverview(),
            const SizedBox(height: 20),
            
            // 成就列表
            ..._achievements.map((achievement) => Column(
              children: [
                _buildAchievementCard(achievement),
                const SizedBox(height: 12),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '成就概览',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '总计',
                    '${_stats['total'] ?? 0}',
                    Colors.blue.shade400,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '已获得',
                    '${_stats['unlocked'] ?? 0}',
                    Colors.green.shade400,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '即将完成',
                    '${_stats['nearComplete'] ?? 0}',
                    Colors.orange.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final color = _parseColor(achievement.colorHex);
    final progress = achievement.progress.clamp(0.0, 1.0);
    
    return CustomCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: achievement.isUnlocked 
              ? color.withOpacity(0.1) 
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: achievement.isUnlocked 
                ? color.withOpacity(0.3) 
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: achievement.isUnlocked 
                        ? color.withOpacity(0.2) 
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: achievement.isUnlocked
                      ? Icon(Icons.emoji_events, color: color, size: 28)
                      : Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: achievement.isUnlocked ? color : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: achievement.isUnlocked 
                              ? AppColors.textSecondary 
                              : Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        achievement.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: achievement.isUnlocked 
                              ? AppColors.textPrimary 
                              : Colors.grey.shade500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (achievement.isUnlocked)
                  Icon(
                    Icons.check_circle,
                    color: color,
                    size: 24,
                  ),
              ],
            ),
            
            // 进度条（仅对未解锁的成就显示）
            if (!achievement.isUnlocked) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '进度',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${achievement.currentValue}/${achievement.requiredValue} ${achievement.unit}',
                        style: TextStyle(
                          fontSize: 12,
                          color: achievement.isNearComplete ? color : Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      achievement.isNearComplete ? color : Colors.grey.shade400,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ],
            
            // 解锁时间（仅对已解锁的成就显示）
            if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '获得于 ${_formatDate(achievement.unlockedAt!)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }


} 