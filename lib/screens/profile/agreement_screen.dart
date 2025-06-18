import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/custom_card.dart';

class AgreementScreen extends StatefulWidget {
  const AgreementScreen({super.key});

  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '我的协议',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(23),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(2),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.accent,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(
                  child: Text('用户协议'),
                ),
                Tab(
                  child: Text('隐私协议'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserAgreement(),
          _buildPrivacyAgreement(),
        ],
      ),
    );
  }

  // 构建用户协议内容
  Widget _buildUserAgreement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            const Text(
              '静心岛用户协议',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '最后更新日期：2024年12月',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 20),

            // 欢迎语
            _buildSection(
              '欢迎使用静心岛',
              '感谢您选择静心岛App。我们致力于为用户提供一个温暖、安全的心理健康服务平台。请您仔细阅读以下条款，您的使用行为将视为对本协议的接受。',
            ),

            // 服务内容
            _buildSection(
              '1. 服务内容',
              '静心岛为用户提供以下服务：\n• 冥想引导音频\n• 白噪音放松音频\n• 心情记录与分享\n• 情感支持社区\n• AI智能陪伴\n• 个人情绪分析',
            ),

            // 用户行为规范
            _buildSection(
              '2. 用户行为规范',
              '为维护良好的社区环境，用户承诺：\n• 不发布违法违规内容\n• 不传播色情、暴力、恐怖信息\n• 不进行人身攻击或恶意骚扰\n• 尊重他人隐私和感受\n• 不恶意刷屏或发布垃圾信息',
            ),

            // 账号管理
            _buildSection(
              '3. 账号管理',
              '• 一个用户只能拥有一个账号\n• 用户有义务保护账号安全\n• 禁止买卖、转让账号\n• 长期不使用的账号可能被回收\n• 违规账号将被限制或封禁',
            ),

            // 知识产权
            _buildSection(
              '4. 知识产权',
              '静心岛App的所有内容，包括但不限于文字、图片、音频、视频、软件等，均受知识产权法保护。未经授权，不得复制、传播或用于商业用途。',
            ),

            // 免责声明
            _buildSection(
              '5. 免责声明',
              '• 静心岛提供的内容仅供参考，不能替代专业医疗建议\n• 如有严重心理问题，请及时寻求专业帮助\n• 我们不对用户使用服务产生的任何后果承担责任\n• 因不可抗力导致的服务中断不承担责任',
            ),

            // 协议变更
            _buildSection(
              '6. 协议变更',
              '我们保留随时修改本协议的权利。重大变更将通过App内通知等方式告知用户。继续使用服务将视为接受新协议。',
            ),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '感谢您的信任与支持，静心岛将竭诚为您服务',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
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
    );
  }

  // 构建隐私协议内容
  Widget _buildPrivacyAgreement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            const Text(
              '静心岛隐私保护协议',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '最后更新日期：2024年12月',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 20),

            // 隐私承诺
            _buildSection(
              '我们的隐私承诺',
              '静心岛深知隐私保护的重要性，特别是在心理健康领域。我们承诺严格保护您的个人信息，绝不泄露您的隐私数据。',
            ),

            // 信息收集
            _buildSection(
              '1. 信息收集',
              '我们可能收集以下信息：\n• 基本信息：昵称、头像（匿名化处理）\n• 使用数据：App使用时长、功能偏好\n• 心情记录：您主动分享的情感状态\n• 设备信息：设备型号、操作系统版本\n• 日志信息：错误日志、性能数据',
            ),

            // 信息使用
            _buildSection(
              '2. 信息使用',
              '我们使用收集的信息用于：\n• 提供个性化服务推荐\n• 改进App功能和用户体验\n• 分析用户行为，优化产品设计\n• 防范安全风险和违规行为\n• 遵守法律法规要求',
            ),

            // 信息保护
            _buildSection(
              '3. 信息保护',
              '我们采取多重措施保护您的信息：\n• 数据加密传输和存储\n• 严格的员工权限管理\n• 定期安全审计和漏洞修复\n• 匿名化处理敏感数据\n• 数据备份和容灾机制',
            ),

            // 信息共享
            _buildSection(
              '4. 信息共享',
              '我们承诺：\n• 绝不出售您的个人信息\n• 不与第三方共享您的隐私数据\n• 仅在法律要求或用户同意下披露信息\n• 合作伙伴仅能获得必要的匿名统计数据',
            ),

            // 用户权利
            _buildSection(
              '5. 您的权利',
              '您享有以下权利：\n• 查看和修改个人信息\n• 删除个人账户和数据\n• 拒绝接收推广信息\n• 撤回授权同意\n• 投诉和举报隐私违规行为',
            ),

            // Cookie政策
            _buildSection(
              '6. Cookie和追踪技术',
              '我们使用Cookie等技术：\n• 记住您的登录状态\n• 提供个性化体验\n• 分析App使用情况\n• 您可以在设置中管理Cookie偏好',
            ),

            // 儿童隐私
            _buildSection(
              '7. 儿童隐私保护',
              '我们特别重视儿童隐私保护：\n• 不主动收集14岁以下儿童信息\n• 如发现儿童信息将立即删除\n• 建议未成年人在监护人指导下使用',
            ),

            // 跨境传输
            _buildSection(
              '8. 数据存储',
              '您的个人信息将存储在中国境内的安全服务器中。如需跨境传输，我们将严格遵守相关法律法规。',
            ),

            const SizedBox(height: 20),
            Container(
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
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '您的隐私安全是我们的首要责任',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 14,
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
    );
  }

  // 构建章节内容
  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
} 