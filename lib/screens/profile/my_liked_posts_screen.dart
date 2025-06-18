import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/post.dart';
import '../../services/data_service.dart';
import '../../widgets/common/custom_card.dart';
import '../plaza/post_detail_screen.dart';

class MyLikedPostsScreen extends StatefulWidget {
  const MyLikedPostsScreen({super.key});

  @override
  State<MyLikedPostsScreen> createState() => _MyLikedPostsScreenState();
}

class _MyLikedPostsScreenState extends State<MyLikedPostsScreen> {
  final DataService _dataService = DataService.getInstance();
  List<Post> _likedPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLikedPosts();
  }

  void _loadLikedPosts() {
    setState(() {
      _isLoading = true;
    });
    
    // 模拟加载延迟
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _likedPosts = _dataService.getLikedPosts();
        _isLoading = false;
      });
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
          '我的点赞',
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
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _likedPosts.isEmpty 
              ? _buildEmptyState()
              : _buildPostsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: CustomCard(
        margin: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            const Text(
              '还没有点赞过动态',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '去情感广场看看，给喜欢的动态点个赞吧',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // 这里可以添加跳转到情感广场的逻辑
              },
              icon: const Icon(Icons.explore, color: Colors.white),
              label: const Text(
                '去发现精彩',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    return Column(
      children: [
        // 统计信息
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accent.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.favorite,
                color: Colors.red.shade400,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '共点赞了 ${_likedPosts.length} 条动态',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '最近点赞在前',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),

        // 动态列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _likedPosts.length,
            itemBuilder: (context, index) {
              final post = _likedPosts[index];
              return _buildPostCard(post);
            },
          ),
        ),
      ],
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
        
        // 如果状态发生变化，刷新列表
        if (result == true) {
          _loadLikedPosts();
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
                ClipOval(
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
                // 点赞状态指示
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.shade200,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 12,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '已点赞',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 动态内容（最多显示3行）
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
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: AppColors.accent,
                      ),
                    );
                  },
                ),
              ),
            ],

            // 话题标签
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
                _buildInteractionItem(
                  Icons.favorite,
                  post.likeCount.toString(),
                  Colors.red.shade400,
                ),
                const SizedBox(width: 16),
                _buildInteractionItem(
                  Icons.chat_bubble_outline,
                  post.commentCount.toString(),
                  AppColors.textSecondary,
                ),
                if (post.isBookmarked) ...[
                  const SizedBox(width: 16),
                  _buildInteractionItem(
                    Icons.bookmark,
                    '',
                    AppColors.accent,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicTag(String topic) {
    final color = _getTopicColor(topic);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        '#$topic',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInteractionItem(IconData icon, String count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        if (count.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ],
    );
  }

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
} 