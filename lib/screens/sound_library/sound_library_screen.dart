import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/data_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                      return _buildWhiteNoiseCard(_whiteNoiseAudios[index]);
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
                  ...(_meditationAudios.map((audio) => _buildAudioItem(audio))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 当前播放
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.currentPlaying,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCurrentPlayer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioItem(AudioItem audio) {
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
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.music_note, color: AppColors.accent),
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
            onPressed: () {
              // TODO: 播放音频
            },
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

  Widget _buildWhiteNoiseCard(AudioItem audio) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.waves, color: AppColors.accent, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            audio.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlayer() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.music_note, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '正念呼吸',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '寻找内心平静',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.favorite_border, color: AppColors.accent),
            const SizedBox(width: 8),
            const Icon(Icons.play_circle_fill, color: AppColors.accent, size: 36),
          ],
        ),
        const SizedBox(height: 16),
        
        // 进度条
        Column(
          children: [
            LinearProgressIndicator(
              value: 0.6,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0:30', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                Text('15:00', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 定时关闭按钮
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: 设置定时关闭
            },
            icon: const Icon(Icons.timer, color: AppColors.textPrimary),
            label: const Text(
              AppStrings.timer,
              style: TextStyle(color: AppColors.textPrimary),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
} 