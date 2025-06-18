import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../../models/user.dart';

class DaysDetailScreen extends StatelessWidget {
  final User user;

  const DaysDetailScreen({super.key, required this.user});

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
          '我的成长历程',
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
            // 主要统计卡片
            _buildMainStatsCard(),
            const SizedBox(height: 20),

            // 成长里程碑
            _buildMilestonesCard(),
            const SizedBox(height: 20),

            // 使用习惯
            _buildUsageHabitsCard(),
            const SizedBox(height: 20),

            // 激励文案
            _buildMotivationCard(),
          ],
        ),
      ),
    );
  }

  // 主要统计卡片
  Widget _buildMainStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withOpacity(0.15),
            AppColors.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 天数显示
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accent.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '${user.daysSinceJoin}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            '在静心岛的日子',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            _getJoinDateText(),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // 快速统计
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStat('💚', user.likeCount, '获赞'),
              _buildQuickStat('⭐', user.collectionCount, '收藏'),
              _buildQuickStat('📝', user.postCount, '发布'),
            ],
          ),
        ],
      ),
    );
  }

  // 成长里程碑卡片
  Widget _buildMilestonesCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amber.shade600,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '成长里程碑',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildMilestoneItem(
            '🎉',
            '加入静心岛',
            _getJoinDateText(),
            true,
          ),
          _buildMilestoneItem(
            '👋',
            '完成首次心情记录',
            user.daysSinceJoin >= 1 ? '已完成' : '待解锁',
            user.daysSinceJoin >= 1,
          ),
          _buildMilestoneItem(
            '🧘',
            '体验第一次冥想',
            user.daysSinceJoin >= 3 ? '已完成' : '待解锁',
            user.daysSinceJoin >= 3,
          ),
          _buildMilestoneItem(
            '📝',
            '发布首条动态',
            user.postCount > 0 ? '已完成' : '待解锁',
            user.postCount > 0,
          ),
          _buildMilestoneItem(
            '⭐',
            '获得首个点赞',
            user.likeCount > 0 ? '已完成' : '待解锁',
            user.likeCount > 0,
          ),
          _buildMilestoneItem(
            '🏆',
            '连续使用7天',
            user.daysSinceJoin >= 7 ? '已完成' : '待解锁',
            user.daysSinceJoin >= 7,
          ),
        ],
      ),
    );
  }

  // 使用习惯卡片
  Widget _buildUsageHabitsCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights,
                color: Colors.blue.shade600,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '使用习惯分析',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildHabitItem(
            '📊',
            '活跃度',
            _getActivityLevel(),
            _getActivityDescription(),
          ),
          const SizedBox(height: 12),
          
          _buildHabitItem(
            '⏰',
            '最佳使用时间',
            user.daysSinceJoin > 0 ? '晚上 20:00-22:00' : '暂无数据',
            '建议在这个时间使用效果更佳',
          ),
          const SizedBox(height: 12),
          
          _buildHabitItem(
            '🎯',
            '偏好功能',
            _getPreferredFeature(),
            '最常使用的功能模块',
          ),
        ],
      ),
    );
  }

  // 激励文案卡片
  Widget _buildMotivationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade50,
            Colors.pink.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.shade100,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome,
            size: 36,
            color: Colors.purple.shade400,
          ),
          const SizedBox(height: 12),
          
          Text(
            _getMotivationTitle(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          Text(
            _getMotivationMessage(),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '继续加油！每一天都是新的开始 🌟',
              style: TextStyle(
                fontSize: 13,
                color: Colors.purple.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建快速统计项
  Widget _buildQuickStat(String emoji, int count, String label) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // 构建里程碑项目
  Widget _buildMilestoneItem(String emoji, String title, String status, bool achieved) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: achieved 
                ? AppColors.accent.withOpacity(0.1) 
                : AppColors.textHint.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(
                  fontSize: 16,
                  color: achieved ? AppColors.accent : AppColors.textHint,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: achieved ? AppColors.textPrimary : AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: achieved ? AppColors.accent : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          if (achieved)
            Icon(
              Icons.check_circle,
              size: 20,
              color: AppColors.accent,
            ),
        ],
      ),
    );
  }

  // 构建习惯项目
  Widget _buildHabitItem(String emoji, String title, String value, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 获取加入日期文本
  String _getJoinDateText() {
    if (user.daysSinceJoin == 0) {
      return '今天加入静心岛';
    } else {
      final joinDate = user.joinDate;
      return '${joinDate.year}年${joinDate.month}月${joinDate.day}日加入';
    }
  }

  // 获取活跃度等级
  String _getActivityLevel() {
    final totalActivity = user.likeCount + user.collectionCount + user.postCount;
    if (totalActivity >= 50) return '非常活跃';
    if (totalActivity >= 20) return '活跃';
    if (totalActivity >= 5) return '一般';
    return '新手';
  }

  // 获取活跃度描述
  String _getActivityDescription() {
    final totalActivity = user.likeCount + user.collectionCount + user.postCount;
    if (totalActivity >= 50) return '您是静心岛的活跃用户！';
    if (totalActivity >= 20) return '保持良好的使用习惯';
    if (totalActivity >= 5) return '正在探索更多功能';
    return '刚刚开始静心之旅';
  }

  // 获取偏好功能
  String _getPreferredFeature() {
    if (user.postCount > user.likeCount && user.postCount > user.collectionCount) {
      return '情感广场';
    } else if (user.collectionCount > user.likeCount) {
      return '冥想音频';
    } else if (user.likeCount > 0) {
      return '社区互动';
    }
    return '尚未确定';
  }

  // 获取激励标题
  String _getMotivationTitle() {
    if (user.daysSinceJoin == 0) {
      return '欢迎来到静心岛！';
    } else if (user.daysSinceJoin < 7) {
      return '初来乍到，继续探索';
    } else if (user.daysSinceJoin < 30) {
      return '已经是老朋友了';
    } else {
      return '感谢一路陪伴';
    }
  }

  // 获取激励消息
  String _getMotivationMessage() {
    if (user.daysSinceJoin == 0) {
      return '这里是您心灵的港湾\n让我们一起开始这段美好的静心之旅\n每一天都是新的开始';
    } else if (user.daysSinceJoin < 7) {
      return '您已经在静心岛度过了${user.daysSinceJoin}天\n慢慢适应这里的节奏\n记住，成长需要时间';
    } else if (user.daysSinceJoin < 30) {
      return '${user.daysSinceJoin}天的相伴，感谢您的信任\n希望静心岛已经成为您生活的一部分\n每一次使用都是对自己的关爱';
    } else {
      return '${user.daysSinceJoin}天的陪伴，您见证了静心岛的成长\n我们也陪伴着您的心灵成长\n感恩有您，愿我们继续前行';
    }
  }
} 