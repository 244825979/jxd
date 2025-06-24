import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/data_service.dart';
import '../../services/apple_auth_service.dart';
import '../../widgets/common/ai_avatar.dart';
import '../../widgets/common/user_avatar.dart';
import '../../models/user.dart';
import '../profile/account_management_screen.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late DataService _dataService;
  late AppleAuthService _authService;
  late User _currentUser;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _dataService = DataService.getInstance();
    _authService = AppleAuthService();
    _currentUser = _dataService.getCurrentUser();
    _messages = _dataService.getAIMessages();
    
    // 检查登录状态
    _checkLoginStatus();
    
    // 监听输入框变化，用于更新发送按钮状态
    _messageController.addListener(() {
      setState(() {});
    });
  }

  // 检查登录状态
  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
      });
      
      if (isLoggedIn) {
        // 登录状态：恢复本地数据
        await _dataService.restoreUserDataOnLogin();
        _currentUser = _dataService.getCurrentUser();
      } else {
        // 未登录状态：重置为游客状态
        _dataService.resetUserData();
        _currentUser = _dataService.getCurrentUser();
      }
      
      // 触发UI刷新
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // 检查登录状态
    if (!_isLoggedIn) {
      _showLoginDialog();
      return;
    }

    // 检查是否需要消耗金币（非VIP用户）
    if (!_currentUser.isVip) {
      if (_currentUser.coins < 1) {
        _showInsufficientCoinsDialog();
        return;
      }
    }

    _messageController.clear();
    
    // 非VIP用户消耗1金币
    if (!_currentUser.isVip) {
      _dataService.updateUserCoins(_currentUser.coins - 1);
      _currentUser = _dataService.getCurrentUser();
    }
    
    // 添加用户消息
    setState(() {
      _messages.add({
        'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'isAI': false,
        'content': text,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _scrollToBottom();

    // 获取AI回复
    try {
      final aiResponse = await _dataService.getAIResponse(text);
      setState(() {
        _messages.add({
          'id': 'ai_${DateTime.now().millisecondsSinceEpoch}',
          'isAI': true,
          'content': aiResponse,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 显示登录对话框
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('需要登录'),
          content: const Text('请先登录后再与情感助手对话'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountManagementScreen(),
                  ),
                ).then((_) => _checkLoginStatus()); // 登录后重新检查状态
              },
              child: const Text('去登录'),
            ),
          ],
        );
      },
    );
  }

  // 显示金币不足对话框
  void _showInsufficientCoinsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('金币不足'),
          content: const Text('发送消息需要消耗1金币，您的金币不足。\n\n• 充值金币\n• 开通VIP会员免费使用'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('稍后再说'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountManagementScreen(),
                  ),
                ).then((_) => _checkLoginStatus()); // 充值后重新检查状态
              },
              child: const Text('去充值'),
            ),
          ],
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime? timestamp) {
    if (timestamp == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        title: Row(
          children: [
            const AIAvatar(
              size: 40,
              backgroundColor: AppColors.accent,
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.aiChat,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '与AI助手分享你的情感世界',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildLoadingBubble();
                }
                
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isAI = message['isAI'] as bool;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAI) ...[
            const AIAvatar(
              size: 36,
              backgroundColor: AppColors.accent,
              iconSize: 18,
            ),
            const SizedBox(width: 12),
          ] else ...[
            const SizedBox(width: 48), // 为右对齐留出空间
          ],
          
          Expanded(
            child: Column(
              crossAxisAlignment: isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isAI ? AppColors.cardBackground : AppColors.accent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isAI ? 4 : 20),
                      topRight: Radius.circular(isAI ? 20 : 4),
                      bottomLeft: const Radius.circular(20),
                      bottomRight: const Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message['content'],
                    style: TextStyle(
                      color: isAI ? AppColors.textPrimary : Colors.white,
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    _formatTime(message['timestamp']),
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (!isAI) ...[
            const SizedBox(width: 12),
            UserAvatar(
              avatarPath: _currentUser.avatar,
              size: 36,
            ),
          ] else ...[
            const SizedBox(width: 48), // 为左对齐留出空间
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AIAvatar(
            size: 36,
            backgroundColor: AppColors.accent,
            iconSize: 18,
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '助手正在思考...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48), // 为左对齐留出空间
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    // 根据登录状态和会员状态确定提示文本
    String getHintText() {
      if (!_isLoggedIn) {
        return '请先登录后再与助手对话';
      } else if (_currentUser.isVip) {
        return '分享你此刻的想法... (VIP会员免费)';
      } else {
        return '分享你此刻的想法... (消耗1金币/条)';
      }
    }

    // 确定输入框是否可用
    bool isInputEnabled = _isLoggedIn && (_currentUser.isVip || _currentUser.coins >= 1);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          top: BorderSide(color: AppColors.divider.withOpacity(0.3)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 状态提示条
            if (!_isLoggedIn || (!_currentUser.isVip && _currentUser.coins < 1))
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: !_isLoggedIn 
                      ? AppColors.accent.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: !_isLoggedIn 
                        ? AppColors.accent.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      !_isLoggedIn ? Icons.login : Icons.monetization_on_outlined,
                      size: 16,
                      color: !_isLoggedIn ? AppColors.accent : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        !_isLoggedIn 
                            ? '请先登录后使用情感助手'
                            : '金币不足，请充值金币或开通VIP会员',
                        style: TextStyle(
                          fontSize: 12,
                          color: !_isLoggedIn ? AppColors.accent : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountManagementScreen(),
                          ),
                        ).then((_) => _checkLoginStatus());
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        !_isLoggedIn ? '去登录' : '去充值',
                        style: TextStyle(
                          fontSize: 12,
                          color: !_isLoggedIn ? AppColors.accent : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // 输入区域
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isInputEnabled ? AppColors.primary : AppColors.divider.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.divider.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      enabled: isInputEnabled,
                      maxLines: null,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: getHintText(),
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.6),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 12,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: isInputEnabled ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                      onSubmitted: (_) => isInputEnabled ? _sendMessage() : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: (isInputEnabled && _messageController.text.trim().isNotEmpty) 
                        ? AppColors.accent 
                        : AppColors.textSecondary.withOpacity(0.3),
                    shape: BoxShape.circle,
                    boxShadow: (isInputEnabled && _messageController.text.trim().isNotEmpty) ? [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: IconButton(
                    onPressed: (isInputEnabled && _messageController.text.trim().isNotEmpty) ? _sendMessage : null,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 