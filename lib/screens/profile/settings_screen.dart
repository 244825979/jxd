import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../../services/storage_service.dart';
import '../../services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late StorageService _storageService;
  late PermissionService _permissionService;
  
  // 设置项状态
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _loopPlayAudio = false;
  bool _dataOptimization = true;
  String _selectedLanguage = '简体中文';
  String _selectedFontSize = '标准';
  
  // 权限状态
  Map<String, PermissionStatus> _permissionStatuses = {};
  
  final List<String> _languages = ['简体中文'];
  final List<String> _fontSizes = ['标准'];

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    _storageService = await StorageService.getInstance();
    _permissionService = await PermissionService.getInstance();
    await _loadSettings();
    await _loadPermissionStatuses();
  }

  Future<void> _loadSettings() async {
    final notificationsEnabled = await _storageService.getBool('notifications_enabled', defaultValue: true);
    final soundEnabled = await _storageService.getBool('sound_enabled', defaultValue: true);
    final loopPlayAudio = await _storageService.getBool('loop_play_audio', defaultValue: false);
    final dataOptimization = await _storageService.getBool('data_optimization', defaultValue: true);
    final selectedLanguage = await _storageService.getString('selected_language') ?? '简体中文';
    final selectedFontSize = await _storageService.getString('selected_font_size') ?? '标准';
    
    setState(() {
      _notificationsEnabled = notificationsEnabled;
      _soundEnabled = soundEnabled;
      _loopPlayAudio = loopPlayAudio;
      _dataOptimization = dataOptimization;
      _selectedLanguage = selectedLanguage;
      _selectedFontSize = selectedFontSize;
    });
  }

  Future<void> _loadPermissionStatuses() async {
    final statuses = await _permissionService.checkAllMediaPermissions();
    setState(() {
      _permissionStatuses = statuses;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    if (value is bool) {
      await _storageService.saveBool(key, value);
    } else if (value is String) {
      await _storageService.saveString(key, value);
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                '选择语言',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
            ...(_languages.map((language) => ListTile(
              title: Text(
                language,
                style: TextStyle(
                  color: _selectedLanguage == language 
                      ? const Color(0xFF4CAF50) 
                      : const Color(0xFF2C3E50),
                  fontWeight: _selectedLanguage == language 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                ),
              ),
              trailing: _selectedLanguage == language
                  ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = language;
                });
                _saveSetting('selected_language', language);
                Navigator.pop(context);
              },
            ))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showFontSizeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                '选择字体大小',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
            ...(_fontSizes.map((fontSize) => ListTile(
              title: Text(
                fontSize,
                style: TextStyle(
                  color: _selectedFontSize == fontSize 
                      ? const Color(0xFF2196F3) 
                      : const Color(0xFF2C3E50),
                  fontWeight: _selectedFontSize == fontSize 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                  fontSize: _getFontSizeValue(fontSize),
                ),
              ),
              trailing: _selectedFontSize == fontSize
                  ? const Icon(Icons.check, color: Color(0xFF2196F3))
                  : null,
              onTap: () {
                setState(() {
                  _selectedFontSize = fontSize;
                });
                _saveSetting('selected_font_size', fontSize);
                Navigator.pop(context);
              },
            ))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  double _getFontSizeValue(String size) {
    switch (size) {
      case '小':
        return 12.0;
      case '标准':
        return 16.0;
      case '大':
        return 18.0;
      case '特大':
        return 20.0;
      default:
        return 16.0;
    }
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '清理缓存',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        content: const Text(
          '确定要清理应用缓存吗？这将删除临时文件，但不会影响您的个人数据。',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF7F8C8D),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '取消',
              style: TextStyle(color: Color(0xFF7F8C8D)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('缓存清理完成'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '确定',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
          '我的设置',
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
            // 通知设置
            _buildSectionTitle('通知设置'),
            CustomCard(
              child: Column(
                children: [
                  _buildSwitchItem(
                    '推送通知',
                    '接收应用推送消息',
                    Icons.notifications_outlined,
                    const Color(0xFFFF9800),
                    _notificationsEnabled,
                    (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _saveSetting('notifications_enabled', value);
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchItem(
                    '声音提醒',
                    '消息提醒声音',
                    Icons.volume_up_outlined,
                    const Color(0xFF9C27B0),
                    _soundEnabled,
                    (value) {
                      setState(() {
                        _soundEnabled = value;
                      });
                      _saveSetting('sound_enabled', value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 显示设置
            _buildSectionTitle('显示设置'),
            CustomCard(
              child: Column(
                children: [
                  _buildSelectItem(
                    '字体大小',
                    _selectedFontSize,
                    Icons.text_fields,
                    const Color(0xFF2196F3),
                    _showFontSizeSelector,
                  ),
                  _buildDivider(),
                  _buildSelectItem(
                    '语言设置',
                    _selectedLanguage,
                    Icons.language,
                    const Color(0xFF4CAF50),
                    _showLanguageSelector,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 应用设置
            _buildSectionTitle('应用设置'),
            CustomCard(
              child: Column(
                children: [
                  _buildSwitchItem(
                    '循环播放音频',
                    '音频播放完毕后循环',
                    Icons.repeat,
                    const Color(0xFFE91E63),
                    _loopPlayAudio,
                    (value) {
                      setState(() {
                        _loopPlayAudio = value;
                      });
                      _saveSetting('loop_play_audio', value);
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchItem(
                    '数据节省模式',
                    '减少流量消耗',
                    Icons.data_usage,
                    const Color(0xFF00BCD4),
                    _dataOptimization,
                    (value) {
                      setState(() {
                        _dataOptimization = value;
                      });
                      _saveSetting('data_optimization', value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 权限管理
            _buildSectionTitle('权限管理'),
            CustomCard(
              child: Column(
                children: [
                  _buildPermissionItem(
                    '相册权限',
                    '选择和保存心情照片',
                    Icons.photo_library_outlined,
                    const Color(0xFF9C27B0),
                    _permissionStatuses['photos'] ?? PermissionStatus.denied,
                    () async {
                      await _requestSinglePermission('photos');
                    },
                  ),
                  _buildDivider(),
                  _buildPermissionItem(
                    '摄像头权限',
                    '拍摄心情瞬间',
                    Icons.camera_alt_outlined,
                    const Color(0xFF2196F3),
                    _permissionStatuses['camera'] ?? PermissionStatus.denied,
                    () async {
                      await _requestSinglePermission('camera');
                    },
                  ),
                  _buildDivider(),
                  _buildPermissionItem(
                    '麦克风权限',
                    '录制语音日记',
                    Icons.mic_outlined,
                    const Color(0xFFFF5722),
                    _permissionStatuses['microphone'] ?? PermissionStatus.denied,
                    () async {
                      await _requestSinglePermission('microphone');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 存储管理
            _buildSectionTitle('存储管理'),
            CustomCard(
              child: Column(
                children: [
                  _buildActionItem(
                    '清理缓存',
                    '清理应用临时文件',
                    Icons.cleaning_services_outlined,
                    const Color(0xFFFF5722),
                    _showClearCacheDialog,
                  ),
                  _buildDivider(),
                  _buildActionItem(
                    '存储详情',
                    '查看应用存储占用',
                    Icons.storage_outlined,
                    const Color(0xFF795548),
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('存储占用：约 45.2 MB'),
                          backgroundColor: Color(0xFF607D8B),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 底部提示
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
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF3498DB),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '设置将自动保存，部分设置需要重启应用后生效。',
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: iconColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectItem(
    String title,
    String value,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 1,
      color: const Color(0xFFECF0F1),
    );
  }

  Future<void> _requestSinglePermission(String permission) async {
    bool result = false;
    
    switch (permission) {
      case 'photos':
        result = await _permissionService.requestPhotoLibraryPermission();
        if (!result) {
          await _permissionService.showPermissionSettingsDialog(context, '相册');
        }
        break;
      case 'camera':
        result = await _permissionService.requestCameraPermission();
        if (!result) {
          await _permissionService.showPermissionSettingsDialog(context, '摄像头');
        }
        break;
      case 'microphone':
        result = await _permissionService.requestMicrophonePermission();
        if (!result) {
          await _permissionService.showPermissionSettingsDialog(context, '麦克风');
        }
        break;
    }
    
    // 刷新权限状态
    await _loadPermissionStatuses();
    
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${permission == 'photos' ? '相册' : permission == 'camera' ? '摄像头' : '麦克风'}权限已授予'),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    }
  }

  Widget _buildPermissionItem(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    PermissionStatus status,
    VoidCallback onTap,
  ) {
    Color statusColor;
    String statusText;
    
    switch (status) {
      case PermissionStatus.granted:
        statusColor = const Color(0xFF4CAF50);
        statusText = '已授权';
        break;
      case PermissionStatus.denied:
        statusColor = const Color(0xFFFF5722);
        statusText = '被拒绝';
        break;
      case PermissionStatus.restricted:
        statusColor = const Color(0xFFFF9800);
        statusText = '受限制';
        break;
      case PermissionStatus.limited:
        statusColor = const Color(0xFF2196F3);
        statusText = '部分授权';
        break;
      case PermissionStatus.permanentlyDenied:
        statusColor = const Color(0xFF9E9E9E);
        statusText = '永久拒绝';
        break;
      default:
        statusColor = const Color(0xFF9E9E9E);
        statusText = '未知';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
} 