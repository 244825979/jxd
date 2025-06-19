import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../../models/report.dart';
import '../../services/data_service.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final DataService _dataService = DataService.getInstance();
  List<Report> _reports = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    setState(() {
      _isLoading = true;
    });

    // 模拟加载延迟
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _reports = _dataService.getMyReports();
        _stats = _dataService.getReportStats();
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
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '我的举报',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                _loadReports();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 统计卡片
                    _buildStatsCard(),
                    const SizedBox(height: 16),

                    // 举报说明
                    _buildInfoCard(),
                    const SizedBox(height: 16),

                    // 举报列表
                    if (_reports.isEmpty)
                      _buildEmptyState()
                    else
                      ..._reports.map((report) => _buildReportCard(report)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '举报统计',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '总计',
                  _stats['total']?.toString() ?? '0',
                  Colors.blue,
                  Icons.flag_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  '审核中',
                  _stats['pending']?.toString() ?? '0',
                  Colors.orange,
                  Icons.hourglass_empty,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '举报成立',
                  _stats['approved']?.toString() ?? '0',
                  Colors.green,
                  Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  '举报不成立',
                  _stats['rejected']?.toString() ?? '0',
                  Colors.red,
                  Icons.cancel_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
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
            Icons.info_outline,
            color: Colors.blue.shade600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '举报处理说明：举报提交后默认显示"审核中"状态，超过24小时后将显示最终审核结果。处理结果将通过系统通知告知您。理性举报，共建和谐社区。',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return CustomCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.flag_outlined,
              color: AppColors.textHint,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无举报记录',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '当您举报违规内容时，记录会显示在这里',
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 举报头部信息
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: report.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: report.statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    report.statusText,
                    style: TextStyle(
                      color: report.statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  report.timeAgo,
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 审核剩余时间（审核中状态）
            if (report.status == ReportStatus.pending && report.reviewTimeLeft.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.blue.shade600,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      report.reviewTimeLeft,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 举报原因
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '举报原因：',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report.reasonText,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 被举报内容
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.borderColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '被举报内容：',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.postContent,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 处理结果（如果有）
            if (report.status != ReportStatus.pending) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: report.status == ReportStatus.approved
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: report.status == ReportStatus.approved
                        ? Colors.green.shade200
                        : Colors.red.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          report.status == ReportStatus.approved
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: report.status == ReportStatus.approved
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '处理结果：${report.resultText}',
                          style: TextStyle(
                            color: report.status == ReportStatus.approved
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (report.resultNote != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        report.resultNote!,
                        style: TextStyle(
                          color: report.status == ReportStatus.approved
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                          fontSize: 10,
                          height: 1.3,
                        ),
                      ),
                    ],
                    if (report.reviewTimeAgo != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '审核时间：${report.reviewTimeAgo}',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // 详细说明（如果有）
            if (report.detail != null && report.detail!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '详细说明：${report.detail}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 