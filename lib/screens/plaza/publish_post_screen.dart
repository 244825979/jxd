import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/common/custom_card.dart';

class PublishPostScreen extends StatefulWidget {
  final String selectedTopic;

  const PublishPostScreen({
    super.key,
    required this.selectedTopic,
  });

  @override
  State<PublishPostScreen> createState() => _PublishPostScreenState();
}

class _PublishPostScreenState extends State<PublishPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isPublishing = false;

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

  // 构建规则项目
  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.red.shade600,
          fontSize: 13,
          height: 1.3,
        ),
      ),
    );
  }

  // 显示违规提醒对话框
  void _showViolationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade600,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '内容违规提醒',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ 检测到您的内容可能包含违规信息',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '为维护良好的社区环境，请避免发布：\n• 色情、暴力、恐怖内容\n• 辱骂、诽谤性言论\n• 政治敏感信息\n• 违法违规内容',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '多次违规将导致账号被限制或封禁',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '重新编辑',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('选择图片失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  // 违规关键词检测
  bool _containsViolatingContent(String content) {
    final violatingKeywords = [
      // 色情相关
      '色情', '淫秽', '黄色', '性感', '裸体', '成人',
      // 暴力相关
      '暴力', '杀死', '血腥', '恐怖', '自杀', '死亡',
      // 辱骂相关
      '傻逼', '白痴', '垃圾', '废物', '滚蛋', 'sb',
      // 政治敏感
      '政治', '政府', '领导人',
      // 其他违规
      '广告', '刷屏', '诈骗', '赌博',
    ];
    
    final lowerContent = content.toLowerCase();
    for (String keyword in violatingKeywords) {
      if (lowerContent.contains(keyword.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  Future<void> _publishPost() async {
    final content = _contentController.text.trim();
    
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入动态内容'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 违规内容检测
    if (_containsViolatingContent(content)) {
      _showViolationDialog();
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    // 模拟发布过程
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isPublishing = false;
    });

    // 显示发布成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('发布成功！'),
        backgroundColor: AppColors.accent,
      ),
    );

    // 返回上一页
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '发布动态',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isPublishing ? null : _publishPost,
            child: Text(
              '发布',
              style: TextStyle(
                color: _isPublishing ? AppColors.textSecondary : AppColors.accent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 选中的话题标签
            CustomCard(
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    color: _getTopicColor(widget.selectedTopic),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '话题：',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _getTopicColor(widget.selectedTopic),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: _getTopicColor(widget.selectedTopic).withOpacity(0.1),
                    ),
                    child: Text(
                      '#${widget.selectedTopic}',
                      style: TextStyle(
                        color: _getTopicColor(widget.selectedTopic),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 违规内容提示
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '发布规则',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🚫 严禁发布以下违规内容：',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildRuleItem('• 色情、淫秽、低俗内容'),
                        _buildRuleItem('• 暴力、血腥、恐怖内容'),
                        _buildRuleItem('• 辱骂、诽谤、人身攻击'),
                        _buildRuleItem('• 仇恨言论、歧视性内容'),
                        _buildRuleItem('• 政治敏感、违法违规信息'),
                        _buildRuleItem('• 恶意刷屏、垃圾广告'),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.gavel,
                                color: Colors.red.shade700,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '违规处罚：警告 → 限制发布 → 永久封禁',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 动态内容输入
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '分享你的心情',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _contentController,
                    maxLines: 8,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: '写下你想分享的心情和感受...',
                      hintStyle: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      counterStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 图片选择区域
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '添加图片',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedImage == null)
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(
                            Icons.add_photo_alternate_outlined,
                            color: AppColors.accent,
                            size: 18,
                          ),
                          label: const Text(
                            '选择图片',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.textSecondary.withOpacity(0.3),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: AppColors.textSecondary,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              '点击添加图片',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 发布按钮
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isPublishing ? null : _publishPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: _isPublishing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        '发布动态',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // 发布提示
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '你的动态将以匿名方式发布，其他用户无法看到你的真实身份',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 用户协议和社区规则
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.textHint.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📋 发布须知',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 11,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: '发布动态即表示您同意遵守'),
                        TextSpan(
                          text: '《社区公约》',
                          style: TextStyle(
                            color: AppColors.accent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: '和'),
                        TextSpan(
                          text: '《用户协议》',
                          style: TextStyle(
                            color: AppColors.accent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: '。我们致力于营造温暖、友善的社区环境，感谢您的理解与配合。'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.amber.shade200,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.security,
                          color: Colors.amber.shade700,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '系统将自动检测违规内容并进行相应处理',
                          style: TextStyle(
                            color: Colors.amber.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 