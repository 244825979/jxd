import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/post.dart';
import '../../services/data_service.dart';
import '../../widgets/common/custom_card.dart';
import '../plaza/post_detail_screen.dart';

class MyBookmarkedPostsScreen extends StatefulWidget {
  const MyBookmarkedPostsScreen({super.key});

  @override
  State<MyBookmarkedPostsScreen> createState() => _MyBookmarkedPostsScreenState();
}

class _MyBookmarkedPostsScreenState extends State<MyBookmarkedPostsScreen> {
  final DataService _dataService = DataService.getInstance();
  List<Post> _bookmarkedPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarkedPosts();
  }

  void _loadBookmarkedPosts() {
    setState(() {
      _isLoading = true;
    });

    // 获取收藏的动态列表
    _bookmarkedPosts = _dataService.getBookmarkedPosts();

    setState(() {
      _isLoading = false;
    });
  }

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
          '我的收藏',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
              ),
            )
          : _bookmarkedPosts.isEmpty
              ? _buildEmptyState()
              : _buildBookmarkedPostsList(),
    );
  }

  // 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_border,
              size: 50,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '还没有收藏任何动态',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '去广场看看，收藏喜欢的内容吧',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: const Text(
              '去广场逛逛',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建收藏动态列表
  Widget _buildBookmarkedPostsList() {
    return Column(
      children: [
        // 统计信息
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.accent.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.bookmark,
                size: 20,
                color: AppColors.accent,
              ),
              const SizedBox(width: 8),
              Text(
                '共收藏了 ${_bookmarkedPosts.length} 条动态',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // 动态列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _bookmarkedPosts.length,
            itemBuilder: (context, index) {
              final post = _bookmarkedPosts[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildPostCard(post),
              );
            },
          ),
        ),
      ],
    );
  }

  // 构建动态卡片
  Widget _buildPostCard(Post post) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
        );
        if (result == true) {
          _loadBookmarkedPosts(); // 刷新列表
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息和收藏标识
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: post.authorAvatar.isNotEmpty
                      ? Image.asset(
                          post.authorAvatar,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppColors.borderColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: AppColors.textHint,
                                size: 20,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.borderColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.textHint,
                            size: 20,
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
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(post.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bookmark,
                        size: 12,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '已收藏',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 动态内容
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            // 图片（如果有）
            if (post.imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  post.imageUrl!,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 150,
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
                children: post.tags.map((tag) => _buildTopicTag(tag)).toList(),
              ),
            ],

            const SizedBox(height: 12),

            // 互动数据
            Row(
              children: [
                Icon(
                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: post.isLiked ? Colors.red : AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  post.likeCount.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: post.isLiked ? Colors.red : AppColors.textHint,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 16,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  post.commentCount.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建话题标签
  Widget _buildTopicTag(String topic) {
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

  // 获取话题颜色
  Color _getTopicColor(String topic) {
    switch (topic) {
      case '今日心情':
        return const Color(0xFFE8B931);
      case '孤独瞬间':
        return const Color(0xFF6B73FF);
      case '来自深夜的我':
        return const Color(0xFF9C27B0);
      case '治愈系语录':
        return const Color(0xFF4CAF50);
      case '情感树洞':
        return const Color(0xFFFF7043);
      case '温暖时刻':
        return const Color(0xFFEC407A);
      default:
        return AppColors.accent;
    }
  }

  // 格式化时间
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}月${dateTime.day}日';
    }
  }
} 