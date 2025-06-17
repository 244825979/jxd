import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/global_player_overlay.dart';
import '../../services/data_service.dart';
import '../../services/player_service.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  late DataService _dataService;
  List<Map<String, dynamic>> _allRecommendations = [];

  @override
  void initState() {
    super.initState();
    _dataService = DataService.getInstance();
    _loadRecommendations();
  }

  void _loadRecommendations() {
    final recommendations = _dataService.getAllRecommendations();
    if (recommendations.isNotEmpty) {
      _allRecommendations = recommendations;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlobalPlayerOverlay(
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            '今日推荐',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.accent),
              onPressed: () {
                setState(() {
                  _loadRecommendations();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('推荐内容已刷新'),
                    backgroundColor: AppColors.accent,
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 顶部统计信息
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('今日推荐', '${_allRecommendations.length}'),
                    Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
                    _buildStatItem('冥想音频', '${_allRecommendations.where((item) => item['type'] == 'meditation').length}'),
                    Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
                    _buildStatItem('治愈语录', '${_allRecommendations.where((item) => item['type'] == 'quote').length}'),
                  ],
                ),
              ),

              // 推荐列表
              Expanded(
                child: ListenableBuilder(
                  listenable: PlayerService(),
                  builder: (context, _) {
                    final playerService = PlayerService();
                    
                    // 确保数据完整性
                    if (_allRecommendations.isEmpty) {
                      _loadRecommendations();
                    }
                    
                    return ListView.builder(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: playerService.isPlayerVisible ? 100 : 16, // 为悬浮播放器留出空间
                      ),
                      itemCount: _allRecommendations.length,
                      itemBuilder: (context, index) {
                        final item = _allRecommendations[index];
                        return _buildRecommendationItem(item, index, playerService);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationItem(Map<String, dynamic> item, int index, PlayerService playerService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        onTap: () => _onItemTap(item),
        child: Row(
          children: [
            // 左侧图标
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getItemColor(item['type']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getItemIcon(item['type']),
                color: _getItemColor(item['type']),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // 中间内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item['author'] != null)
                    Text(
                      '— ${item['author']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  if (item['duration'] != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['duration'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  if (item['description'] != null)
                    Text(
                      item['description'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // 右侧操作
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getItemColor(item['type']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getItemTypeLabel(item['type']),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _getItemColor(item['type']),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getItemIcon(String type) {
    switch (type) {
      case 'meditation':
        return Icons.self_improvement;
      case 'breathing':
        return Icons.air;
      case 'whitenoise':
        return Icons.waves;
      case 'quote':
        return Icons.format_quote;
      case 'music':
        return Icons.music_note;
      case 'story':
        return Icons.auto_stories;
      default:
        return Icons.play_arrow;
    }
  }

  Color _getItemColor(String type) {
    switch (type) {
      case 'meditation':
        return const Color(0xFF8E24AA);
      case 'breathing':
        return const Color(0xFF1976D2);
      case 'whitenoise':
        return const Color(0xFF00796B);
      case 'quote':
        return const Color(0xFFE91E63);
      case 'music':
        return const Color(0xFFFF9800);
      case 'story':
        return const Color(0xFF795548);
      default:
        return AppColors.accent;
    }
  }

  String _getItemTypeLabel(String type) {
    switch (type) {
      case 'meditation':
        return '冥想';
      case 'breathing':
        return '呼吸';
      case 'whitenoise':
        return '白噪音';
      case 'quote':
        return '语录';
      case 'music':
        return '音乐';
      case 'story':
        return '故事';
      default:
        return '推荐';
    }
  }

  void _onItemTap(Map<String, dynamic> item) {
    if (item['type'] == 'quote') {
      // 显示完整语录
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.format_quote,
                color: AppColors.accent,
                size: 40,
              ),
              const SizedBox(height: 16),
              Text(
                item['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (item['author'] != null) ...[
                const SizedBox(height: 12),
                Text(
                  '— ${item['author']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '关闭',
                style: TextStyle(color: AppColors.accent),
              ),
            ),
          ],
        ),
      );
    } else {
      // 音频类型的处理 - 使用全局播放服务
      PlayerService().playTrack(item, playlist: _allRecommendations);
    }
  }
} 