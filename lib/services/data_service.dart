import '../models/audio_item.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/notification.dart';
import '../models/user.dart';
import '../models/user_data.dart';
import '../models/report.dart';
import '../models/achievement.dart';
import '../constants/app_images.dart';
import '../models/feedback.dart' as feedback_model;
import 'ai_service.dart';
import 'storage_service.dart';

class DataService {
  static DataService? _instance;
  DataService._();

  static DataService getInstance() {
    if (_instance == null) {
      _instance = DataService._();
      _instance!._initializeCommentsData();
      _instance!._initializeUserData();
    }
    return _instance!;
  }

  // 初始化用户数据，从本地存储加载
  Future<void> _initializeUserData() async {
    try {
      final savedUser = await StorageService.loadUserBackup();
      if (savedUser != null) {
        _currentUser = savedUser;
        print('🔄 已加载本地用户数据: ${savedUser.nickname}, 登录状态: ${savedUser.isLoggedIn}');
      } else {
        // 没有保存的数据，使用默认游客状态
        resetUserData();
        print('🔄 使用默认游客数据');
      }
    } catch (e) {
      print('❌ 加载本地用户数据失败: $e');
      resetUserData();
    }
  }

  // 静态音频数据
  final List<AudioItem> _audioItems = [
    // 冥想音频
    AudioItem(
      id: 'meditation_1',
      title: '正念呼吸：寻找内心平静',
      description: '通过专注呼吸，让心灵回到当下',
      coverImage: 'assets/images/meditation/breathing.jpg',
      audioPath: 'voice/meditation/mingxiang_1.mp3',
      duration: 94, // 1分34秒 (实际播放时长)
      type: AudioType.meditation,
      category: '正念冥想',
    ),
    AudioItem(
      id: 'meditation_2',
      title: '放空睡前：安然入梦',
      description: '睡前冥想，帮助您快速进入深度睡眠',
      coverImage: 'assets/images/meditation/sleep.jpg',
      audioPath: 'voice/meditation/mingxiang_2.mp3',
      duration: 120, // 2分00秒 (实际播放时长)
      type: AudioType.meditation,
      category: '睡眠冥想',
    ),
    AudioItem(
      id: 'meditation_3',
      title: '身心放松冥想',
      description: '快速放松身心的短时冥想',
      coverImage: 'assets/images/meditation/relaxation.jpg',
      audioPath: 'voice/meditation/mingxiang_3.mp3',
      duration: 120, // 2分00秒 (实际播放时长)
      type: AudioType.meditation,
      category: '快速冥想',
    ),
    AudioItem(
      id: 'meditation_4',
      title: '身体扫描冥想',
      description: '通过身体扫描技术，释放身体各部位的紧张',
      coverImage: 'assets/images/meditation/body_scan.jpg',
      audioPath: 'voice/meditation/mingxiang_4.mp3',
      duration: 118, // 1分58秒 (实际播放时长)
      type: AudioType.meditation,
      category: '身体觉知',
    ),
    AudioItem(
      id: 'meditation_5',
      title: '感恩冥想',
      description: '培养感恩之心，感受生活中的美好',
      coverImage: 'assets/images/meditation/gratitude.jpg',
      audioPath: 'voice/meditation/mingxiang_5.mp3',
      duration: 118, // 1分58秒 (实际播放时长)
      type: AudioType.meditation,
      category: '情感疗愈',
    ),
    // 白噪音
    AudioItem(
      id: 'whitenoise_1',
      title: '雨声',
      description: '自然雨声，营造宁静氛围',
      coverImage: 'assets/images/whitenoise/rain.jpg',
      audioPath: 'voice/bzy/rain.mp3',
      duration: 90, // 90秒
      type: AudioType.whiteNoise,
      category: '自然声音',
    ),
    AudioItem(
      id: 'whitenoise_2',
      title: '海浪',
      description: '温柔的海浪声，仿佛置身海边',
      coverImage: 'assets/images/whitenoise/ocean.jpg',
      audioPath: 'voice/bzy/ocean.mp3',
      duration: 90, // 90秒
      type: AudioType.whiteNoise,
      category: '自然声音',
    ),
    AudioItem(
      id: 'whitenoise_3',
      title: '咖啡馆',
      description: '咖啡馆的环境音，专注工作的好伴侣',
      coverImage: 'assets/images/whitenoise/cafe.jpg',
      audioPath: 'voice/bzy/cafe.mp3',
      duration: 90, // 90秒
      type: AudioType.whiteNoise,
      category: '环境声音',
    ),
    AudioItem(
      id: 'whitenoise_4',
      title: '心跳',
      description: '平静的心跳声，回到母体的安全感',
      coverImage: 'assets/images/whitenoise/heartbeat.jpg',
      audioPath: 'voice/bzy/heartbeat.mp3',
      duration: 90, // 90秒
      type: AudioType.whiteNoise,
      category: '生理声音',
    ),
    AudioItem(
      id: 'whitenoise_5',
      title: '篝火',
      description: '温暖的篝火声，营造安全舒适的氛围',
      coverImage: 'assets/images/whitenoise/fire.jpg',
      audioPath: 'voice/bzy/campfire.mp3',
      duration: 90, // 90秒
      type: AudioType.whiteNoise,
      category: '环境声音',
    ),
    AudioItem(
      id: 'whitenoise_6',
      title: '森林',
      description: '清新的森林声音，鸟鸣与风声的自然和谐',
      coverImage: 'assets/images/whitenoise/forest.jpg',
      audioPath: 'voice/bzy/forest.mp3',
      duration: 90, // 90秒
      type: AudioType.whiteNoise,
      category: '自然声音',
    ),
  ];

  // 用户数据实例
  UserData _userData = UserData();

  // 评论数据存储 - 按 postId 分组存储评论
  final Map<String, List<Comment>> _comments = {};

  // 举报数据存储
  final List<Report> _reports = [];

  // 被屏蔽动态ID列表
  final Set<String> _blockedPostIds = {};

