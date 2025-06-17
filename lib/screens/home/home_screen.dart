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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedMood = 3;
  final TextEditingController _moodNoteController = TextEditingController();
  late DataService _dataService;
  late StorageService _storageService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _dataService = DataService.getInstance();
    _storageService = await StorageService.getInstance();
    
    // 初始化时自动填充默认心情(3-一般)的内容
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
      _selectedMood = 3;
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
      case 1: return '😢';
      case 2: return '😔';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '😊';
      default: return '😐';
    }
  }

  String _getDefaultMoodContent() {
    // 默认心情(3-一般)的内容
    return '今天感觉平平常常，没有特别的起伏，就是普通的一天，希望明天会更好。';
  }

  void _navigateToAIChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AIChatScreen(),
      ),
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

 