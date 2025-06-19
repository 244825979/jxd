import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/post.dart';
import '../../models/comment.dart';
import '../../services/data_service.dart';
import 'report_post_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final DataService _dataService = DataService.getInstance();

  List<Comment> _comments = [];
  bool _isLiked = false;
  bool _isBookmarked = false;
  int _likeCount = 0;
  int _commentCount = 0;
  bool _hasStateChanged = false; // 用于追踪状态是否发生变化

  @override
  void initState() {
    super.initState();
    // 从数据服务获取最新的帖子状态
    final latestPost = _dataService.getPostById(widget.post.id);
    if (latestPost != null) {
      _isLiked = latestPost.isLiked;
      _isBookmarked = latestPost.isBookmarked;
      _likeCount = latestPost.likeCount;
      _commentCount = latestPost.commentCount;
    } else {
      _isLiked = widget.post.isLiked;
      _isBookmarked = widget.post.isBookmarked;
      _likeCount = widget.post.likeCount;
      _commentCount = widget.post.commentCount;
    }
    _loadComments();
    // 确保评论数量与实际评论列表一致
    _commentCount = _comments.length;
  }

  void _loadComments() {
    // 从数据服务获取评论数据
    _comments = _dataService.getCommentsForPost(widget.post.id);
    setState(() {});
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  // 统一的返回处理方法
  void _handleBack() {
    Navigator.pop(context, _hasStateChanged);
  }

  // 系统返回处理（只处理系统返回手势）
  void _handleSystemBack() {
    Navigator.pop(context, _hasStateChanged);
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
          onPressed: _handleBack,
        ),
        title: const Text(
          '动态详情',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.textPrimary),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // 动态内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 动态卡片
                  _buildPostCard(),
                  const SizedBox(height: 12),

                  // 评论列表
                  _buildCommentsSection(),
                  
                  // 底部间距，避免评论列表贴底
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 评论输入框
          _buildCommentInput(),
        ],
      ),
    );
  }

  // 构建动态卡片
  Widget _buildPostCard() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          // 用户信息
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: widget.post.authorAvatar.isNotEmpty
                    ? Image.asset(
                        widget.post.authorAvatar,
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
                      widget.post.authorName.isNotEmpty 
                          ? widget.post.authorName 
                          : '匿名用户',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.post.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 动态内容
          Text(
            widget.post.content,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // 图片（如果有）
          if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.post.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.borderColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.textHint,
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
          if (widget.post.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              children: widget.post.tags.map((tag) {
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
            const SizedBox(height: 16),
          ],

          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                label: _likeCount.toString(),
                color: _isLiked ? Colors.red : AppColors.textSecondary,
                onTap: _toggleLike,
              ),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: _commentCount.toString(),
                color: AppColors.textSecondary,
                onTap: () {
                  _commentFocusNode.requestFocus();
                },
              ),
              _buildActionButton(
                icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                label: '',
                color: _isBookmarked ? AppColors.accent : AppColors.textSecondary,
                onTap: _toggleBookmark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建评论区域
  Widget _buildCommentsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '评论 ${_comments.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_comments.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 40,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '还没有评论',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '来说说你的看法吧',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _comments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return _buildCommentItem(comment);
              },
            ),
        ],
      ),
    );
  }

  // 构建单个评论项
  Widget _buildCommentItem(Comment comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            comment.authorAvatar,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.borderColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.textHint,
                  size: 16,
                ),
              );
            },
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
                    comment.authorName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    comment.timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (comment.isLiked) {
                          comment.likeCount--;
                        } else {
                          comment.likeCount++;
                        }
                        comment.isLiked = !comment.isLiked;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          comment.isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: comment.isLiked ? Colors.red : AppColors.textHint,
                        ),
                        if (comment.likeCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            comment.likeCount.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: comment.isLiked ? Colors.red : AppColors.textHint,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      _commentController.text = '@${comment.authorName} ';
                      _commentFocusNode.requestFocus();
                    },
                    child: Text(
                      '回复',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 构建评论输入框
  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 
               MediaQuery.of(context).padding.bottom + 16, // 考虑安全区域 + 额外间距
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.borderColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.borderColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _commentController,
                focusNode: _commentFocusNode,
                decoration: const InputDecoration(
                  hintText: '说说你的看法...',
                  hintStyle: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                maxLines: 3,
                minLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _postComment,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建操作按钮
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

  // 切换点赞状态
  void _toggleLike() {
    final newLikeStatus = _dataService.togglePostLike(widget.post.id);
    
    setState(() {
      _isLiked = newLikeStatus;
      if (newLikeStatus) {
        _likeCount++;
      } else {
        _likeCount--;
      }
      _hasStateChanged = true;
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

  // 切换收藏状态
  void _toggleBookmark() {
    final newBookmarkStatus = _dataService.togglePostBookmark(widget.post.id);
    
    setState(() {
      _isBookmarked = newBookmarkStatus;
      _hasStateChanged = true;
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

  // 发布评论
  void _postComment() {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入评论内容'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 创建新评论
    final newComment = Comment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: widget.post.id,
      authorName: '温暖如风',
      authorAvatar: 'assets/images/avatars/user_15.png',
      content: commentText,
      createdAt: DateTime.now(),
      likeCount: 0,
      isLiked: false,
    );

    // 使用 DataService 添加评论，这会自动更新评论数量
    _dataService.addComment(widget.post.id, newComment);

    // 重新加载评论和更新状态
    _loadComments();
    
    setState(() {
      _commentCount = _comments.length;
      _commentController.clear();
      _commentFocusNode.unfocus();
      _hasStateChanged = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('评论发布成功'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  // 显示更多选项
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _buildOptionItem(Icons.flag_outlined, '举报', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportPostScreen(post: widget.post),
                  ),
                );
              }),
              _buildOptionItem(Icons.block, '屏蔽用户', () {
                Navigator.pop(context);
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 