import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../../services/storage_service.dart';
import '../../models/mood_record.dart';

class MoodRecordsScreen extends StatefulWidget {
  const MoodRecordsScreen({super.key});

  @override
  State<MoodRecordsScreen> createState() => _MoodRecordsScreenState();
}

class _MoodRecordsScreenState extends State<MoodRecordsScreen> {
  late StorageService _storageService;
  List<MoodRecord> _moodRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _storageService = await StorageService.getInstance();
    await _loadMoodRecords();
  }

  Future<void> _loadMoodRecords() async {
    final records = await _storageService.getMoodRecords();
    
    // 如果没有记录，添加一些测试数据
    if (records.isEmpty) {
      await _addTestData();
      final newRecords = await _storageService.getMoodRecords();
      // 按时间倒序排列（最新的在前面）
      newRecords.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        _moodRecords = newRecords;
        _isLoading = false;
      });
    } else {
      // 按时间倒序排列（最新的在前面）
      records.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        _moodRecords = records;
        _isLoading = false;
      });
    }
  }

  Future<void> _addTestData() async {
    final now = DateTime.now();
    final testRecords = [
      MoodRecord(
        id: '1',
        date: now.subtract(const Duration(days: 0, hours: 2)),
        moodEmoji: '😊',
        moodValue: 4,
        note: '今天工作很顺利，完成了一个重要的项目，心情很不错！',
        title: '工作顺利',
      ),
      MoodRecord(
        id: '2',
        date: now.subtract(const Duration(days: 1, hours: 3)),
        moodEmoji: '😴',
        moodValue: 3,
        note: '昨天熬夜了，今天有点累，但总体还行。',
        title: '有点疲惫',
      ),
      MoodRecord(
        id: '3',
        date: now.subtract(const Duration(days: 2, hours: 1)),
        moodEmoji: '😄',
        moodValue: 5,
        note: '和朋友们一起聚餐，聊得很开心，笑到肚子疼！',
        title: '开心聚餐',
      ),
      MoodRecord(
        id: '4',
        date: now.subtract(const Duration(days: 3, hours: 4)),
        moodEmoji: '😔',
        moodValue: 2,
        note: '遇到了一些挫折，感觉有点沮丧，需要调整心态。',
        title: '遇到挫折',
      ),
      MoodRecord(
        id: '5',
        date: now.subtract(const Duration(days: 4, hours: 2)),
        moodEmoji: '🤔',
        moodValue: 3,
        note: '今天在思考一些人生问题，心情比较平静。',
        title: '思考人生',
      ),
      MoodRecord(
        id: '6',
        date: now.subtract(const Duration(days: 5, hours: 1)),
        moodEmoji: '😌',
        moodValue: 4,
        note: '看了一本好书，心情很平和，感觉收获很多。',
        title: '读书收获',
      ),
      MoodRecord(
        id: '7',
        date: now.subtract(const Duration(days: 6, hours: 3)),
        moodEmoji: '😢',
        moodValue: 1,
        note: '今天心情很低落，什么都不想做，希望明天会好一些。',
        title: '心情低落',
      ),
    ];

    for (final record in testRecords) {
      await _storageService.addMoodRecord(record);
    }
  }

  String _getMoodTitle(int moodValue) {
    switch (moodValue) {
      case 1: return '很不开心';
      case 2: return '有点低落';
      case 3: return '平平常常';
      case 4: return '心情不错';
      case 5: return '非常开心';
      default: return '未知心情';
    }
  }

  Color _getMoodColor(int moodValue) {
    switch (moodValue) {
      case 1: return const Color(0xFFE57373); // 红色
      case 2: return const Color(0xFFFF8A65); // 橙红
      case 3: return const Color(0xFFFFB74D); // 橙色
      case 4: return const Color(0xFF81C784); // 浅绿
      case 5: return const Color(0xFF66BB6A); // 绿色
      default: return AppColors.textHint;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(date.year, date.month, date.day);
    
    if (recordDate == today) {
      return '今天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (recordDate == today.subtract(const Duration(days: 1))) {
      return '昨天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '情绪指数记录',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.accent),
            onPressed: _loadMoodRecords,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_moodRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mood_outlined,
              size: 80,
              color: AppColors.textHint.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '还没有情绪记录',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '去首页记录你的第一条心情吧',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                '去记录心情',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 统计卡片
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accent.withOpacity(0.1),
                AppColors.accent.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accent.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('📊', '${_moodRecords.length}', '总记录'),
              _buildStatColumn('📅', '${_getRecordDays()}', '记录天数'),
              _buildStatColumn('😊', _getAverageMood(), '平均心情'),
            ],
          ),
        ),

        // 记录列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _moodRecords.length,
            itemBuilder: (context, index) {
              final record = _moodRecords[index];
              return _buildMoodRecordItem(record, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String icon, String value, String label) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodRecordItem(MoodRecord record, int index) {
    final moodColor = _getMoodColor(record.moodValue);
    final moodTitle = _getMoodTitle(record.moodValue);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        child: Row(
          children: [
            // 左侧心情指示器
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: moodColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: moodColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    record.moodEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    record.moodValue.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: moodColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // 中间内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 心情标题和时间
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        moodTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _formatDate(record.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 心情内容
                  if (record.note != null && record.note!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        record.note!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    Text(
                      '今天的心情是${moodTitle.toLowerCase()}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textHint,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),

            // 右侧指示器
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: moodColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${record.moodValue}.0',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: moodColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getRecordDays() {
    if (_moodRecords.isEmpty) return 0;
    
    final uniqueDays = <String>{};
    for (final record in _moodRecords) {
      final dayKey = '${record.date.year}-${record.date.month}-${record.date.day}';
      uniqueDays.add(dayKey);
    }
    return uniqueDays.length;
  }

  String _getAverageMood() {
    if (_moodRecords.isEmpty) return '0.0';
    
    final total = _moodRecords.fold(0, (sum, record) => sum + record.moodValue);
    final average = total / _moodRecords.length;
    return average.toStringAsFixed(1);
  }
} 