  // 成就数据
  List<Achievement> _achievements = [
    Achievement(
      id: 'welcome',
      type: AchievementType.welcome,
      title: '🌟 欢迎来到静心岛',
      subtitle: '首次使用静心岛',
      description: '欢迎来到静心岛！开始您的心灵疗愈之旅吧！',
      icon: '🌟',
      colorHex: '#4CAF50', // green.shade500
      requiredValue: 1,
      unit: '次',
      currentValue: 1, // 默认完成
      isUnlocked: true, // 默认解锁
      unlockedAt: DateTime.now(),
    ),
    Achievement(
      id: 'listener',
      type: AchievementType.listener,
      title: '🎯 倾听者',
      subtitle: '连续7天使用情感助手',
      description: '坚持与AI助手交流7天，展现对内心成长的坚持！',
      icon: '🎯',
      colorHex: '#FFA726', // amber.shade400
      requiredValue: 7,
      unit: '天',
      currentValue: 0, // 从零开始
      isUnlocked: false,
    ),
    Achievement(
      id: 'expresser',
      type: AchievementType.expresser,
      title: '📝 表达者',
      subtitle: '发布10条心情动态',
      description: '勇敢表达自己的想法和感受',
      icon: '📝',
      colorHex: '#42A5F5', // blue.shade400
      requiredValue: 10,
      unit: '条',
      currentValue: 0, // 从零开始
      isUnlocked: false,
    ),
    Achievement(
      id: 'meditator',
      type: AchievementType.meditator,
      title: '🧘‍♀️ 冥想初学者',
      subtitle: '完成30分钟冥想',
      description: '开始冥想练习的第一步',
      icon: '🧘‍♀️',
      colorHex: '#66BB6A', // green.shade400
      requiredValue: 30,
      unit: '分钟',
      currentValue: 0, // 从零开始
      isUnlocked: false,
    ),
    Achievement(
      id: 'supporter',
      type: AchievementType.supporter,
      title: '❤️ 温暖使者',
      subtitle: '获得50个点赞',
      description: '您的分享温暖了许多人的心',
      icon: '❤️',
      colorHex: '#EF5350', // red.shade400
      requiredValue: 50,
      unit: '个',
      currentValue: 0, // 当前用户获得的总点赞数
      isUnlocked: false,
    ),
    Achievement(
      id: 'tracker',
      type: AchievementType.tracker,
      title: '🌱 成长见证者',
      subtitle: '连续21天记录心情',
      description: '坚持记录，见证自己的情感成长',
      icon: '🌱',
      colorHex: '#AB47BC', // purple.shade400
      requiredValue: 21,
      unit: '天',
      currentValue: 0, // 连续记录天数
      isUnlocked: false,
    ),
    Achievement(
      id: 'challenger',
      type: AchievementType.challenger,
      title: '🏃‍♂️ 挑战者',
      subtitle: '参与5个社区挑战',
      description: '积极参与社区活动，挑战自我',
      icon: '🏃‍♂️',
      colorHex: '#FF7043', // deepOrange.shade400
      requiredValue: 5,
      unit: '个',
      currentValue: 1, // 已参与的挑战数
      isUnlocked: false,
    ),
    Achievement(
      id: 'helper',
      type: AchievementType.helper,
      title: '🤝 互助者',
      subtitle: '帮助他人20次',
      description: '通过评论和互动，帮助他人走出困境',
      icon: '🤝',
      colorHex: '#26C6DA', // cyan.shade400
      requiredValue: 20,
      unit: '次',
      currentValue: 0, // 帮助他人的次数
      isUnlocked: false,
    ),
    Achievement(
      id: 'consistent',
      type: AchievementType.consistent,
      title: '⭐ 坚持者',
      subtitle: '连续30天使用应用',
      description: '持续的自我关怀，是最好的成长方式',
      icon: '⭐',
      colorHex: '#FFCA28', // amber.shade600
      requiredValue: 30,
      unit: '天',
      currentValue: 7, // 连续使用天数
      isUnlocked: false,
    ),
  ];

  // 用户行为统计数据
  Map<String, int> _userStats = {
    'aiChatDays': 0,           // AI聊天天数
    'meditationMinutes': 0,    // 冥想总分钟数
    'postsPublished': 0,       // 发布动态数
    'likesReceived': 0,        // 获得点赞数
    'moodRecordDays': 0,       // 心情记录天数
    'challengesJoined': 0,     // 参与挑战数
    'helpActions': 0,          // 帮助他人次数
    'consecutiveDays': 0,      // 连续使用天数
  };

