import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/data_service.dart';
import '../../services/player_service.dart';
import '../../models/audio_item.dart';
import '../../widgets/common/custom_card.dart';

class SoundLibraryScreen extends StatefulWidget {
  const SoundLibraryScreen({super.key});

  @override
  State<SoundLibraryScreen> createState() => _SoundLibraryScreenState();
}

class _SoundLibraryScreenState extends State<SoundLibraryScreen> {
  late DataService _dataService;
  List<AudioItem> _meditationAudios = [];
  List<AudioItem> _whiteNoiseAudios = [];

  @override
  void initState() {
    super.initState();
    _dataService = DataService.getInstance();
    _loadAudioData();
  }

  void _loadAudioData() {
    setState(() {
      _meditationAudios = _dataService.getAudioItems(type: AudioType.meditation);
      _whiteNoiseAudios = _dataService.getAudioItems(type: AudioType.whiteNoise);
    });
  }

  // 将AudioItem转换为PlayerService期望的格式
  Map<String, dynamic> _audioItemToTrack(AudioItem audio) {
    String type;
    switch (audio.type) {
      case AudioType.meditation:
        type = 'meditation';
        break;
      case AudioType.whiteNoise:
        type = 'whitenoise';
        break;
    }

    return {
      'type': type,
      'title': audio.title,
      'duration': audio.formattedDuration,
      'description': audio.description,
      'audioId': audio.id,
    };
  }

  // 播放音频
  void _playAudio(AudioItem audio) {
    final track = _audioItemToTrack(audio);
    
    // 创建播放列表：包含所有冥想音频和白噪音
    final allAudios = [..._meditationAudios, ..._whiteNoiseAudios];
    final playlist = allAudios.map((item) => _audioItemToTrack(item)).toList();
    
    PlayerService().playTrack(track, playlist: playlist);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: ListenableBuilder(
        listenable: PlayerService(),
        builder: (context, _) {
          final playerService = PlayerService();
          
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: playerService.isPlayerVisible ? 100 : 16, // 为悬浮播放器留出空间
            ),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            const Text(
              AppStrings.soundLibraryTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 白噪音
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.whiteNoise,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _whiteNoiseAudios.length,
                    itemBuilder: (context, index) {
                      return _buildWhiteNoiseCard(_whiteNoiseAudios[index], index);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 冥想音引导
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.meditation,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...(_meditationAudios.asMap().entries.map((entry) => _buildAudioItem(entry.value, entry.key))),
                ],
              ),
            ),
          ],
        ),
      );
    },
    ),
    );
  }

  Widget _buildAudioItem(AudioItem audio, int index) {
    // 根据索引获取mx背景图片路径，循环使用5张图片
    final backgroundImage = 'assets/images/backgrounds/mx_${(index % 5) + 1}.jpeg';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  audio.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${audio.formattedDuration} · ${audio.category}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _playAudio(audio),
            icon: const Icon(
              Icons.play_circle_fill,
              size: 36,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildWhiteNoiseCard(AudioItem audio, int index) {
    // 根据索引获取背景图片路径
    final backgroundImage = 'assets/images/backgrounds/bzy_bg${index + 1}.jpeg';
    
    // 根据音频标题获取对应图标
    IconData getSceneIcon(String title) {
      switch (title) {
        case '雨声':
          return Icons.grain; // 雨滴图标
        case '海浪':
          return Icons.waves; // 海浪图标
        case '咖啡馆':
          return Icons.local_cafe; // 咖啡图标
        case '心跳':
          return Icons.favorite; // 心形图标
        case '篝火':
          return Icons.local_fire_department; // 火焰图标
        case '森林':
          return Icons.park; // 公园/树木图标
        default:
          return Icons.music_note; // 默认音乐图标
      }
    }
    
    return GestureDetector(
      onTap: () => _playAudio(audio),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            // 添加更深的半透明遮罩以确保文字可读性
            color: Colors.black.withOpacity(0.4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  getSceneIcon(audio.title),
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                audio.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700, // 加粗字体
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black87, // 更深的阴影
                    ),
                    Shadow(
                      offset: Offset(1, 0),
                      blurRadius: 3,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


} 