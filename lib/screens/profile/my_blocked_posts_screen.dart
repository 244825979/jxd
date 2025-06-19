import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/post.dart';
import '../../services/data_service.dart';
import '../../widgets/common/custom_card.dart';

class MyBlockedPostsScreen extends StatefulWidget {
  const MyBlockedPostsScreen({super.key});

  @override
  State<MyBlockedPostsScreen> createState() => _MyBlockedPostsScreenState();
}

class _MyBlockedPostsScreenState extends State<MyBlockedPostsScreen> {
  final DataService _dataService = DataService.getInstance();
  List<Post> _blockedPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedPosts();
  }

  void _loadBlockedPosts() {
    setState(() {
      _isLoading = true;
    });

    // 获取被屏蔽的动态ID列表
    final blockedPostIds = _dataService.getBlockedPostIds();
    
    // 根据ID获取具体的动态信息
    _blockedPosts = [];
    for (final postId in blockedPostIds) {
      final post = _dataService.getBlockedPostById(postId);
      if (post != null) {
        _blockedPosts.add(post);
      }
    }

    // 按屏蔽时间排序（最新的在前）
    _blockedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _isLoading = false;
    });
  }

  void _unblockPost(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消屏蔽'),
        content: const Text('确定要取消屏蔽这条内容吗？取消后该内容将重新在动态列表中显示。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _dataService.unblockPost(postId);
              _loadBlockedPosts(); // 刷新列表
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已取消屏蔽'),
                  backgroundColor: AppColors.accent,
                ),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          '我的屏蔽',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_blockedPosts.isNotEmpty)
            TextButton(
              onPressed: () => _showClearAllDialog(),
              child: const Text(
                '全部取消',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            )
          : _blockedPosts.isEmpty
              ? _buildEmptyState()
              : _buildBlockedPostsList(),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 动画容器背景
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accent.withOpacity(0.1),
                  Colors.green.withOpacity(0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade50,
                  border: Border.all(
                    color: Colors.green.shade200,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  size: 40,
                  color: Colors.green.shade600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // 主标题
          Text(
            '社区环境清洁',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          
          // 副标题
          Text(
            '您还没有屏蔽任何内容',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          
          // 描述信息
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue.shade100,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  '当您遇到违规或不感兴趣的内容时，可以选择屏蔽\n被屏蔽的内容将不再在动态列表中显示',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade700,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // 功能说明卡片
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  Icons.visibility_off,
                  '屏蔽内容',
                  '隐藏不喜欢的动态',
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureCard(
                  Icons.restore,
                  '随时恢复',
                  '可以取消屏蔽状态',
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 底部提示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.accent,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '理性参与，共建和谐社区环境',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedPostsList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 统计信息
          CustomCard(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.block,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '已屏蔽 ${_blockedPosts.length} 条内容',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '屏蔽的内容不会在动态列表中显示',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 屏蔽列表
          Expanded(
            child: ListView.builder(
              itemCount: _blockedPosts.length,
              itemBuilder: (context, index) {
                final post = _blockedPosts[index];
                return _buildBlockedPostCard(post);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息和屏蔽标识
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      post.authorAvatar,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: AppColors.accent, size: 20),
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
                      const SizedBox(height: 2),
                      Text(
                        post.timeAgo,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.shade200,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '已屏蔽',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 内容预览
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.borderColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.content,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (post.imageUrl != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '[包含图片]',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 操作按钮
            Row(
              children: [
                // 话题标签
                if (post.tags.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#${post.tags.first}',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => _unblockPost(post.id),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text(
                    '取消屏蔽',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消全部屏蔽'),
        content: Text('确定要取消屏蔽所有 ${_blockedPosts.length} 条内容吗？\n这些内容将重新在动态列表中显示。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 取消所有屏蔽
              for (final post in _blockedPosts) {
                _dataService.unblockPost(post.id);
              }
              _loadBlockedPosts(); // 刷新列表
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已取消全部屏蔽'),
                  backgroundColor: AppColors.accent,
                ),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
} 