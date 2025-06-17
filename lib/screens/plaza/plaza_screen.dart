import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/data_service.dart';
import '../../models/post.dart';
import '../../widgets/common/custom_card.dart';

class PlazaScreen extends StatefulWidget {
  const PlazaScreen({super.key});

  @override
  State<PlazaScreen> createState() => _PlazaScreenState();
}

class _PlazaScreenState extends State<PlazaScreen> {
  late DataService _dataService;
  List<Post> _posts = [];
  List<String> _hotTopics = [];

  @override
  void initState() {
    super.initState();
    _dataService = DataService.getInstance();
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
                    children: _hotTopics.take(4).map((topic) => 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '#$topic',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // 发布按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 导航到发布页面
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text(
                        AppStrings.anonymousPost,
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
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
    return CustomCard(
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
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '匿名用户',
                      style: TextStyle(
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
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.image,
                size: 48,
                color: AppColors.accent,
              ),
            ),
          ],
          
          // 标签
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: post.tags.map((tag) => 
                Text(
                  '#$tag',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                  ),
                ),
              ).toList(),
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
                onTap: () {
                  // TODO: 点赞功能
                },
              ),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: post.commentCount.toString(),
                color: AppColors.textSecondary,
                onTap: () {
                  // TODO: 评论功能
                },
              ),
              _buildActionButton(
                icon: post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                label: '',
                color: post.isBookmarked ? AppColors.accent : AppColors.textSecondary,
                onTap: () {
                  // TODO: 收藏功能
                },
              ),
            ],
          ),
        ],
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
} 