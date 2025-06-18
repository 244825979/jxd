import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';

class PublishAudioScreen extends StatefulWidget {
  const PublishAudioScreen({super.key});

  @override
  State<PublishAudioScreen> createState() => _PublishAudioScreenState();
}

class _PublishAudioScreenState extends State<PublishAudioScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  File? _selectedImage;
  File? _selectedAudioFile;
  String _selectedType = '白噪音';
  
  final List<String> _audioTypes = ['白噪音', '冥想', '其他'];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // 选择音频文件（模拟实现）
  Future<void> _pickAudioFile() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '选择音频文件',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '这里将打开文件管理器选择MP3文件',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '支持格式：MP3\n最大大小：50MB',
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '取消',
              style: TextStyle(color: AppColors.textHint),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // 模拟选择了一个文件
              setState(() {
                _selectedAudioFile = File('mock_selected_audio.mp3');
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('模拟选择了音频文件'),
                  backgroundColor: AppColors.accent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '选择文件',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // 发布音频
  void _publishAudio() {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar('请输入音频标题');
      return;
    }
    
    if (_contentController.text.trim().isEmpty) {
      _showErrorSnackBar('请输入音频描述');
      return;
    }
    
    if (_selectedAudioFile == null) {
      _showErrorSnackBar('请选择音频文件');
      return;
    }

    // 创建音频数据
    final audioData = {
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'type': _selectedType,
      'image': _selectedImage?.path,
      'audioFile': _selectedAudioFile?.path,
      'createdAt': DateTime.now(),
    };

    // 返回数据给上一页
    Navigator.of(context).pop(audioData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '发布音频',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _publishAudio,
            child: const Text(
              '发布',
              style: TextStyle(
                color: AppColors.accent,
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
          children: [
            // 图片选择区域
            _buildImageSection(),
            const SizedBox(height: 16),
            // 标题输入
            _buildTitleSection(),
            const SizedBox(height: 16),
            // 内容输入
            _buildContentSection(),
            const SizedBox(height: 16),
            // MP3文件选择
            _buildAudioFileSection(),
            const SizedBox(height: 16),
            // 类型选择
            _buildTypeSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '封面图片',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  _selectedImage = File(image.path);
                });
              }
            },
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.accent),
                        const SizedBox(height: 8),
                        const Text('点击选择封面图片', style: TextStyle(color: AppColors.accent)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '音频标题',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: '请输入音频标题',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '音频描述',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            style: const TextStyle(color: AppColors.textPrimary),
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: '请输入音频描述内容',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioFileSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MP3文件',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickAudioFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedAudioFile != null ? AppColors.accent.withOpacity(0.1) : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selectedAudioFile != null ? AppColors.accent : AppColors.divider),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedAudioFile != null ? Icons.audio_file : Icons.upload_file,
                    color: _selectedAudioFile != null ? AppColors.accent : AppColors.textHint,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedAudioFile != null ? '已选择音频文件' : '点击选择MP3文件',
                          style: TextStyle(
                            color: _selectedAudioFile != null ? AppColors.accent : AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_selectedAudioFile != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _selectedAudioFile!.path.split('/').last,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 4),
                          const Text(
                            '支持 MP3 格式，最大 50MB',
                            style: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '音频类型',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: _audioTypes.map((type) {
              final isSelected = _selectedType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? AppColors.accent : AppColors.divider),
                    ),
                    child: Text(
                      type,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
} 