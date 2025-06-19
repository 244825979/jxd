import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../../services/data_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final DataService _dataService = DataService.getInstance();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  final FocusNode _contactFocusNode = FocusNode();
  
  String _selectedType = '功能建议';
  bool _isSubmitting = false;
  String? _lastFeedbackId;

  final List<Map<String, dynamic>> _feedbackTypes = [
    {
      'title': '功能建议',
      'icon': Icons.lightbulb_outline,
      'color': const Color(0xFF4CAF50),
      'description': '对应用功能的改进建议',
    },
    {
      'title': '问题反馈',
      'icon': Icons.bug_report_outlined,
      'color': const Color(0xFFE74C3C),
      'description': '应用使用中遇到的问题',
    },
    {
      'title': '内容建议',
      'icon': Icons.article_outlined,
      'color': const Color(0xFF9C27B0),
      'description': '对内容质量的建议',
    },
    {
      'title': '体验优化',
      'icon': Icons.tune_outlined,
      'color': const Color(0xFF2196F3),
      'description': '用户体验相关建议',
    },
    {
      'title': '其他意见',
      'icon': Icons.chat_outlined,
      'color': const Color(0xFFFF9800),
      'description': '其他想法和建议',
    },
  ];

  @override
  void dispose() {
    _contentController.dispose();
    _contactController.dispose();
    _contentFocusNode.dispose();
    _contactFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请填写反馈内容'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 提交反馈到数据服务
      _lastFeedbackId = _dataService.submitFeedback(
        type: _selectedType,
        content: _contentController.text.trim(),
        contact: _contactController.text.trim().isEmpty 
            ? null 
            : _contactController.text.trim(),
      );

      // 模拟网络请求延迟
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // 显示成功对话框
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '提交成功',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '感谢您的宝贵意见！\n反馈编号：${_lastFeedbackId?.substring(_lastFeedbackId!.length - 8) ?? 'N/A'}\n我们会认真对待每一条反馈。',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 关闭对话框
                          Navigator.of(context).pop(true); // 返回上一页并传递true
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '确定',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        
        // 显示错误提示
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('提交失败：$e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
          '意见反馈',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎语
            CustomCard(
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF9C27B0).withOpacity(0.8),
                          const Color(0xFF673AB7).withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '您的意见很重要',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '帮助我们打造更好的静心岛',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 反馈类型选择
            const Text(
              '反馈类型',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              child: Column(
                children: _feedbackTypes.map((type) {
                  final isSelected = _selectedType == type['title'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = type['title'];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? type['color'].withOpacity(0.1) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected 
                              ? type['color'].withOpacity(0.3) 
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: type['color'].withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              type['icon'],
                              color: type['color'],
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type['title'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected 
                                        ? type['color'] 
                                        : const Color(0xFF2C3E50),
                                  ),
                                ),
                                Text(
                                  type['description'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF7F8C8D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: type['color'],
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // 详细描述
            const Text(
              '详细描述',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              child: TextField(
                controller: _contentController,
                focusNode: _contentFocusNode,
                maxLines: 6,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: '请详细描述您的意见或建议...',
                  hintStyle: TextStyle(
                    color: Color(0xFFBDC3C7),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  counterStyle: TextStyle(
                    color: Color(0xFFBDC3C7),
                    fontSize: 12,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2C3E50),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 联系方式
            const Text(
              '联系方式 (选填)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              child: TextField(
                controller: _contactController,
                focusNode: _contactFocusNode,
                decoration: const InputDecoration(
                  hintText: '邮箱或手机号，方便我们回复您',
                  hintStyle: TextStyle(
                    color: Color(0xFFBDC3C7),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  prefixIcon: Icon(
                    Icons.contact_mail_outlined,
                    color: Color(0xFFBDC3C7),
                    size: 20,
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 提交按钮
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  disabledBackgroundColor: const Color(0xFFBDC3C7),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '提交反馈',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // 隐私说明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF3498DB).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: const Color(0xFF3498DB),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '我们承诺保护您的隐私，反馈内容仅用于产品改进，不会泄露给第三方。',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3498DB),
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
    );
  }
} 