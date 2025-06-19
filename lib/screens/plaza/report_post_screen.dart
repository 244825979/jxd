import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../../models/post.dart';
import '../../services/data_service.dart';

class ReportPostScreen extends StatefulWidget {
  final Post post;

  const ReportPostScreen({super.key, required this.post});

  @override
  State<ReportPostScreen> createState() => _ReportPostScreenState();
}

class _ReportPostScreenState extends State<ReportPostScreen> {
  final TextEditingController _detailController = TextEditingController();
  final DataService _dataService = DataService.getInstance();
  String? _selectedReason;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _reportReasons = [
    {
      'id': 'inappropriate_content',
      'title': '不当内容',
      'subtitle': '色情、暴力、血腥等内容',
      'icon': Icons.warning_amber_rounded,
      'color': Colors.red,
    },
    {
      'id': 'harassment',
      'title': '骚扰辱骂',
      'subtitle': '人身攻击、恶意辱骂等',
      'icon': Icons.block,
      'color': Colors.orange,
    },
    {
      'id': 'false_info',
      'title': '虚假信息',
      'subtitle': '传播不实信息、谣言等',
      'icon': Icons.fact_check,
      'color': Colors.amber,
    },
    {
      'id': 'spam',
      'title': '垃圾信息',
      'subtitle': '广告推广、恶意刷屏等',
      'icon': Icons.delete_outline,
      'color': Colors.grey,
    },
    {
      'id': 'privacy_violation',
      'title': '侵犯隐私',
      'subtitle': '泄露他人隐私信息',
      'icon': Icons.privacy_tip,
      'color': Colors.blue,
    },
    {
      'id': 'other',
      'title': '其他原因',
      'subtitle': '其他违规或不当行为',
      'icon': Icons.more_horiz,
      'color': Colors.purple,
    },
  ];

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请选择举报原因'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 使用DataService提交举报
      final reportId = _dataService.submitReport(
        postId: widget.post.id,
        reason: _selectedReason!,
        detail: _detailController.text.trim().isEmpty ? null : _detailController.text.trim(),
      );

      setState(() {
        _isSubmitting = false;
      });

      // 显示成功提示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '举报提交成功',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '我们已收到您的举报，将在24小时内完成审核处理。感谢您为维护社区环境做出的贡献。',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '举报编号：$reportId',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
                Navigator.of(context).pop(); // 返回上一页
              },
              child: Text(
                '知道了',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('举报提交失败：$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '举报内容',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 举报说明
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.accent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '举报说明',
                              style: TextStyle(
                                color: AppColors.accent,
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
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '举报是维护社区健康环境的重要方式。我们承诺严肃对待每一个举报，并对举报者信息严格保密。恶意举报可能影响您的账号信誉。',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 被举报的动态预览
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '举报内容',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.borderColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: widget.post.authorAvatar.isNotEmpty
                                        ? Image.asset(
                                            widget.post.authorAvatar,
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
                                          )
                                        : Container(
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
                                          ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.post.authorName.isNotEmpty 
                                              ? widget.post.authorName 
                                              : '匿名用户',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          widget.post.timeAgo,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textHint,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.post.content,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 举报原因选择
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '举报原因',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '请选择最符合的举报原因',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._reportReasons.map((reason) => _buildReasonItem(reason)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 详细说明
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '详细说明',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '请详细描述违规情况（可选）',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _detailController,
                          maxLines: 4,
                          maxLength: 200,
                          decoration: InputDecoration(
                            hintText: '请描述具体的违规行为或提供更多信息...',
                            hintStyle: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.borderColor,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.borderColor,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.accent,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                            counterStyle: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 11,
                            ),
                          ),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 温馨提示
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '温馨提示：我们会认真审核每一个举报，处理结果将通过系统通知告知您。同时也希望您能理性举报，共同维护温暖的社区环境。',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 底部提交按钮
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        '提交举报',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonItem(Map<String, dynamic> reason) {
    final isSelected = _selectedReason == reason['id'];
    final color = reason['color'] as Color;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReason = reason['id'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                reason['icon'],
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason['title'],
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reason['subtitle'],
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
} 