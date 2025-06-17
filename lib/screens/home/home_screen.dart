import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

import '../../widgets/common/custom_card.dart';
import '../../widgets/common/mood_selector.dart';
import '../../services/data_service.dart';
import '../../services/storage_service.dart';
import '../../services/player_service.dart';
import '../../models/mood_record.dart';
import 'ai_chat_screen.dart';
import 'recommendations_screen.dart';
import '../mood/mood_records_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedMood = 5;
  final TextEditingController _moodNoteController = TextEditingController();
  late DataService _dataService;
  late StorageService _storageService;
  bool _isInitialized = false;
  Key _weeklyMoodKey = UniqueKey(); // 用于强制刷新心情卡片

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _dataService = DataService.getInstance();
    _storageService = await StorageService.getInstance();
    
    // 初始化时自动填充默认心情(5-一般)的内容
    _onMoodContentChanged(_getDefaultMoodContent());
    
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _moodNoteController.dispose();
    super.dispose();
  }

  void _onMoodChanged(int mood) {
    setState(() {
      _selectedMood = mood;
    });
  }

  void _onMoodContentChanged(String content) {
    _moodNoteController.text = content;
  }

  Future<void> _submitMoodRecord() async {
    if (!_isInitialized) return;

    final record = MoodRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      moodValue: _selectedMood,
      moodEmoji: _getMoodEmoji(_selectedMood),
      note: _moodNoteController.text.isNotEmpty ? _moodNoteController.text : null,
    );

    await _storageService.addMoodRecord(record);
    
    // 重置到默认状态并自动填充默认心情内容
    setState(() {
      _selectedMood = 5;
      _weeklyMoodKey = UniqueKey(); // 刷新心情卡片
    });
    _onMoodContentChanged(_getDefaultMoodContent());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('心情记录已保存'),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 0: return '😢';
      case 3: return '😔';
      case 5: return '😐';
      case 8: return '🙂';
      case 10: return '😊';
      default: return '😐';
    }
  }

  String _getDefaultMoodContent() {
    // 默认心情(5-一般)的内容
    return '今天感觉平平常常，没有特别的起伏，就是普通的一天，希望明天会更好。';
  }

  void _navigateToAIChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AIChatScreen(),
      ),
    );
  }

  // 生成最近7天的心情数据
  Future<List<Map<String, dynamic>>> _generateWeeklyMoodData() async {
    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();
    
    // 获取存储的心情记录
    final moodRecords = await _storageService.getMoodRecords();
    
    // 生成7天的数据
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      // 查找当天的心情记录
      final dayRecords = moodRecords.where((record) {
        return record.date.isAfter(dayStart.subtract(const Duration(milliseconds: 1))) &&
               record.date.isBefore(dayEnd);
      }).toList();
      
      double moodValue = 0.0;
      if (dayRecords.isNotEmpty) {
        // 如果有记录，计算当天的平均心情
        final totalMood = dayRecords.fold(0, (sum, record) => sum + record.moodValue);
        moodValue = totalMood / dayRecords.length;
      }
      // 如果没有记录，保持为0（不显示柱子）
      
      data.add({
        'date': date,
        'mood': moodValue,
        'dayLabel': i == 0 ? '今天' : '${date.month}/${date.day}',
        'isToday': i == 0,
        'hasRecord': dayRecords.isNotEmpty,
      });
    }
    
    return data;
  }

  // 构建最近7天心情卡片
  Widget _buildWeeklyMoodCard() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      key: _weeklyMoodKey,
      future: _generateWeeklyMoodData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CustomCard(
            child: Container(
              height: 200,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            ),
          );
        }
        
        final moodData = snapshot.data!;
        final recordDays = moodData.where((data) => data['hasRecord'] == true).length;
        final recordsWithMood = moodData.where((data) => data['hasRecord'] == true).toList();
        final avgMood = recordsWithMood.isNotEmpty 
            ? recordsWithMood.map((e) => e['mood'] as double).reduce((a, b) => a + b) / recordsWithMood.length
            : 0.0;
        
        return _buildWeeklyMoodCardContent(moodData, recordDays, avgMood);
      },
    );
  }

  // 构建心情卡片内容
  Widget _buildWeeklyMoodCardContent(List<Map<String, dynamic>> moodData, int recordDays, double avgMood) {
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和平均分
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '最近情绪打卡指数',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
                             Container(
                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                 decoration: BoxDecoration(
                   color: AppColors.accent.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: Text(
                   '平均 ${avgMood.toStringAsFixed(1)}',
                   style: const TextStyle(
                     fontSize: 12,
                     fontWeight: FontWeight.w500,
                     color: AppColors.accent,
                   ),
                 ),
               ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 柱状图
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: moodData.map((data) {
                return _buildMoodBar(data);
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 统计信息
                     Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: AppColors.accent.withOpacity(0.15),
               borderRadius: BorderRadius.circular(12),
             ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('😊', '$recordDays', '记录天数'),
                _buildStatItem('📅', '7', '统计天数'),
                _buildStatItem('📈', avgMood > 0 ? avgMood.toStringAsFixed(1) : '--', '平均心情'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 记录按钮
          SizedBox(
            width: double.infinity,
            child:              ElevatedButton.icon(
               onPressed: () {
                 Navigator.of(context).push(
                   MaterialPageRoute(
                     builder: (context) => const MoodRecordsScreen(),
                   ),
                 );
               },
                             icon: const Icon(Icons.edit, color: AppColors.accent, size: 18),
               label: const Text(
                 '查看情绪指数',
                 style: TextStyle(
                   color: AppColors.accent,
                   fontSize: 14,
                   fontWeight: FontWeight.w500,
                 ),
               ),
               style: ElevatedButton.styleFrom(
                 backgroundColor: AppColors.accent.withOpacity(0.1),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

    // 构建单个心情柱子
  Widget _buildMoodBar(Map<String, dynamic> data) {
    final mood = data['mood'] as double;
    final isToday = data['isToday'] as bool;
    final hasRecord = data['hasRecord'] as bool;
    
    // 如果没有记录，显示占位柱子
    if (!hasRecord) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 占位柱子
          Container(
            width: 24,
            height: 15,
            decoration: BoxDecoration(
              color: AppColors.textHint.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '--',
                style: TextStyle(
                  fontSize: 8,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 日期标签
          Text(
            data['dayLabel'],
            style: TextStyle(
              fontSize: 10,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
              color: isToday ? AppColors.accent : AppColors.textHint,
            ),
          ),
        ],
      );
    }
    
    final barHeight = (mood / 10.0) * 50 + 10; // 最小10px，最大60px
    
    Color barColor;
    if (mood >= 8.0) {
      barColor = const Color(0xFF4CAF50); // 绿色 - 很好
    } else if (mood >= 6.0) {
      barColor = const Color(0xFF8BC34A); // 浅绿 - 好
    } else if (mood >= 4.0) {
      barColor = const Color(0xFFFFB74D); // 橙色 - 一般
    } else if (mood >= 2.0) {
      barColor = const Color(0xFFFF8A65); // 橙红 - 不好
    } else {
      barColor = const Color(0xFFE57373); // 红色 - 很差
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 柱子
        Container(
          width: 24,
          height: barHeight,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 8),
        // 日期标签
        Text(
          data['dayLabel'],
          style: TextStyle(
            fontSize: 10,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
            color: isToday ? AppColors.accent : AppColors.textHint,
          ),
        ),
      ],
    );
  }

  // 构建统计项
  Widget _buildStatItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }

  void _onItemTap(Map<String, dynamic> item) {
    if (item['type'] == 'quote') {
      // 显示完整语录
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.format_quote,
                color: AppColors.accent,
                size: 40,
              ),
              const SizedBox(height: 16),
              Text(
                item['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (item['author'] != null) ...[
                const SizedBox(height: 12),
                Text(
                  '— ${item['author']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '关闭',
                style: TextStyle(color: AppColors.accent),
              ),
            ),
          ],
        ),
      );
    } else {
      // 音频类型的处理 - 使用全局播放服务
      final allRecommendations = _dataService.getAllRecommendations();
      PlayerService().playTrack(item, playlist: allRecommendations);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            const Text(
              AppStrings.homeTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 今日情绪打卡
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.moodCheckIn,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 心情选择器
                  MoodSelector(
                    selectedMood: _selectedMood,
                    onMoodChanged: _onMoodChanged,
                    onMoodContentChanged: _onMoodContentChanged,
                  ),
                  const SizedBox(height: 16),
                  
                  // 文字输入
                  TextField(
                    controller: _moodNoteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: AppStrings.moodInputHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.accent),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 提交按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _submitMoodRecord,
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: const Text(
                          AppStrings.submit,
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // AI 情绪陪伴
            CustomCard(
              onTap: _navigateToAIChat,
              child: Row(
                children: [
                  // 左侧图标
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 2),
                    ),
                    child: const Icon(
                      Icons.smart_toy,
                      size: 36,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // 右侧内容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.aiCompanion,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          AppStrings.aiDescription,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // 开始聊天按钮
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _navigateToAIChat,
                            icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                            label: const Text(
                              AppStrings.startChat,
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 今日推荐
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.dailyRecommendation,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RecommendationsScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '查看更多',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildRecommendations(),
            const SizedBox(height: 16),

            // 最近7天心情指数
            _buildWeeklyMoodCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    final recommendations = _dataService.getRecommendations();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4, // 固定显示4个推荐卡片
      itemBuilder: (context, index) {
        // 如果推荐数据不足4个，循环使用现有数据
        final item = recommendations[index % recommendations.length];
        
        if (item['type'] == 'quote') {
          return CustomCard(
            onTap: () => _onItemTap(item),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.format_quote,
                  color: AppColors.accent,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '— ${item['author']}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          );
        } else {
          // 处理音频类型（meditation, breathing, whitenoise）
          IconData iconData;
          switch (item['type']) {
            case 'meditation':
              iconData = Icons.self_improvement;
              break;
            case 'breathing':
              iconData = Icons.air;
              break;
            case 'whitenoise':
              iconData = Icons.waves;
              break;
            default:
              iconData = Icons.play_arrow;
          }
          
          return CustomCard(
            onTap: () => _onItemTap(item),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    iconData,
                    color: AppColors.accent,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item['duration'],
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

 