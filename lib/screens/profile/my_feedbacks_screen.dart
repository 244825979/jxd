import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../../services/data_service.dart';
import '../../models/feedback.dart' as feedback_model;
import '../messages/feedback_screen.dart';

class MyFeedbacksScreen extends StatefulWidget {
  const MyFeedbacksScreen({super.key});

  @override
  State<MyFeedbacksScreen> createState() => _MyFeedbacksScreenState();
}

class _MyFeedbacksScreenState extends State<MyFeedbacksScreen> {
  final DataService _dataService = DataService.getInstance();
  List<feedback_model.Feedback> _feedbacks = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    setState(() {
      _isLoading = true;
    });

    // 模拟加载延迟
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _feedbacks = _dataService.getUserFeedbacks();
        _stats = _dataService.getFeedbackStats();
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadFeedbacks();
  }

  void _navigateToNewFeedback() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FeedbackScreen(),
      ),
    );

    // 如果提交了新反馈，刷新列表
    if (result == true) {
      _loadFeedbacks();
    }
  }

  Color _getStatusColor(feedback_model.FeedbackStatus status) {
    switch (status) {
      case feedback_model.FeedbackStatus.pending:
        return const Color(0xFFFF9800);
      case feedback_model.FeedbackStatus.replied:
        return const Color(0xFF4CAF50);
      case feedback_model.FeedbackStatus.resolved:
        return const Color(0xFF2196F3);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case '功能建议':
        return Icons.lightbulb_outline;
      case '问题反馈':
        return Icons.bug_report_outlined;
      case '内容建议':
        return Icons.article_outlined;
      case '体验优化':
        return Icons.tune_outlined;
      case '其他意见':
        return Icons.chat_outlined;
      default:
        return Icons.feedback_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case '功能建议':
        return const Color(0xFF4CAF50);
      case '问题反馈':
        return const Color(0xFFE74C3C);
      case '内容建议':
        return const Color(0xFF9C27B0);
      case '体验优化':
        return const Color(0xFF2196F3);
      case '其他意见':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF7F8C8D);
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
          '我的反馈',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Color(0xFF2C3E50),
            ),
            onPressed: _navigateToNewFeedback,
            tooltip: '新建反馈',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 统计概览
                    _buildStatsOverview(),
                    const SizedBox(height: 20),

                    // 反馈列表
                    if (_feedbacks.isEmpty)
                      _buildEmptyState()
                    else
                      _buildFeedbackList(),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewFeedback,
        backgroundColor: const Color(0xFF9C27B0),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '反馈统计',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '总计',
                  _stats['total']?.toString() ?? '0',
                  const Color(0xFF34495E),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '处理中',
                  _stats['pending']?.toString() ?? '0',
                  const Color(0xFFFF9800),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '已回复',
                  _stats['replied']?.toString() ?? '0',
                  const Color(0xFF4CAF50),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '已解决',
                  _stats['resolved']?.toString() ?? '0',
                  const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
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
              Icons.feedback_outlined,
              size: 50,
              color: Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '还没有反馈记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '您的意见对我们很重要\n点击下方按钮提交您的第一个反馈',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToNewFeedback,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              '提交反馈',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '反馈历史',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        ...(_feedbacks.map((feedback) => _buildFeedbackItem(feedback))),
      ],
    );
  }

  Widget _buildFeedbackItem(feedback_model.Feedback feedback) {
    final typeColor = _getTypeColor(feedback.type);
    final statusColor = _getStatusColor(feedback.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部：类型和状态
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: typeColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTypeIcon(feedback.type),
                        size: 14,
                        color: typeColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        feedback.type,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    feedback.statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 反馈内容
            Text(
              feedback.content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2C3E50),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // 底部信息
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  feedback.timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Text(
                  '#${feedback.id.substring(feedback.id.length - 8)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),

            // 如果有回复，显示回复内容
            if (feedback.response != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.reply,
                          size: 16,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '官方回复',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        const Spacer(),
                        if (feedback.responseAt != null)
                          Text(
                            feedback.responseAt!.difference(DateTime.now()).inDays.abs() <= 0
                                ? '今天'
                                : '${feedback.responseAt!.difference(DateTime.now()).inDays.abs()}天前',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feedback.response!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2C3E50),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 