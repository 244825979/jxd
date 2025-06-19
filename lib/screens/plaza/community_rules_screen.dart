import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';

class CommunityRulesScreen extends StatelessWidget {
  const CommunityRulesScreen({super.key});

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
          '社区公约',
          style: TextStyle(
            color: AppColors.textPrimary,
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
            // 欢迎语
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: AppColors.accent,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '欢迎来到我们的温暖社区',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '为了营造一个安全、友善、互助的社区环境，让每一位用户都能在这里找到温暖和支持，我们制定了以下社区公约。请您仔细阅读并遵守这些规则。',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 基本原则
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '基本原则',
                        style: TextStyle(
                          color: Colors.amber.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPrincipleItem('💝', '互相尊重', '尊重每一位用户的感受和观点，用温暖的话语交流'),
                  _buildPrincipleItem('🤝', '友善互助', '主动帮助需要支持的用户，传递正能量'),
                  _buildPrincipleItem('🛡️', '保护隐私', '尊重他人隐私，不恶意传播个人信息'),
                  _buildPrincipleItem('🌱', '积极向上', '分享正面内容，营造健康的交流氛围'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 行为准则
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.rule,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '行为准则',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRuleSection(
                    '✅ 我们鼓励',
                    Colors.green,
                    [
                      '分享真实的情感和体验',
                      '给予他人温暖的关怀和支持',
                      '分享有益的心理健康知识',
                      '积极参与社区互动活动',
                      '为他人提供情感支持和建议',
                      '分享正能量的生活感悟',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildRuleSection(
                    '❌ 我们禁止',
                    Colors.red,
                    [
                      '发布有害、歧视性或仇恨言论',
                      '恶意攻击、骚扰或威胁他人',
                      '传播虚假信息或谣言',
                      '发布色情、暴力或不当内容',
                      '恶意刷屏或发送垃圾信息',
                      '侵犯他人隐私或版权',
                      '进行商业推广或诈骗活动',
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 处理机制
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: Colors.orange.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '违规处理',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPenaltyItem('1️⃣', '首次违规', '友善提醒，删除违规内容'),
                        _buildPenaltyItem('2️⃣', '再次违规', '警告处理，限制部分功能'),
                        _buildPenaltyItem('3️⃣', '严重违规', '暂时封禁账号（1-7天）'),
                        _buildPenaltyItem('⛔', '恶劣行为', '永久封禁账号'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),



            // 结语
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.handshake,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '共同维护',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '社区的温暖需要我们每个人的努力。让我们携手创造一个充满关爱、理解和支持的美好空间，让每一个人都能在这里找到心灵的慰藉和成长的力量。',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: AppColors.accent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '感谢您的理解与配合，祝您在社区中度过美好时光！',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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

            // 最后更新时间
            Center(
              child: Text(
                '最后更新：2024年12月',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrincipleItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleSection(String title, MaterialColor color, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color.shade700,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  color: color.shade600,
                  fontSize: 12,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildPenaltyItem(String step, String level, String action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                    text: '$level：',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: action),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


} 