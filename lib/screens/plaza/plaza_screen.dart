import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/data_service.dart';
import '../../models/post.dart';
import '../../widgets/common/custom_card.dart';
import 'publish_post_screen.dart';
import 'post_detail_screen.dart';

class PlazaScreen extends StatefulWidget {
  const PlazaScreen({super.key});

  @override
  State<PlazaScreen> createState() => _PlazaScreenState();
}

class _PlazaScreenState extends State<PlazaScreen> {
  final DataService _dataService = DataService.getInstance();
  List<Post> _posts = [];
  List<String> _hotTopics = [];
  String? _selectedTopic;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _posts = _dataService.getPosts();
      _hotTopics = _dataService.getHotTopics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            const Text(
              AppStrings.plazaTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 话题引导区 & 发布入口
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.hotTopics,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 热门话题标签
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _hotTopics.take(6).toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final topic = entry.value;
                      return _buildTopicTag(
                        topic, 
                        index,
                        isSelected: _selectedTopic == topic,
                        onTap: () {
                          setState(() {
                            _selectedTopic = _selectedTopic == topic ? null : topic;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // 发布按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _selectedTopic != null ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PublishPostScreen(
                              selectedTopic: _selectedTopic!,
                            ),
                          ),
                        );
                      } : null,
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: Text(
                        _selectedTopic != null ? '发布到 #$_selectedTopic' : '请先选择话题',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTopic != null ? AppColors.accent : AppColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 动态流
            ...(_posts.map((post) => _buildPostCard(post))),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
        );
        
        // 如果从详情页返回，刷新数据
        if (result == true) {
          _loadData();
        }
      },
      child: CustomCard(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    post.authorAvatar,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: AppColors.accent),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      post.timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 内容
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          
          // 图片（如果有）
          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                post.imageUrl!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: AppColors.accent,
                    ),
                  );
                },
              ),
            ),
          ],
          
          // 标签
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: post.tags.map((tag) => _buildPostTopicTag(tag)).toList(),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // 互动按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                label: post.likeCount.toString(),
                color: post.isLiked ? Colors.red : AppColors.textSecondary,
                onTap: () => _toggleLike(post.id),
              ),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: post.commentCount.toString(),
                color: AppColors.textSecondary,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailScreen(post: post),
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
              ),
              _buildActionButton(
                icon: post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                label: '',
                color: post.isBookmarked ? AppColors.accent : AppColors.textSecondary,
                onTap: () => _toggleBookmark(post.id),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 点赞功能
  void _toggleLike(String postId) {
    final newLikeStatus = _dataService.togglePostLike(postId);
    
    setState(() {
      // 刷新帖子列表以更新UI
      _posts = _dataService.getPosts();
    });

    // 显示提示信息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newLikeStatus ? '已点赞' : '已取消点赞'),
        backgroundColor: newLikeStatus ? Colors.red.shade400 : AppColors.textSecondary,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  // 收藏功能
  void _toggleBookmark(String postId) {
    final newBookmarkStatus = _dataService.togglePostBookmark(postId);
    
    setState(() {
      // 刷新帖子列表以更新UI
      _posts = _dataService.getPosts();
    });

    // 显示提示信息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newBookmarkStatus ? '已收藏' : '已取消收藏'),
        backgroundColor: newBookmarkStatus ? AppColors.accent : AppColors.textSecondary,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  // 为每个话题分配暖色系颜色的映射
  Color _getTopicColor(String topic) {
    final topicColors = {
      '今日心情': const Color(0xFFE67E22), // 橙色
      '孤独瞬间': const Color(0xFFD35400), // 深橙色
      '来自深夜的我': const Color(0xFF8E44AD), // 紫色
      '治愈系语录': const Color(0xFF27AE60), // 绿色
      '情感树洞': const Color(0xFFE74C3C), // 红色
      '温暖时刻': const Color(0xFFF39C12), // 金色
    };
    return topicColors[topic] ?? const Color(0xFFE67E22);
  }

  // 构建动态内容中的话题标签，使用暖色系
  Widget _buildPostTopicTag(String topic) {
    final color = _getTopicColor(topic);
    return Text(
      '#$topic',
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // 构建话题标签，简洁样式（用于发布界面的话题选择）
  Widget _buildTopicTag(String topic, int index, {bool isSelected = false, VoidCallback? onTap}) {
    final color = _getTopicColor(topic);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        ),
        child: Text(
          '#$topic',
          style: TextStyle(
            color: isSelected ? color : color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
} 