import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../services/data_service.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../plaza/post_detail_screen.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  final DataService _dataService = DataService.getInstance();
  List<Post> _myPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyPosts();
  }

  Future<void> _loadMyPosts() async {
    setState(() {
      _isLoading = true;
    });

    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      final posts = _dataService.getMyPosts();
      setState(() {
        _myPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadMyPosts();
  }

  void _navigateToDetail(Post post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: post),
      ),
    );
    
    // 如果从详情页返回，刷新数据
    if (result == true) {
      _refreshData();
    }
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
        return const Color(0xFF9C27B0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '我的发布',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2C3E50)),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
                ),
              )
            : _myPosts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _myPosts.length,
                    itemBuilder: (context, index) {
                      final post = _myPosts[index];
                      return _buildPostCard(post);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF9C27B0).withOpacity(0.1),
                  const Color(0xFF673AB7).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.article_outlined,
              size: 60,
              color: Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '还没有发布过动态',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '快去广场分享你的第一条动态吧！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFFE8B931),
                  size: 32,
                ),
                const SizedBox(height: 12),
                const Text(
                  '发布小贴士',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '分享真实感受，与其他用户建立情感连接，一起成长。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            // 发布时间和状态
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  post.timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(post.status),
              ],
            ),
            const SizedBox(height: 12),

            // 动态内容
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2C3E50),
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // 图片（如果有）
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  post.imageUrl!,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 话题标签
            if (post.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                children: post.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTopicColor(tag).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getTopicColor(tag).withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getTopicColor(tag),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // 统计信息
            Row(
              children: [
                _buildStatItem(
                  Icons.favorite_border,
                  post.likeCount.toString(),
                  Colors.red.shade400,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  Icons.chat_bubble_outline,
                  post.commentCount.toString(),
                  Colors.blue.shade400,
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(PostStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case PostStatus.pending:
        color = const Color(0xFFE8B931);
        text = '审核中';
        break;
      case PostStatus.approved:
        color = const Color(0xFF4CAF50);
        text = '已发布';
        break;
      case PostStatus.rejected:
        color = const Color(0xFFE74C3C);
        text = '审核未通过';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
} 