import 'dart:async';
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

class _PlazaScreenState extends State<PlazaScreen> with WidgetsBindingObserver {
  final DataService _dataService = DataService.getInstance();
  List<Post> _posts = [];
  List<String> _hotTopics = [];
  String? _selectedTopic;
  bool _isNavigating = false; // 防止重复导航
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 当应用重新获得焦点时刷新数据
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  // 启动自动刷新（由于审核状态不会自动改变，暂时禁用）
  void _startAutoRefresh() {
    // 由于审核状态保持不变，不需要自动刷新
    // _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //   // 检查是否有审核中的动态需要更新
    //   final hasUpdates = _posts.any((post) => post.status == PostStatus.pending);
    //   if (hasUpdates) {
    //     setState(() {
    //       _posts = _dataService.getPosts();
    //     });
    //   }
    // });
  }

  void _loadData() {
    setState(() {
      _posts = _dataService.getPosts();
      _hotTopics = _dataService.getHotTopics();
    });
  }

  // 防重复导航的导航方法
  void _navigateToDetail(Post post) {
    if (_isNavigating) return; // 如果正在导航，直接返回
    
    _isNavigating = true;
    
    // 使用 Future.microtask 来避免在 build 过程中导航
    Future.microtask(() async {
      try {
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
      } catch (e) {
        print('Navigation error: $e');
      } finally {
        _isNavigating = false; // 导航完成后重置标志
      }
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
                      onPressed: _selectedTopic != null ? () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PublishPostScreen(
                              selectedTopic: _selectedTopic!,
                            ),
                          ),
                        );
                        
                        // 如果发布成功，刷新动态列表
                        if (result == true) {
                          setState(() {
                            _posts = _dataService.getPosts();
                          });
                        }
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
      onTap: () => _navigateToDetail(post),
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
                    Row(
                      children: [
                        Text(
                          post.authorName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        // 审核状态标签
                        if (post.status != PostStatus.approved) ...[
                          const SizedBox(width: 8),
                          _buildStatusBadge(post.status),
                        ],
                      ],
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
                onTap: () => _navigateToDetail(post),
              ),
              _buildActionButton(
                icon: post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                label: '',
                color: post.isBookmarked ? AppColors.accent : AppColors.textSecondary,
                onTap: () => _toggleBookmark(post.id),
              ),
              // 只有不是自己发布的动态才显示屏蔽按钮
              if (!_dataService.isMyPost(post.id))
                _buildActionButton(
                  icon: Icons.block_outlined,
                  label: '',
                  color: Colors.grey.shade600,
                  onTap: () => _blockPost(post.id),
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
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // 阻止事件冒泡
      child: Container(
        padding: const EdgeInsets.all(4), // 增加点击区域
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

  // 屏蔽功能
  void _blockPost(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('屏蔽内容'),
        content: const Text('确定要屏蔽这条内容吗？\n屏蔽后该内容将不再在动态列表中显示。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              
              // 执行屏蔽操作
              _dataService.blockPost(postId);
              
              // 刷新动态列表
              setState(() {
                _posts = _dataService.getPosts();
              });
              
              // 显示成功提示
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已屏蔽该内容'),
                  backgroundColor: AppColors.accent,
                  duration: Duration(milliseconds: 1500),
                ),
              );
            },
            child: const Text(
              '确定屏蔽',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
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

  // 构建审核状态标签
  Widget _buildStatusBadge(PostStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case PostStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        text = '审核中';
        icon = Icons.hourglass_empty;
        break;
      case PostStatus.approved:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        text = '已通过';
        icon = Icons.check_circle_outline;
        break;
      case PostStatus.rejected:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        text = '未通过';
        icon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: textColor,
          ),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 