  // 静态帖子数据 - 图片和纯文字动态交错排列
  List<Post> _posts = [
    // 1. 带图片
    Post(
      id: 'post_1',
      content: '今天感觉有点低落，但看到窗外的阳光，还是努力给自己一个微笑。',
      imageUrl: 'assets/images/dongtai/dongtai_1.png',
      tags: ['今日心情'],
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      authorAvatar: 'assets/images/avatars/user_1.png',
      authorName: '阳光小暖',
      likeCount: 12,
      commentCount: 0, // 将被动态设置
    ),
    // 2. 纯文字
    Post(
      id: 'post_2',
      content: '今天想起了一句话："你要做一个不动声色的大人了。不准情绪化，不准偷偷想念，不准回头看。" 但有时候，允许自己脆弱一下，也没关系的。',
      tags: ['情感树洞'],
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      authorAvatar: 'assets/images/avatars/user_2.png',
      authorName: '温柔的风',
      likeCount: 67,
      commentCount: 0, // 将被动态设置
    ),
    // 3. 带图片
    Post(
      id: 'post_3',
      content: '深夜的街道，霓虹灯闪烁，内心却异常平静。这个城市的夜晚总是那么治愈。',
      imageUrl: 'assets/images/dongtai/dongtai_2.png',
      tags: ['来自深夜的我'],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      authorAvatar: 'assets/images/avatars/user_3.png',
      authorName: '夜色温柔',
      likeCount: 28,
      commentCount: 0, // 将被动态设置
    ),
    // 4. 带图片
    Post(
      id: 'post_4',
      content: '春天的第一朵花开了，就像心情突然明亮起来。生活总是在不经意间给我们小惊喜。',
      imageUrl: 'assets/images/dongtai/dongtai_3.png',
      tags: ['温暖时刻'],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      authorAvatar: 'assets/images/avatars/user_4.png',
      authorName: '春暖花开的心',
      likeCount: 45,
      commentCount: 0, // 将被动态设置
    ),
    // 5. 纯文字
    Post(
      id: 'post_5',
      content: '失眠的夜晚，脑海里播放着白天的画面。有些话想说却不知道对谁说，有些情感想表达却找不到合适的方式。',
      tags: ['来自深夜的我'],
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      authorAvatar: 'assets/images/avatars/user_5.png',
      authorName: '深夜听雨人',
      likeCount: 89,
      commentCount: 0, // 将被动态设置
    ),
    // 6. 带图片
    Post(
      id: 'post_6',
      content: '雨后的天空格外清澈，就像洗涤过的心灵。有时候，眼泪过后就是彩虹。',
      imageUrl: 'assets/images/dongtai/dongtai_4.png',
      tags: ['情感树洞'],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      authorAvatar: 'assets/images/avatars/user_6.png',
      authorName: '雨后彩虹',
      likeCount: 32,
      commentCount: 0, // 将被动态设置
    ),
    // 7. 带图片
    Post(
      id: 'post_7',
      content: '咖啡店的午后，阳光透过玻璃窗洒在桌案上。这一刻，时间好像停止了。',
      imageUrl: 'assets/images/dongtai/dongtai_5.png',
      tags: ['孤独瞬间'],
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      authorAvatar: 'assets/images/avatars/user_7.png',
      authorName: '午后咖啡香',
      likeCount: 67,
      commentCount: 0, // 将被动态设置
    ),
    // 8. 纯文字
    Post(
      id: 'post_8',
      content: '学会了冥想之后，感觉世界都安静了。原来内心的平静，不是没有波澜，而是学会了与波澜共处。',
      tags: ['治愈系语录'],
      createdAt: DateTime.now().subtract(const Duration(hours: 7)),
      authorAvatar: 'assets/images/avatars/user_8.png',
      authorName: '静心守望者',
      likeCount: 52,
      commentCount: 0, // 将被动态设置
    ),
    // 9. 带图片
    Post(
      id: 'post_9',
      content: '夜晚的书桌，一盏台灯，一本书。简单的快乐，纯粹的满足。',
      imageUrl: 'assets/images/dongtai/dongtai_6.png',
      tags: ['来自深夜的我'],
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      authorAvatar: 'assets/images/avatars/user_9.png',
      authorName: '灯下读书人',
      likeCount: 19,
      commentCount: 0, // 将被动态设置
    ),
    // 10. 带图片
    Post(
      id: 'post_10',
      content: '海边的日落，橙红色的天空倒映在水面上。大自然总是最好的心理医生。',
      imageUrl: 'assets/images/dongtai/dongtai_7.png',
      tags: ['治愈系语录'],
      createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      authorAvatar: 'assets/images/avatars/user_10.png',
      authorName: '海边拾贝者',
      likeCount: 89,
      commentCount: 0, // 将被动态设置
    ),
    // 11. 纯文字
    Post(
      id: 'post_11',
      content: '压力山大的一周终于结束了。虽然很累，但也收获了很多。成长的路上，每一步都算数。',
      tags: ['今日心情'],
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      authorAvatar: 'assets/images/avatars/user_11.png',
      authorName: '成长路上的我',
      likeCount: 34,
      commentCount: 0, // 将被动态设置
    ),
    // 12. 带图片
    Post(
      id: 'post_12',
      content: '深夜的厨房，为自己煮一碗面。照顾好自己，也是一种爱的表达。',
      imageUrl: 'assets/images/dongtai/dongtai_8.png',
      tags: ['来自深夜的我'],
      createdAt: DateTime.now().subtract(const Duration(hours: 11)),
      authorAvatar: 'assets/images/avatars/user_12.png',
      authorName: '暖心小厨',
      likeCount: 41,
      commentCount: 0, // 将被动态设置
    ),
    // 13. 纯文字
    Post(
      id: 'post_13',
      content: '突然想念小时候的无忧无虑，那时候快乐很简单，一颗糖果就能开心一整天。长大后才发现，简单的快乐最珍贵。',
      tags: ['温暖时刻'],
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      authorAvatar: 'assets/images/avatars/user_13.png',
      authorName: '童心未泯',
      likeCount: 78,
      commentCount: 0, // 将被动态设置
    ),
    // 14. 带图片
    Post(
      id: 'post_14',
      content: '公园里的老夫妇，手牵着手散步。爱情最美的样子，大概就是这样吧。',
      imageUrl: 'assets/images/dongtai/dongtai_9.png',
      tags: ['温暖时刻'],
      createdAt: DateTime.now().subtract(const Duration(hours: 13)),
      authorAvatar: 'assets/images/avatars/user_14.png',
      authorName: '爱的见证者',
      likeCount: 76,
      commentCount: 0, // 将被动态设置
    ),
    // 15. 带图片
    Post(
      id: 'post_15',
      content: '雨夜，听着音乐，思绪飘远。有些情感，只有在这样的夜晚才敢释放。',
      imageUrl: 'assets/images/dongtai/dongtai_10.png',
      tags: ['情感树洞'],
      createdAt: DateTime.now().subtract(const Duration(hours: 14)),
      authorAvatar: 'assets/images/avatars/user_15.png',
      authorName: '雨夜聆听者',
      likeCount: 53,
      commentCount: 0, // 将被动态设置
    ),
    // 16. 纯文字
    Post(
      id: 'post_16',
      content: '焦虑的时候，试着深呼吸，告诉自己："这也会过去的。" 没有什么是永恒的，包括痛苦。',
      tags: ['情感树洞'],
      createdAt: DateTime.now().subtract(const Duration(hours: 15)),
      authorAvatar: 'assets/images/avatars/user_16.png',
      authorName: '心灵疗愈师',
      likeCount: 95,
      commentCount: 0, // 将被动态设置
    ),
    // 17. 带图片
    Post(
      id: 'post_17',
      content: '图书馆的安静角落，沉浸在书本的世界里。知识是最好的精神食粮。',
      imageUrl: 'assets/images/dongtai/dongtai_11.png',
      tags: ['孤独瞬间'],
      createdAt: DateTime.now().subtract(const Duration(hours: 16)),
      authorAvatar: 'assets/images/avatars/user_17.png',
      authorName: '书香墨韵',
      likeCount: 24,
      commentCount: 0, // 将被动态设置
    ),
    // 18. 带图片
    Post(
      id: 'post_18',
      content: '清晨的第一缕阳光，新的一天，新的希望。每一个黎明都是生命的礼物。',
      imageUrl: 'assets/images/dongtai/dongtai_12.png',
      tags: ['今日心情'],
      createdAt: DateTime.now().subtract(const Duration(hours: 17)),
      authorAvatar: 'assets/images/avatars/user_18.png',
      authorName: '晨光追梦人',
      likeCount: 61,
      commentCount: 0, // 将被动态设置
    ),
    // 19. 纯文字
    Post(
      id: 'post_19',
      content: '今天遇到了一个陌生人的微笑，瞬间感觉整个世界都亮了。原来善意是可以传递的，温暖是可以感染的。',
      tags: ['温暖时刻'],
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      authorAvatar: 'assets/images/avatars/user_19.png',
      authorName: '微笑传递者',
      likeCount: 61,
      commentCount: 0, // 将被动态设置
    ),
    // 20. 带图片
    Post(
      id: 'post_20',
      content: '小巷里的猫咪，慵懒地晒着太阳。简单的生活，纯真的快乐。',
      imageUrl: 'assets/images/dongtai/dongtai_13.png',
      tags: ['温暖时刻'],
      createdAt: DateTime.now().subtract(const Duration(hours: 19)),
      authorAvatar: 'assets/images/avatars/user_20.png',
      authorName: '小巷猫咪友',
      likeCount: 38,
      commentCount: 0, // 将被动态设置
    ),
    // 21. 带图片
    Post(
      id: 'post_21',
      content: '夜晚的城市天际线，万家灯火。每一盏灯背后，都有一个故事。',
      imageUrl: 'assets/images/dongtai/dongtai_14.png',
      tags: ['来自深夜的我'],
      createdAt: DateTime.now().subtract(const Duration(hours: 20)),
      authorAvatar: 'assets/images/avatars/user_21.png',
      authorName: '城市夜归人',
      likeCount: 47,
      commentCount: 0, // 将被动态设置
    ),
    // 22. 纯文字
    Post(
      id: 'post_22',
      content: '深夜的思考总是格外深刻。关于人生，关于梦想，关于那些还没有答案的问题。黑夜给了我们思考的时间。',
      tags: ['来自深夜的我'],
      createdAt: DateTime.now().subtract(const Duration(hours: 21)),
      authorAvatar: 'assets/images/avatars/user_22.png',
      authorName: '深夜哲思者',
      likeCount: 44,
      commentCount: 0, // 将被动态设置
    ),
    // 23. 带图片
    Post(
      id: 'post_23',
      content: '森林里的小径，阳光透过树叶洒下斑驳的光影。大自然的怀抱最温暖。',
      imageUrl: 'assets/images/dongtai/dongtai_15.png',
      tags: ['治愈系语录'],
      createdAt: DateTime.now().subtract(const Duration(hours: 22)),
      authorAvatar: 'assets/images/avatars/user_23.png',
      authorName: '森林漫步者',
      likeCount: 72,
      commentCount: 0, // 将被动态设置
    ),
    // 24. 带图片
    Post(
      id: 'post_24',
      content: '窗台上的绿植，生机勃勃。照顾它们的过程，也是在治愈自己。',
      imageUrl: 'assets/images/dongtai/dongtai_16.png',
      tags: ['温暖时刻'],
      createdAt: DateTime.now().subtract(const Duration(hours: 23)),
      authorAvatar: 'assets/images/avatars/user_24.png',
      authorName: '绿植小园丁',
      likeCount: 29,
      commentCount: 0, // 将被动态设置
    ),
    // 25. 纯文字
    Post(
      id: 'post_25',
      content: '学会了倾听自己内心的声音，不再被外界的噪音干扰。原来，最重要的答案一直在我们心里。',
      tags: ['情感树洞'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      authorAvatar: 'assets/images/avatars/user_25.png',
      authorName: '内心倾听者',
      likeCount: 58,
      commentCount: 0, // 将被动态设置
    ),
    // 26. 带图片
    Post(
      id: 'post_26',
      content: '山顶的云海，壮观而宁静。站在这里，所有的烦恼都显得那么渺小。',
      imageUrl: 'assets/images/dongtai/dongtai_17.png',
      tags: ['治愈系语录'],
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      authorAvatar: 'assets/images/avatars/user_26.png',
      authorName: '云海观星人',
      likeCount: 94,
      commentCount: 0, // 将被动态设置
    ),
    // 27. 带图片
    Post(
      id: 'post_27',
      content: '深夜的便利店，温暖的灯光。有时候，孤独也可以很温柔。',
      imageUrl: 'assets/images/dongtai/dongtai_18.png',
      tags: ['来自深夜的我'],
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      authorAvatar: 'assets/images/avatars/user_27.png',
      authorName: '便利店常客',
      likeCount: 56,
      commentCount: 0, // 将被动态设置
    ),
    // 28. 纯文字
    Post(
      id: 'post_28',
      content: '感谢每一个陪伴我走过低谷的人，包括那个在深夜里独自坚强的自己。我们都比想象中更勇敢。',
      tags: ['情感树洞'],
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      authorAvatar: 'assets/images/avatars/user_28.png',
      authorName: '勇敢的心',
      likeCount: 103,
      commentCount: 0, // 将被动态设置
    ),
    // 29. 带图片
    Post(
      id: 'post_29',
      content: '花园里的蝴蝶，翩翩起舞。生命的美好，就在这些小小的瞬间里。',
      imageUrl: 'assets/images/dongtai/dongtai_19.png',
      tags: ['温暖时刻'],
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      authorAvatar: 'assets/images/avatars/user_29.png',
      authorName: '蝴蝶花语',
      likeCount: 43,
      commentCount: 0, // 将被动态设置
    ),
    // 30. 带图片
    Post(
      id: 'post_30',
      content: '星空下的帐篷，远离城市的喧嚣。在这里，可以听到自己内心最真实的声音。',
      imageUrl: 'assets/images/dongtai/dongtai_20.png',
      tags: ['情感树洞'],
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      authorAvatar: 'assets/images/avatars/user_30.png',
      authorName: '星空守护者',
      likeCount: 81,
      commentCount: 0, // 将被动态设置
    ),
  ];

  // 静态通知数据
  final List<NotificationItem> _notifications = [
    // 1. 健康贴士通知
    NotificationItem(
      id: 'notif_wellness_1',
      title: '💡 每日健康贴士',
      content: '研究表明，每天10分钟的冥想可以显著减少焦虑。今天你冥想了吗？',
      type: NotificationType.wellness,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      routeName: '/wellness_tips',
    ),
    
    // 2. 成就徽章通知 - 最新
    NotificationItem(
      id: 'notif_achievement_2',
      title: '🎖️ 获得新徽章：「首次使用app」',
      content: '恭喜！欢迎来到静心岛，获得「首次使用app」徽章！',
      type: NotificationType.achievement,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      routeName: '/achievements',
    ),
    
    // 3. 系统公告通知
    NotificationItem(
      id: 'notif_system_1',
      title: '📢 静心岛新功能敬请期待',
      content: '我们正在开发更多精彩功能，包括情绪日记、冥想指导等，敬请期待！',
      type: NotificationType.system,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      routeName: '/coming_soon',
      routeParams: null,
    ),
    
    // 原有通知
    NotificationItem(
      id: 'notif_ai_1',
      title: 'AI 每日提醒：是时候放松一下了',
      content: '您已经工作很久了，要不要来一段冥想放松一下？',
      type: NotificationType.aiReminder,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      routeName: '/ai_chat',
    ),
    NotificationItem(
      id: 'notif_comment_1',
      title: '有用户评论了您的动态',
      content: '\"感同身受，有时候我们都需要这样的时刻。\"',
      type: NotificationType.comment,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      routeName: '/my_posts',
    ),
    NotificationItem(
      id: 'notif_like_1',
      title: '有用户点赞了您的动态',
      content: '您的分享让其他人感到共鸣',
      type: NotificationType.like,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      routeName: '/my_posts',
    ),
  ];

  // 热门话题标签
  final List<String> _hotTopics = [
    '今日心情',
    '孤独瞬间',
    '来自深夜的我',
    '治愈系语录',
    '情感树洞',
    '温暖时刻',
  ];

  // 推荐内容
  final List<Map<String, dynamic>> _recommendations = [
    {
      'type': 'meditation',
      'title': '晨间唤醒冥想',
      'duration': '2分00秒',  // 120.03秒
      'image': 'assets/images/meditation/morning.jpg',
      'audioPath': 'voice/meditation/home_mingxiang_1.mp3',
      'description': '以温和的方式唤醒身心，开启充满活力的一天',
    },
    {
      'type': 'quote',
      'title': '"内心的平静来自于接纳当下，而不是与之对抗。"',
      'author': '静心语录',
    },
    {
      'type': 'meditation',
      'title': '专注力提升',
      'duration': '1分58秒',  // 118.44秒
      'image': 'assets/images/meditation/focus.jpg',
      'audioPath': 'voice/meditation/home_mingxiang_2.mp3',
      'description': '通过呼吸练习增强注意力和工作效率',
    },
    {
      'type': 'quote',
      'title': '"每一次呼吸都是重新开始的机会。"',
      'author': '冥想箴言',
    },
    {
      'type': 'meditation',
      'title': '压力释放冥想',
      'duration': '2分00秒',  // 120.03秒
      'image': 'assets/images/meditation/stress.jpg',
      'audioPath': 'voice/meditation/home_mingxiang_3.mp3',
      'description': '缓解身心压力，找回内心的平静',
    },
    {
      'type': 'quote',
      'title': '"生命中的每个时刻都是练习正念的机会。"',
      'author': '禅修智慧',
    },
    {
      'type': 'meditation',
      'title': '情绪平衡练习',
      'duration': '1分58秒',  // 118.44秒
      'image': 'assets/images/meditation/emotion.jpg',
      'audioPath': 'voice/meditation/home_mingxiang_4.mp3',
      'description': '学习觉察和调节情绪的冥想方法',
    },
    {
      'type': 'quote',
      'title': '"平静不是无为，而是内在的清明。"',
      'author': '心灵笔记',
    },
    {
      'type': 'meditation',
      'title': '正念生活冥想',
      'duration': '2分00秒',  // 120.03秒
      'image': 'assets/images/meditation/mindful.jpg',
      'audioPath': 'voice/meditation/home_mingxiang_5.mp3',
      'description': '培养当下觉知，体验生活的美好',
    },
    {
      'type': 'quote',
      'title': '"静心不是逃避，而是更好地面对。"',
      'author': '冥想感悟',
    },
    {
      'type': 'meditation',
      'title': '深度放松引导',
      'duration': '1分34秒',  // 94.43秒
      'image': 'assets/images/meditation/relax.jpg',
      'audioPath': 'voice/meditation/mingxiang_1.mp3',
      'description': '全身放松练习，缓解身体紧张',
    },
    {
      'type': 'meditation',
      'title': '安眠助眠冥想',
      'duration': '2分00秒',  // 120.03秒
      'image': 'assets/images/meditation/sleep.jpg',
      'audioPath': 'voice/meditation/mingxiang_2.mp3',
      'description': '舒缓的引导帮助你进入深度睡眠',
    },
    {
      'type': 'meditation',
      'title': '慈心关怀冥想',
      'duration': '2分00秒',
      'image': 'assets/images/meditation/compassion.jpg',
      'audioPath': 'voice/meditation/mingxiang_3.mp3',
      'description': '培养慈悲心和自我关怀的能力',
    },
    {
      'type': 'meditation',
      'title': '能量提升冥想',
      'duration': '1分58秒',
      'image': 'assets/images/meditation/energy.jpg',
      'audioPath': 'voice/meditation/mingxiang_4.mp3',
      'description': '提升身体能量和精神活力',
    },
    {
      'type': 'meditation',
      'title': '创造力激发',
      'duration': '2分00秒',
      'image': 'assets/images/meditation/creativity.jpg',
      'audioPath': 'voice/meditation/mingxiang_5.mp3',
      'description': '打开心灵空间，激发创意潜能',
    },
  ];

  // AI 聊天消息
  final List<Map<String, dynamic>> _aiMessages = [
    {
      'id': 'ai_msg_1',
      'isAI': true,
      'content': '你好！我是静心AI，很高兴见到你。今天的心情怎么样？',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'id': 'ai_msg_2',
      'isAI': false,
      'content': '感觉有点焦虑，工作压力很大',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 4)),
    },
    {
      'id': 'ai_msg_3',
      'isAI': true,
      'content': '我理解你的感受。工作压力确实会让人感到焦虑。要不要试试深呼吸？或者我们可以聊聊是什么让你感到压力的？',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 3)),
    },
  ];

  // ============ 反馈相关数据 ============
  
  final List<feedback_model.Feedback> _feedbacks = [];

  // ============ 反馈相关方法 ============

  // 提交反馈
  String submitFeedback({
    required String type,
    required String content,
    String? contact,
  }) {
    // 生成反馈ID
    final feedbackId = 'feedback_${DateTime.now().millisecondsSinceEpoch}';
    
    // 创建反馈记录
    final feedback = feedback_model.Feedback(
      id: feedbackId,
      type: type,
      content: content,
      contact: contact,
      createdAt: DateTime.now(),
      status: feedback_model.FeedbackStatus.pending,
    );

    // 添加到反馈列表
    _feedbacks.add(feedback);

    // 模拟后台处理
    _simulateFeedbackProcessing(feedbackId);

    return feedbackId;
  }

  // 获取用户反馈列表
  List<feedback_model.Feedback> getUserFeedbacks() {
    // 按创建时间排序（最新的在前）
    final sortedFeedbacks = List<feedback_model.Feedback>.from(_feedbacks);
    sortedFeedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedFeedbacks;
  }

  // 根据ID获取反馈详情
  feedback_model.Feedback? getFeedbackById(String feedbackId) {
    try {
      return _feedbacks.firstWhere((feedback) => feedback.id == feedbackId);
    } catch (e) {
      return null;
    }
  }

  // 模拟反馈处理过程
  void _simulateFeedbackProcessing(String feedbackId) {
    // 模拟1-3天后收到回复
    final processingTime = Duration(
      hours: 24 + (DateTime.now().millisecond % 48), // 1-3天
    );

    Future.delayed(processingTime, () {
      final feedbackIndex = _feedbacks.indexWhere((f) => f.id == feedbackId);
      if (feedbackIndex != -1) {
        final feedback = _feedbacks[feedbackIndex];
        
        // 生成模拟回复
        final responses = [
          '感谢您的反馈！我们已经收到您的建议，开发团队正在评估可行性。',
          '您提到的问题我们已经记录，会在下个版本中优化。',
          '非常感谢您的宝贵意见，这对我们改进产品很有帮助！',
          '您的建议很有价值，我们会认真考虑并纳入产品规划。',
          '感谢反馈！相关问题已转交给技术团队处理。',
        ];
        
        final randomResponse = responses[
          DateTime.now().millisecond % responses.length
        ];

        _feedbacks[feedbackIndex] = feedback.copyWith(
          status: feedback_model.FeedbackStatus.replied,
          response: randomResponse,
          responseAt: DateTime.now(),
        );
      }
    });
  }

  // 获取反馈统计信息
  Map<String, int> getFeedbackStats() {
    final stats = <String, int>{
      'total': _feedbacks.length,
      'pending': 0,
      'replied': 0,
      'resolved': 0,
    };

    for (final feedback in _feedbacks) {
      switch (feedback.status) {
        case feedback_model.FeedbackStatus.pending:
          stats['pending'] = stats['pending']! + 1;
          break;
        case feedback_model.FeedbackStatus.replied:
          stats['replied'] = stats['replied']! + 1;
          break;
        case feedback_model.FeedbackStatus.resolved:
          stats['resolved'] = stats['resolved']! + 1;
          break;
      }
    }

    return stats;
  }

  // 获取音频列表
  List<AudioItem> getAudioItems({AudioType? type, String? category}) {
    var items = List<AudioItem>.from(_audioItems);
    
    if (type != null) {
      items = items.where((item) => item.type == type).toList();
    }
    
    if (category != null) {
      items = items.where((item) => item.category == category).toList();
    }
    
    return items;
  }

  // 根据ID获取音频
  AudioItem? getAudioById(String id) {
    try {
      return _audioItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // 获取冥想音频分类
  List<String> getMeditationCategories() {
    return _audioItems
        .where((item) => item.type == AudioType.meditation)
        .map((item) => item.category)
        .toSet()
        .toList();
  }

  // 获取白噪音分类
  List<String> getWhiteNoiseCategories() {
    return _audioItems
        .where((item) => item.type == AudioType.whiteNoise)
        .map((item) => item.category)
        .toSet()
        .toList();
  }

  // 获取帖子列表（带用户点赞状态和实际评论数）
  List<Post> getPosts({int? limit}) {
    var posts = List<Post>.from(_posts);
    
    // 过滤掉被屏蔽的动态
    posts = posts.where((post) => !_blockedPostIds.contains(post.id)).toList();
    
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // 根据用户的点赞数据设置 isLiked 状态，设置收藏状态，并设置实际评论数
    posts = posts.map((post) {
      final commentsForPost = _comments[post.id] ?? [];
      return post.copyWith(
        isLiked: _userData.isPostLiked(post.id),
        isBookmarked: _userData.isPostBookmarked(post.id),
        commentCount: commentsForPost.length,
        // 保留原来的状态，不要重置
        status: post.status,
      );
    }).toList();
    
    if (limit != null && limit > 0) {
      posts = posts.take(limit).toList();
    }
    
    return posts;
  }

  // 根据ID获取帖子（带用户点赞状态和实际评论数）
  Post? getPostById(String id) {
    try {
      final post = _posts.firstWhere((post) => post.id == id);
      final commentsForPost = _comments[post.id] ?? [];
      return post.copyWith(
        isLiked: _userData.isPostLiked(post.id),
        isBookmarked: _userData.isPostBookmarked(post.id),
        commentCount: commentsForPost.length,
        // 保留原来的状态，不要重置
        status: post.status,
      );
    } catch (e) {
      return null;
    }
  }

  // 获取通知列表
  List<NotificationItem> getNotifications({bool? unreadOnly}) {
    var notifications = List<NotificationItem>.from(_notifications);
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (unreadOnly == true) {
      notifications = notifications.where((notif) => !notif.isRead).toList();
    }
    
    return notifications;
  }

  // 获取热门话题
  List<String> getHotTopics() {
    return List<String>.from(_hotTopics);
  }

  // 获取推荐内容
  List<Map<String, dynamic>> getRecommendations() {
    return List<Map<String, dynamic>>.from(_recommendations);
  }

  // 获取所有推荐内容（20条）
  List<Map<String, dynamic>> getAllRecommendations() {
    // 获取基础推荐列表
    final baseRecommendations = List<Map<String, dynamic>>.from(_recommendations);
    
    // 添加更多推荐内容
    final additionalRecommendations = [
      {
        'type': 'meditation',
        'title': '5分钟放松冥想',
        'duration': '2分00秒',  // 120.03秒
        'description': '快速缓解压力，找回内心平静',
        'audioPath': 'voice/meditation/home_mingxiang_1.mp3',
      },
      {
        'type': 'quote',
        'title': '"愿你遍历山河，觉得人间值得。"',
        'author': '治愈句子',
      },
      {
        'type': 'breathing',
        'title': '深度呼吸练习',
        'duration': '1分34秒',  // 94.43秒
        'description': '调节情绪，缓解焦虑',
        'audioPath': 'voice/meditation/mingxiang_1.mp3',
      },
      {
        'type': 'meditation',
        'title': '正念冥想',
        'duration': '2分00秒',  // 120.03秒
        'description': '专注当下，培养觉察力',
        'audioPath': 'voice/meditation/mingxiang_2.mp3',
      },
      {
        'type': 'whitenoise',
        'title': '雨声白噪音',
        'duration': '1分58秒',  // 118.44秒
        'description': '自然雨声，助眠放松',
        'audioPath': 'voice/meditation/home_mingxiang_2.mp3',
      },
      {
        'type': 'quote',
        'title': '"每一个不曾起舞的日子，都是对生命的辜负。"',
        'author': '尼采',
      },
    ];
    
    // 合并列表并返回
    return [...baseRecommendations, ...additionalRecommendations];
  }

  // 获取情感助手消息
  List<Map<String, dynamic>> getAIMessages() {
    return List<Map<String, dynamic>>.from(_aiMessages);
  }

  // 添加AI消息
  void addAIMessage(String content, bool isAI) {
    _aiMessages.add({
      'id': 'ai_msg_${DateTime.now().millisecondsSinceEpoch}',
      'isAI': isAI,
      'content': content,
      'timestamp': DateTime.now(),
    });
  }

  // 当前用户数据
  User _currentUser = User(
    id: 'user_2024001',
    nickname: '温暖如风',
    avatar: 'assets/images/avatars/user_15.png',
    likeCount: 0,
    collectionCount: 0,
    postCount: 0,
    joinDate: DateTime.now().subtract(const Duration(days: 1)),
    mood: '今天心情不错',
    isVip: false, // 默认未开通VIP
  );

  // 获取当前用户信息
  User getCurrentUser() {
    // 计算实际的点赞、收藏、发布数量
    final actualLikeCount = _userData.likedPosts.length;
    final actualCollectionCount = _userData.bookmarkedPosts.length + _userData.favoriteAudios.length;
    final actualPostCount = _userData.myPostIds.length;

    return _currentUser.copyWith(
      likeCount: actualLikeCount,
      collectionCount: actualCollectionCount,
      postCount: actualPostCount,
    );
  }

  // 更新用户信息
  User updateUser({
    String? nickname,
    String? avatar,
    String? mood,
    bool? isVip,
  }) {
    _currentUser = _currentUser.copyWith(
      nickname: nickname,
      avatar: avatar,
      mood: mood,
      isVip: isVip,
    );
    return _currentUser;
  }

  // 切换VIP状态
  void setVipStatus(bool isVip) {
    _currentUser = _currentUser.copyWith(isVip: isVip);
    // 保存到本地
    _saveCurrentUserToLocal();
  }

  // 更新用户金币
  void updateUserCoins(int coins) {
    _currentUser = _currentUser.copyWith(coins: coins);
    // 保存到本地
    _saveCurrentUserToLocal();
  }

  // 更新用户VIP到期时间
  void updateUserVipExpireDate(DateTime? expireDate) {
    _currentUser = _currentUser.copyWith(vipExpireDate: expireDate);
    // 保存到本地
    _saveCurrentUserToLocal();
  }

  // 添加金币（充值用）
  void addCoins(int coins) {
    final currentCoins = _currentUser.coins;
    _currentUser = _currentUser.copyWith(coins: currentCoins + coins);
    // 保存到本地
    _saveCurrentUserToLocal();
  }

  // 激活VIP（订阅用）
  void activateVip() {
    _currentUser = _currentUser.copyWith(
      isVip: true,
      vipExpireDate: DateTime.now().add(const Duration(days: 30)), // 默认30天
    );
    // 保存到本地
    _saveCurrentUserToLocal();
  }

  // 重置用户数据（退出登录时调用）
  void resetUserData() {
    // 保留金币和VIP状态，只重置登录相关信息
    final currentCoins = _currentUser.coins;
    final currentVipStatus = _currentUser.isVip;
    final currentVipExpireDate = _currentUser.vipExpireDate;
    
    _currentUser = User(
      id: 'guest',
      nickname: '游客',
      avatar: 'assets/images/avatars/user_1.png',
      coins: currentCoins, // 保留金币
      likeCount: 0,
      collectionCount: 0,
      postCount: 0,
      joinDate: DateTime.now(),
      mood: '',
      isVip: currentVipStatus, // 保留VIP状态
      vipExpireDate: currentVipExpireDate, // 保留VIP过期时间
      isLoggedIn: false, // 设置为未登录状态
      email: '',
    );
    // 保存到本地
    _saveCurrentUserToLocal();
    // 也可以重置用户数据
    _userData = UserData();
  }

  // 设置登录状态
  void setLoginStatus(bool isLoggedIn, {String email = '', String? nickname}) {
    if (isLoggedIn) {
      // 登录时保留金币和VIP状态，更新登录信息
      _currentUser = _currentUser.copyWith(
        id: 'logged_user_${DateTime.now().millisecondsSinceEpoch}',
        nickname: nickname ?? '心灵旅者',
        isLoggedIn: true,
        email: email,
        joinDate: DateTime.now(),
        // 保留原有的金币和VIP状态
      );
    } else {
      // 退出登录时保留金币和VIP状态
      resetUserData();
    }
    _saveCurrentUserToLocal();
  }

  // 检查登录状态
  bool isLoggedIn() {
    return _currentUser.isLoggedIn;
  }

  // 获取登录用户邮箱
  String getUserEmail() {
    return _currentUser.email;
  }

  // 完全清除用户数据（注销账户时调用）
  Future<void> clearAllUserData() async {
    resetUserData();
    await StorageService.clearUserBackup();
  }

  // 登录成功时恢复本地数据
  Future<void> restoreUserDataOnLogin() async {
    try {
      final savedUser = await StorageService.loadUserBackup();
      if (savedUser != null) {
        _currentUser = savedUser;
        print('🔄 已恢复本地用户数据: ${savedUser.nickname}, 金币: ${savedUser.coins}');
      } else {
        print('🔄 无本地用户数据，使用默认数据');
      }
    } catch (e) {
      print('❌ 恢复本地用户数据失败: $e');
      // 发生错误时重置为游客状态
      resetUserData();
    }
  }

  // 保存当前用户数据到本地
  void _saveCurrentUserToLocal() {
    StorageService.saveUserBackup(_currentUser).catchError((e) {
      print('❌ 保存用户数据到本地失败: $e');
    });
  }

  // 手动保存用户数据到本地
  Future<void> saveUserDataToLocal() async {
    try {
      await StorageService.saveUserBackup(_currentUser);
    } catch (e) {
      print('❌ 手动保存用户数据失败: $e');
    }
  }

  // 更新用户信息并保存到本地
  void updateUserProfile({
    String? nickname,
    String? avatar,
    String? mood,
  }) {
    _currentUser = _currentUser.copyWith(
      nickname: nickname,
      avatar: avatar,
      mood: mood,
    );
    _saveCurrentUserToLocal();
  }

  // 设置当前用户对象
  void setCurrentUser(User user) {
    _currentUser = user;
    _saveCurrentUserToLocal();
  }

  // 获取用户数据
  UserData getUserData() {
    return _userData;
  }

  // 切换动态点赞状态
  bool togglePostLike(String postId) {
    final isCurrentlyLiked = _userData.isPostLiked(postId);
    
    // 找到对应的动态并更新点赞数
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final currentPost = _posts[postIndex];
      
      if (isCurrentlyLiked) {
        // 取消点赞
        _userData = _userData.removeLikedPost(postId);
        _posts[postIndex] = currentPost.copyWith(
          likeCount: currentPost.likeCount - 1,
        );
        // 在实际应用中，这里会向服务器发送取消点赞请求
        return false; // 返回新的点赞状态
      } else {
        // 点赞
        _userData = _userData.addLikedPost(postId);
        _posts[postIndex] = currentPost.copyWith(
          likeCount: currentPost.likeCount + 1,
        );
        // 在实际应用中，这里会向服务器发送点赞请求
        return true; // 返回新的点赞状态
      }
    }
    
    // 如果找不到动态，只更新用户数据
    if (isCurrentlyLiked) {
      _userData = _userData.removeLikedPost(postId);
      return false;
    } else {
      _userData = _userData.addLikedPost(postId);
      return true;
    }
  }

  // 切换动态收藏状态
  bool togglePostBookmark(String postId) {
    final isCurrentlyBookmarked = _userData.isPostBookmarked(postId);
    
    if (isCurrentlyBookmarked) {
      _userData = _userData.removeBookmarkedPost(postId);
      return false;
    } else {
      _userData = _userData.addBookmarkedPost(postId);
      return true;
    }
  }

  // 获取我点赞的动态列表
  List<Post> getLikedPosts() {
    final likedPostIds = _userData.likedPosts;
    final likedPosts = <Post>[];
    
    for (final postId in likedPostIds) {
      final post = getPostById(postId);
      if (post != null) {
        likedPosts.add(post);
      }
    }
    
    // 按点赞时间排序（最近点赞的在前面）
    likedPosts.sort((a, b) {
      final aIndex = likedPostIds.indexOf(a.id);
      final bIndex = likedPostIds.indexOf(b.id);
      return bIndex.compareTo(aIndex);
    });
    
    return likedPosts;
  }

  // 获取我收藏的动态列表
  List<Post> getBookmarkedPosts() {
    final bookmarkedPostIds = _userData.bookmarkedPosts;
    final bookmarkedPosts = <Post>[];
    
    for (final postId in bookmarkedPostIds) {
      final post = getPostById(postId);
      if (post != null) {
        bookmarkedPosts.add(post);
      }
    }
    
    return bookmarkedPosts;
  }

  // 获取指定动态的评论列表
  List<Comment> getCommentsForPost(String postId) {
    return List<Comment>.from(_comments[postId] ?? []);
  }

  // 添加评论
  void addComment(String postId, Comment comment) {
    if (_comments[postId] == null) {
      _comments[postId] = [];
    }
    _comments[postId]!.add(comment);
    
    // 更新对应动态的评论数
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final currentPost = _posts[postIndex];
      _posts[postIndex] = currentPost.copyWith(
        commentCount: _comments[postId]!.length,
      );
    }
  }

  // 删除评论
  void removeComment(String postId, String commentId) {
    if (_comments[postId] != null) {
      _comments[postId]!.removeWhere((comment) => comment.id == commentId);
      
      // 更新对应动态的评论数
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final currentPost = _posts[postIndex];
        _posts[postIndex] = currentPost.copyWith(
          commentCount: _comments[postId]!.length,
        );
      }
    }
  }

  // 初始化一些示例评论数据
  void _initializeCommentsData() {
    // 为一些动态添加示例评论
    _comments['post_1'] = [
      Comment(
        id: 'comment_1_1',
        postId: 'post_1',
        authorName: '温柔的夜',
        authorAvatar: 'assets/images/avatars/user_8.png',
        content: '很有共鸣，有时候我们都需要给自己一个拥抱。',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likeCount: 5,
        isLiked: false,
      ),
      Comment(
        id: 'comment_1_2',
        postId: 'post_1',
        authorName: '星光点点',
        authorAvatar: 'assets/images/avatars/user_12.png',
        content: '阳光总会出现的，坚持住！',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likeCount: 3,
        isLiked: false,
      ),
    ];

    _comments['post_2'] = [
      Comment(
        id: 'comment_2_1',
        postId: 'post_2',
        authorName: '微笑阳光',
        authorAvatar: 'assets/images/avatars/user_5.png',
        content: '这段话很有感触，有时候脆弱也是一种勇敢。',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        likeCount: 8,
        isLiked: false,
      ),
    ];

    _comments['post_3'] = [
      Comment(
        id: 'comment_3_1',
        postId: 'post_3',
        authorName: '安静的猫',
        authorAvatar: 'assets/images/avatars/user_9.png',
        content: '深夜的街道确实很治愈，我也喜欢这样的时刻。',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        likeCount: 4,
        isLiked: false,
      ),
      Comment(
        id: 'comment_3_2',
        postId: 'post_3',
        authorName: '夜晚行者',
        authorAvatar: 'assets/images/avatars/user_14.png',
        content: '城市的夜晚有种特别的魅力',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        likeCount: 2,
        isLiked: false,
      ),
    ];
  }

  // AI回复（使用DeepSeek API）
  Future<String> getAIResponse(String userMessage) async {
    try {
      // 调用DeepSeek API获取回复
      return await AIService.getChatResponse(userMessage);
    } catch (e) {
      // 如果API调用失败，返回备用回复
      return _getFallbackResponse(userMessage);
    }
  }

  // 备用回复方法
  String _getFallbackResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('焦虑') || message.contains('紧张')) {
      return '我理解你的焦虑感受。试试深呼吸练习：吸气4秒，屏息4秒，呼气4秒。这个简单的技巧能帮助你平静下来。';
    } else if (message.contains('失眠') || message.contains('睡不着')) {
      return '失眠确实很困扰人。建议你试试我们的睡前冥想音频，创造一个安静舒适的睡眠环境，睡前一小时避免使用电子设备。';
    } else if (message.contains('压力')) {
      return '感受到压力是很正常的。记住，你已经很努力了。适当的休息和放松同样重要，要不要试试我们的放松音频？';
    } else if (message.contains('开心') || message.contains('高兴')) {
      return '很高兴听到你心情不错！分享快乐会让快乐加倍，能告诉我是什么让你这么开心吗？';
    } else if (message.contains('孤独') || message.contains('寂寞')) {
      return '感到孤独时记住，你并不孤单。我在这里陪伴你，社区里也有很多朋友愿意倾听和支持你。';
    } else {
      return '感谢你与我分享你的想法。每一份真诚的表达都值得被听见和理解。我会一直在这里陪伴你。';
    }
  }

  // 发布新动态
  String publishPost({
    required String content,
    String? imageUrl,
    required String selectedTopic,
  }) {
    // 生成新的动态ID
    final postId = 'user_post_${DateTime.now().millisecondsSinceEpoch}';
    
    // 创建新的动态，设置为审核中状态
    final newPost = Post(
      id: postId,
      content: content,
      imageUrl: imageUrl,
      tags: [selectedTopic],
      createdAt: DateTime.now(),
      authorAvatar: _currentUser.avatar,
      authorName: _currentUser.nickname,
      likeCount: 0,
      commentCount: 0,
      isLiked: false,
      isBookmarked: false,
      status: PostStatus.pending, // 设置为审核中
    );

    // 将新动态添加到列表前面（最新的在前）
    _posts.insert(0, newPost);
    
    // 添加到用户的发布列表
    _userData = _userData.addMyPost(postId);
    
    // 保持审核中状态，不自动通过审核
    
    return postId;
  }

  // 审核通过动态
  void _approvePost(String postId) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      _posts[postIndex] = _posts[postIndex].copyWith(
        status: PostStatus.approved,
      );
    }
  }

  // 获取我发布的动态列表
  List<Post> getMyPosts() {
    final myPostIds = _userData.myPostIds;
    final myPosts = <Post>[];
    
    for (final postId in myPostIds) {
      final post = getPostById(postId);
      if (post != null) {
        myPosts.add(post);
      }
    }
    
    // 按发布时间排序（最新的在前面）
    myPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return myPosts;
  }

  // ============ 举报相关方法 ============

  // 提交举报
  String submitReport({
    required String postId,
    required String reason,
    String? detail,
  }) {
    // 获取被举报的动态信息
    final post = getPostById(postId);
    if (post == null) {
      throw Exception('动态不存在');
    }

    // 生成举报ID
    final reportId = 'report_${DateTime.now().millisecondsSinceEpoch}';
    
    // 创建举报记录
    final report = Report(
      id: reportId,
      reporterId: _currentUser.id,
      reporterName: _currentUser.nickname,
      postId: postId,
      postAuthorId: post.authorName, // 简化处理，实际应该是作者ID
      postAuthorName: post.authorName,
      postContent: post.content,
      reason: reason,
      reasonText: Report.reasonMap[reason] ?? '其他原因',
      detail: detail,
      createdAt: DateTime.now(),
      status: ReportStatus.pending,
      result: ReportResult.none,
    );

    // 添加到举报列表
    _reports.add(report);

    return reportId;
  }

  // 获取我的举报列表
  List<Report> getMyReports() {
    final myReports = _reports.where((report) => 
      report.reporterId == _currentUser.id
    ).toList();
    
    // 检查并更新超过24小时的举报状态
    _checkAndUpdateReportStatus();
    
    // 按举报时间排序（最新的在前）
    myReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return myReports;
  }

  // 根据ID获取举报详情
  Report? getReportById(String reportId) {
    try {
      return _reports.firstWhere((report) => report.id == reportId);
    } catch (e) {
      return null;
    }
  }

  // 检查并更新超过24小时的举报状态
  void _checkAndUpdateReportStatus() {
    final now = DateTime.now();
    
    for (int i = 0; i < _reports.length; i++) {
      final report = _reports[i];
      
      // 只处理审核中的举报
      if (report.status != ReportStatus.pending) continue;
      
      // 检查是否超过24小时
      final timeDifference = now.difference(report.createdAt);
      if (timeDifference.inHours >= 24) {
        // 随机决定审核结果
        final random = (report.createdAt.millisecondsSinceEpoch % 100);
        late ReportStatus status;
        late ReportResult result;
        late String resultNote;

        if (random < 30) {
          // 30% 举报成立
          status = ReportStatus.approved;
          result = _getRandomApprovedResult();
          resultNote = _getResultNote(result);
        } else {
          // 70% 举报不成立
          status = ReportStatus.rejected;
          result = ReportResult.noViolation;
          resultNote = '经审核，该内容未违反社区规定。感谢您对社区环境的关注。';
        }

        // 更新举报状态
        _reports[i] = report.copyWith(
          status: status,
          result: result,
          resultNote: resultNote,
          reviewedAt: now,
          reviewerId: 'admin_001',
          reviewerName: '社区管理员',
        );
      }
    }
  }

  // 获取随机的处理结果（举报成立时）
  ReportResult _getRandomApprovedResult() {
    final results = [
      ReportResult.contentRemoved,
      ReportResult.userWarned,
      ReportResult.userBanned,
    ];
    final index = DateTime.now().millisecond % results.length;
    return results[index];
  }

  // 根据处理结果获取说明文本
  String _getResultNote(ReportResult result) {
    switch (result) {
      case ReportResult.contentRemoved:
        return '经审核，该内容确实违反了社区规定，我们已删除相关内容。感谢您的举报。';
      case ReportResult.userWarned:
        return '经审核，该内容违反社区规定，我们已对发布者进行警告处理。';
      case ReportResult.userBanned:
        return '经审核，该用户存在严重违规行为，我们已对其进行封禁处理。';
      case ReportResult.noViolation:
        return '经审核，该内容未违反社区规定。感谢您对社区环境的关注。';
      case ReportResult.none:
        return '正在审核中...';
    }
  }

  // 获取举报统计信息
  Map<String, int> getReportStats() {
    final myReports = getMyReports();
    final stats = <String, int>{
      'total': myReports.length,
      'pending': 0,
      'approved': 0,
      'rejected': 0,
    };

    for (final report in myReports) {
      switch (report.status) {
        case ReportStatus.pending:
        case ReportStatus.processing:
          stats['pending'] = stats['pending']! + 1;
          break;
        case ReportStatus.approved:
          stats['approved'] = stats['approved']! + 1;
          break;
        case ReportStatus.rejected:
          stats['rejected'] = stats['rejected']! + 1;
          break;
      }
    }

    return stats;
  }

  // ============ 屏蔽相关方法 ============

  // 屏蔽动态
  void blockPost(String postId) {
    _blockedPostIds.add(postId);
  }

  // 取消屏蔽动态
  void unblockPost(String postId) {
    _blockedPostIds.remove(postId);
  }

  // 检查动态是否被屏蔽
  bool isPostBlocked(String postId) {
    return _blockedPostIds.contains(postId);
  }

  // 获取被屏蔽的动态ID列表
  Set<String> getBlockedPostIds() {
    return Set<String>.from(_blockedPostIds);
  }

  // 根据ID获取被屏蔽的动态详情（不受过滤影响）
  Post? getBlockedPostById(String id) {
    try {
      final post = _posts.firstWhere((post) => post.id == id);
      final commentsForPost = _comments[post.id] ?? [];
      return post.copyWith(
        isLiked: _userData.isPostLiked(post.id),
        isBookmarked: _userData.isPostBookmarked(post.id),
        commentCount: commentsForPost.length,
        status: post.status,
      );
    } catch (e) {
      return null;
    }
  }

  // 判断动态是否为当前用户发布
  bool isMyPost(String postId) {
    return _userData.myPostIds.contains(postId);
  }

  // 根据动态作者名称判断是否为当前用户发布（备用方法）
  bool isMyPostByAuthor(String authorName) {
    return authorName == _currentUser.nickname;
  }

  // 删除动态
  bool deletePost(String postId) {
    // 检查是否为当前用户发布的动态
    if (!isMyPost(postId)) {
      return false; // 不允许删除他人动态
    }

    // 从动态列表中移除
    _posts.removeWhere((post) => post.id == postId);
    
    // 从用户发布列表中移除
    _userData = _userData.removeMyPost(postId);
    
    // 删除相关的评论
    _comments.remove(postId);
    
    // 从所有用户的点赞和收藏列表中移除
    _userData = _userData.removeLikedPost(postId);
    _userData = _userData.removeBookmarkedPost(postId);
    
    return true;
  }

  // ============ 成就相关方法 ============

  // 获取所有成就列表
  List<Achievement> getAchievements() {
    _updateAchievementProgress();
    return List<Achievement>.from(_achievements);
  }

  // 获取已解锁的成就
  List<Achievement> getUnlockedAchievements() {
    _updateAchievementProgress();
    return _achievements.where((achievement) => achievement.isUnlocked).toList();
  }

  // 获取成就统计
  Map<String, int> getAchievementStats() {
    _updateAchievementProgress();
    return {
      'total': _achievements.length,
      'unlocked': _achievements.where((a) => a.isUnlocked).length,
      'nearComplete': _achievements.where((a) => a.isNearComplete).length,
    };
  }

  // 根据ID获取成就
  Achievement? getAchievementById(String id) {
    try {
      return _achievements.firstWhere((achievement) => achievement.id == id);
    } catch (e) {
      return null;
    }
  }

  // 更新成就进度
  void _updateAchievementProgress() {
    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      int currentValue = 0;

      // 根据成就类型计算当前进度
      switch (achievement.type) {
        case AchievementType.welcome:
          currentValue = 1; // 欢迎成就默认完成
          break;
        case AchievementType.listener:
          currentValue = _userStats['aiChatDays'] ?? 0;
          break;
        case AchievementType.expresser:
          currentValue = _userStats['postsPublished'] ?? 0;
          break;
        case AchievementType.meditator:
          currentValue = _userStats['meditationMinutes'] ?? 0;
          break;
        case AchievementType.supporter:
          currentValue = _userStats['likesReceived'] ?? 0;
          break;
        case AchievementType.tracker:
          currentValue = _userStats['moodRecordDays'] ?? 0;
          break;
        case AchievementType.challenger:
          currentValue = _userStats['challengesJoined'] ?? 0;
          break;
        case AchievementType.helper:
          currentValue = _userStats['helpActions'] ?? 0;
          break;
        case AchievementType.consistent:
          currentValue = _userStats['consecutiveDays'] ?? 0;
          break;
      }

      // 检查是否应该解锁成就
      bool shouldUnlock = currentValue >= achievement.requiredValue && !achievement.isUnlocked;

      _achievements[i] = achievement.copyWith(
        currentValue: currentValue,
        isUnlocked: shouldUnlock || achievement.isUnlocked,
        unlockedAt: shouldUnlock ? DateTime.now() : achievement.unlockedAt,
      );
    }
  }

  // 更新用户行为统计
  void updateUserStats(String key, int value) {
    _userStats[key] = value;
    _updateAchievementProgress();
  }

  // 增加用户行为统计
  void incrementUserStats(String key, {int increment = 1}) {
    _userStats[key] = (_userStats[key] ?? 0) + increment;
    _updateAchievementProgress();
  }

  // 获取用户统计数据
  Map<String, int> getUserStats() {
    return Map<String, int>.from(_userStats);
  }


} 