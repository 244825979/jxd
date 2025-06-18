import '../models/audio_item.dart';
import '../models/post.dart';
import '../models/notification.dart';
import '../constants/app_images.dart';

class DataService {
  static DataService? _instance;
  DataService._();

  static DataService getInstance() {
    return _instance ??= DataService._();
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

  // 静态帖子数据 - 图片和纯文字动态交错排列
  final List<Post> _posts = [
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
      commentCount: 5,
    ),
    // 2. 纯文字
    Post(
      id: 'post_2',
      content: '今天想起了一句话："你要做一个不动声色的大人了。不准情绪化，不准偷偷想念，不准回头看。" 但有时候，允许自己脆弱一下，也没关系的。',
      tags: ['情感树洞', '成长'],
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      authorAvatar: 'assets/images/avatars/user_2.png',
      authorName: '温柔的风',
      likeCount: 67,
      commentCount: 23,
      isBookmarked: true,
    ),
    // 3. 带图片
    Post(
      id: 'post_3',
      content: '深夜的街道，霓虹灯闪烁，内心却异常平静。这个城市的夜晚总是那么治愈。',
      imageUrl: 'assets/images/dongtai/dongtai_2.png',
      tags: ['来自深夜的我', '治愈系语录'],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      authorAvatar: 'assets/images/avatars/user_3.png',
      authorName: '夜色温柔',
      likeCount: 28,
      commentCount: 12,
      isLiked: true,
    ),
    // 4. 带图片
    Post(
      id: 'post_4',
      content: '春天的第一朵花开了，就像心情突然明亮起来。生活总是在不经意间给我们小惊喜。',
      imageUrl: 'assets/images/dongtai/dongtai_3.png',
      tags: ['温暖时刻', '今日心情'],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      authorAvatar: 'assets/images/avatars/user_4.png',
      authorName: '春暖花开的心',
      likeCount: 45,
      commentCount: 18,
      isBookmarked: true,
    ),
    // 5. 纯文字
    Post(
      id: 'post_5',
      content: '失眠的夜晚，脑海里播放着白天的画面。有些话想说却不知道对谁说，有些情感想表达却找不到合适的方式。',
      tags: ['来自深夜的我', '失眠'],
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      authorAvatar: 'assets/images/avatars/user_5.png',
      authorName: '深夜听雨人',
      likeCount: 89,
      commentCount: 35,
      isLiked: true,
    ),
    // 6. 带图片
    Post(
      id: 'post_6',
      content: '雨后的天空格外清澈，就像洗涤过的心灵。有时候，眼泪过后就是彩虹。',
      imageUrl: 'assets/images/dongtai/dongtai_4.png',
      tags: ['情感树洞', '治愈系语录'],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      authorAvatar: 'assets/images/avatars/user_6.png',
      authorName: '雨后彩虹',
      likeCount: 32,
      commentCount: 8,
    ),
    // 7. 带图片
    Post(
      id: 'post_7',
      content: '咖啡店的午后，阳光透过玻璃窗洒在桌案上。这一刻，时间好像停止了。',
      imageUrl: 'assets/images/dongtai/dongtai_5.png',
      tags: ['孤独瞬间', '温暖时刻'],
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      authorAvatar: 'assets/images/avatars/user_7.png',
      authorName: '午后咖啡香',
      likeCount: 67,
      commentCount: 23,
      isLiked: true,
      isBookmarked: true,
    ),
    // 8. 纯文字
    Post(
      id: 'post_8',
      content: '学会了冥想之后，感觉世界都安静了。原来内心的平静，不是没有波澜，而是学会了与波澜共处。',
      tags: ['冥想', '成长'],
      createdAt: DateTime.now().subtract(const Duration(hours: 7)),
      authorAvatar: 'assets/images/avatars/user_8.png',
      authorName: '静心守望者',
      likeCount: 52,
      commentCount: 17,
    ),
    // 9. 带图片
    Post(
      id: 'post_9',
      content: '夜晚的书桌，一盏台灯，一本书。简单的快乐，纯粹的满足。',
      imageUrl: 'assets/images/dongtai/dongtai_6.png',
      tags: ['来自深夜的我', '成长'],
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      authorAvatar: 'assets/images/avatars/user_9.png',
      authorName: '灯下读书人',
      likeCount: 19,
      commentCount: 6,
    ),
    // 10. 带图片
    Post(
      id: 'post_10',
      content: '海边的日落，橙红色的天空倒映在水面上。大自然总是最好的心理医生。',
      imageUrl: 'assets/images/dongtai/dongtai_7.png',
      tags: ['治愈系语录', '温暖时刻'],
      createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      authorAvatar: 'assets/images/avatars/user_10.png',
      authorName: '海边拾贝者',
      likeCount: 89,
      commentCount: 34,
      isLiked: true,
    ),
    // 11. 纯文字
    Post(
      id: 'post_11',
      content: '压力山大的一周终于结束了。虽然很累，但也收获了很多。成长的路上，每一步都算数。',
      tags: ['压力', '成长'],
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      authorAvatar: 'assets/images/avatars/user_11.png',
      authorName: '成长路上的我',
      likeCount: 34,
      commentCount: 11,
    ),
    // 12. 带图片
    Post(
      id: 'post_12',
      content: '深夜的厨房，为自己煮一碗面。照顾好自己，也是一种爱的表达。',
      imageUrl: 'assets/images/dongtai/dongtai_8.png',
      tags: ['来自深夜的我', '自我关爱'],
      createdAt: DateTime.now().subtract(const Duration(hours: 11)),
      authorAvatar: 'assets/images/avatars/user_12.png',
      authorName: '暖心小厨',
      likeCount: 41,
      commentCount: 15,
    ),
    // 13. 纯文字
    Post(
      id: 'post_13',
      content: '突然想念小时候的无忧无虑，那时候快乐很简单，一颗糖果就能开心一整天。长大后才发现，简单的快乐最珍贵。',
      tags: ['温暖时刻', '感悟'],
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      authorAvatar: 'assets/images/avatars/user_13.png',
      authorName: '童心未泯',
      likeCount: 78,
      commentCount: 26,
      isBookmarked: true,
    ),
    // 14. 带图片
    Post(
      id: 'post_14',
      content: '公园里的老夫妇，手牵着手散步。爱情最美的样子，大概就是这样吧。',
      imageUrl: 'assets/images/dongtai/dongtai_9.png',
      tags: ['温暖时刻', '感悟'],
      createdAt: DateTime.now().subtract(const Duration(hours: 13)),
      authorAvatar: 'assets/images/avatars/user_14.png',
      authorName: '爱的见证者',
      likeCount: 76,
      commentCount: 28,
      isBookmarked: true,
    ),
    // 15. 带图片
    Post(
      id: 'post_15',
      content: '雨夜，听着音乐，思绪飘远。有些情感，只有在这样的夜晚才敢释放。',
      imageUrl: 'assets/images/dongtai/dongtai_10.png',
      tags: ['情感树洞', '来自深夜的我'],
      createdAt: DateTime.now().subtract(const Duration(hours: 14)),
      authorAvatar: 'assets/images/avatars/user_15.png',
      authorName: '雨夜聆听者',
      likeCount: 53,
      commentCount: 19,
      isLiked: true,
    ),
    // 16. 纯文字
    Post(
      id: 'post_16',
      content: '焦虑的时候，试着深呼吸，告诉自己："这也会过去的。" 没有什么是永恒的，包括痛苦。',
      tags: ['焦虑', '治愈系语录'],
      createdAt: DateTime.now().subtract(const Duration(hours: 15)),
      authorAvatar: 'assets/images/avatars/user_16.png',
      authorName: '心灵疗愈师',
      likeCount: 95,
      commentCount: 31,
      isLiked: true,
    ),
    // 17. 带图片
    Post(
      id: 'post_17',
      content: '图书馆的安静角落，沉浸在书本的世界里。知识是最好的精神食粮。',
      imageUrl: 'assets/images/dongtai/dongtai_11.png',
      tags: ['成长', '孤独瞬间'],
      createdAt: DateTime.now().subtract(const Duration(hours: 16)),
      authorAvatar: 'assets/images/avatars/user_17.png',
      authorName: '书香墨韵',
      likeCount: 24,
      commentCount: 7,
    ),
    // 18. 带图片
    Post(
      id: 'post_18',
      content: '清晨的第一缕阳光，新的一天，新的希望。每一个黎明都是生命的礼物。',
      imageUrl: 'assets/images/dongtai/dongtai_12.png',
      tags: ['今日心情', '温暖时刻'],
      createdAt: DateTime.now().subtract(const Duration(hours: 17)),
      authorAvatar: 'assets/images/avatars/user_18.png',
      authorName: '晨光追梦人',
      likeCount: 61,
      commentCount: 22,
      isBookmarked: true,
    ),
    // 19. 纯文字
    Post(
      id: 'post_19',
      content: '今天遇到了一个陌生人的微笑，瞬间感觉整个世界都亮了。原来善意是可以传递的，温暖是可以感染的。',
      tags: ['温暖时刻', '今日心情'],
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      authorAvatar: 'assets/images/avatars/user_19.png',
      authorName: '微笑传递者',
      likeCount: 61,
      commentCount: 19,
    ),
    // 20. 带图片
    Post(
      id: 'post_20',
      content: '小巷里的猫咪，慵懒地晒着太阳。简单的生活，纯真的快乐。',
      imageUrl: 'assets/images/dongtai/dongtai_13.png',
      tags: ['温暖时刻', '治愈系语录'],
      createdAt: DateTime.now().subtract(const Duration(hours: 19)),
      authorAvatar: 'assets/images/avatars/user_20.png',
      authorName: '小巷猫咪友',
      likeCount: 38,
      commentCount: 12,
      isLiked: true,
    ),
    // 21. 带图片
    Post(
      id: 'post_21',
      content: '夜晚的城市天际线，万家灯火。每一盏灯背后，都有一个故事。',
      imageUrl: 'assets/images/dongtai/dongtai_14.png',
      tags: ['来自深夜的我', '感悟'],
      createdAt: DateTime.now().subtract(const Duration(hours: 20)),
      authorAvatar: 'assets/images/avatars/user_21.png',
      authorName: '城市夜归人',
      likeCount: 47,
      commentCount: 16,
    ),
    // 22. 纯文字
    Post(
      id: 'post_22',
      content: '深夜的思考总是格外深刻。关于人生，关于梦想，关于那些还没有答案的问题。黑夜给了我们思考的时间。',
      tags: ['来自深夜的我', '感悟'],
      createdAt: DateTime.now().subtract(const Duration(hours: 21)),
      authorAvatar: 'assets/images/avatars/user_22.png',
      authorName: '深夜哲思者',
      likeCount: 44,
      commentCount: 15,
    ),
    // 23. 带图片
    Post(
      id: 'post_23',
      content: '森林里的小径，阳光透过树叶洒下斑驳的光影。大自然的怀抱最温暖。',
      imageUrl: 'assets/images/dongtai/dongtai_15.png',
      tags: ['治愈系语录', '冥想'],
      createdAt: DateTime.now().subtract(const Duration(hours: 22)),
      authorAvatar: 'assets/images/avatars/user_23.png',
      authorName: '森林漫步者',
      likeCount: 72,
      commentCount: 25,
      isBookmarked: true,
    ),
    // 24. 带图片
    Post(
      id: 'post_24',
      content: '窗台上的绿植，生机勃勃。照顾它们的过程，也是在治愈自己。',
      imageUrl: 'assets/images/dongtai/dongtai_16.png',
      tags: ['温暖时刻', '自我关爱'],
      createdAt: DateTime.now().subtract(const Duration(hours: 23)),
      authorAvatar: 'assets/images/avatars/user_24.png',
      authorName: '绿植小园丁',
      likeCount: 29,
      commentCount: 9,
    ),
    // 25. 纯文字
    Post(
      id: 'post_25',
      content: '学会了倾听自己内心的声音，不再被外界的噪音干扰。原来，最重要的答案一直在我们心里。',
      tags: ['情感树洞', '冥想'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      authorAvatar: 'assets/images/avatars/user_25.png',
      authorName: '内心倾听者',
      likeCount: 58,
      commentCount: 21,
      isBookmarked: true,
    ),
    // 26. 带图片
    Post(
      id: 'post_26',
      content: '山顶的云海，壮观而宁静。站在这里，所有的烦恼都显得那么渺小。',
      imageUrl: 'assets/images/dongtai/dongtai_17.png',
      tags: ['感悟', '治愈系语录'],
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      authorAvatar: 'assets/images/avatars/user_26.png',
      authorName: '云海观星人',
      likeCount: 94,
      commentCount: 31,
      isLiked: true,
    ),
    // 27. 带图片
    Post(
      id: 'post_27',
      content: '深夜的便利店，温暖的灯光。有时候，孤独也可以很温柔。',
      imageUrl: 'assets/images/dongtai/dongtai_18.png',
      tags: ['来自深夜的我', '孤独瞬间'],
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      authorAvatar: 'assets/images/avatars/user_27.png',
      authorName: '便利店常客',
      likeCount: 56,
      commentCount: 20,
      isBookmarked: true,
    ),
    // 28. 纯文字
    Post(
      id: 'post_28',
      content: '感谢每一个陪伴我走过低谷的人，包括那个在深夜里独自坚强的自己。我们都比想象中更勇敢。',
      tags: ['感悟', '成长'],
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      authorAvatar: 'assets/images/avatars/user_28.png',
      authorName: '勇敢的心',
      likeCount: 103,
      commentCount: 38,
      isLiked: true,
      isBookmarked: true,
    ),
    // 29. 带图片
    Post(
      id: 'post_29',
      content: '花园里的蝴蝶，翩翩起舞。生命的美好，就在这些小小的瞬间里。',
      imageUrl: 'assets/images/dongtai/dongtai_19.png',
      tags: ['温暖时刻', '今日心情'],
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      authorAvatar: 'assets/images/avatars/user_29.png',
      authorName: '蝴蝶花语',
      likeCount: 43,
      commentCount: 14,
    ),
    // 30. 带图片
    Post(
      id: 'post_30',
      content: '星空下的帐篷，远离城市的喧嚣。在这里，可以听到自己内心最真实的声音。',
      imageUrl: 'assets/images/dongtai/dongtai_20.png',
      tags: ['情感树洞', '冥想'],
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      authorAvatar: 'assets/images/avatars/user_30.png',
      authorName: '星空守护者',
      likeCount: 81,
      commentCount: 27,
      isLiked: true,
    ),
  ];

  // 静态通知数据
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 'notif_1',
      title: 'AI 每日提醒：是时候放松一下了',
      content: '您已经工作很久了，要不要来一段冥想放松一下？',
      type: NotificationType.aiReminder,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    NotificationItem(
      id: 'notif_2',
      title: '匿名用户评论了您的动态',
      content: '\"感同身受，有时候我们都需要这样的时刻。\"',
      type: NotificationType.comment,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationItem(
      id: 'notif_3',
      title: '匿名用户点赞了您的动态',
      content: '您的分享让其他人感到共鸣',
      type: NotificationType.like,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
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
    '失眠',
    '焦虑',
    '压力',
    '成长',
    '冥想',
    '感悟',
    '自我关爱',
  ];

  // 推荐内容
  final List<Map<String, dynamic>> _recommendations = [
    {
      'type': 'meditation',
      'title': '身心放松冥想',
      'duration': '5分钟',
      'image': 'assets/images/meditation/relaxation.jpg',
      'audioId': 'meditation_3',
    },
    {
      'type': 'breathing',
      'title': '深度呼吸练习',
      'duration': '3分钟',
      'image': 'assets/images/meditation/breathing.jpg',
      'audioId': 'meditation_1',
    },
    {
      'type': 'quote',
      'title': '"愿你遍历山河，觉得人间值得。"',
      'author': '治愈句子',
    },
    {
      'type': 'meditation',
      'title': '正念冥想',
      'duration': '10分钟',
      'image': 'assets/images/meditation/mindfulness.jpg',
      'audioId': 'meditation_2',
    },
    {
      'type': 'quote',
      'title': '"每一个不曾起舞的日子，都是对生命的辜负。"',
      'author': '尼采',
    },
    {
      'type': 'whitenoise',
      'title': '雨声白噪音',
      'duration': '90秒',
      'image': 'assets/images/whitenoise/rain.jpg',
      'audioId': 'whitenoise_1',
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

  // 获取帖子列表
  List<Post> getPosts({int? limit}) {
    var posts = List<Post>.from(_posts);
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (limit != null && limit > 0) {
      posts = posts.take(limit).toList();
    }
    
    return posts;
  }

  // 根据ID获取帖子
  Post? getPostById(String id) {
    try {
      return _posts.firstWhere((post) => post.id == id);
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
    return [
      {
        'type': 'meditation',
        'title': '5分钟放松冥想',
        'duration': '5分钟',
        'description': '快速缓解压力，找回内心平静',
        'audioId': 'meditation_3',
      },
      {
        'type': 'quote',
        'title': '"愿你遍历山河，觉得人间值得。"',
        'author': '治愈句子',
      },
      {
        'type': 'breathing',
        'title': '深度呼吸练习',
        'duration': '3分钟',
        'description': '调节情绪，缓解焦虑',
        'audioId': 'meditation_1',
      },
      {
        'type': 'meditation',
        'title': '正念冥想',
        'duration': '10分钟',
        'description': '专注当下，培养觉察力',
        'audioId': 'meditation_2',
      },
      {
        'type': 'whitenoise',
        'title': '雨声白噪音',
        'duration': '30分钟',
        'description': '自然雨声，助眠放松',
        'audioId': 'whitenoise_1',
      },
      {
        'type': 'quote',
        'title': '"每一个不曾起舞的日子，都是对生命的辜负。"',
        'author': '尼采',
      },
      {
        'type': 'music',
        'title': '轻柔钢琴曲',
        'duration': '15分钟',
        'description': '舒缓心情的钢琴旋律',
        'audioId': 'music_1',
      },
      {
        'type': 'meditation',
        'title': '身体扫描冥想',
        'duration': '20分钟',
        'description': '放松身体每一个部位',
        'audioId': 'meditation_4',
      },
      {
        'type': 'story',
        'title': '森林里的小屋',
        'duration': '12分钟',
        'description': '温暖治愈的睡前故事',
        'audioId': 'story_1',
      },
      {
        'type': 'quote',
        'title': '"你要做一个不动声色的大人了。"',
        'author': '村上春树',
      },
      {
        'type': 'whitenoise',
        'title': '海浪声',
        'duration': '45分钟',
        'description': '海边的宁静，心灵的港湾',
        'audioId': 'whitenoise_2',
      },
      {
        'type': 'breathing',
        'title': '4-7-8呼吸法',
        'duration': '5分钟',
        'description': '科学呼吸法，快速入眠',
        'audioId': 'breathing_1',
      },
      {
        'type': 'meditation',
        'title': '慈心冥想',
        'duration': '15分钟',
        'description': '培养慈悲心，释放负面情绪',
        'audioId': 'meditation_5',
      },
      {
        'type': 'quote',
        'title': '"生活不是等待暴风雨过去，而是学会在雨中起舞。"',
        'author': '佚名',
      },
      {
        'type': 'music',
        'title': '自然音乐合集',
        'duration': '25分钟',
        'description': '鸟鸣、流水、风声的和谐交响',
        'audioId': 'music_2',
      },
      {
        'type': 'story',
        'title': '星空下的对话',
        'duration': '8分钟',
        'description': '关于梦想与希望的温柔故事',
        'audioId': 'story_2',
      },
      {
        'type': 'whitenoise',
        'title': '篝火声',
        'duration': '60分钟',
        'description': '温暖的篝火声，带来安全感',
        'audioId': 'whitenoise_3',
      },
      {
        'type': 'quote',
        'title': '"山川是不卷收的文章，日月为你掌灯伴读。"',
        'author': '简媜',
      },
      {
        'type': 'meditation',
        'title': '行走冥想',
        'duration': '8分钟',
        'description': '在行走中找到内心的宁静',
        'audioId': 'meditation_6',
      },
      {
        'type': 'breathing',
        'title': '盒式呼吸法',
        'duration': '6分钟',
        'description': '军队训练的呼吸技巧，快速冷静',
        'audioId': 'breathing_2',
      },
    ];
  }

  // 获取AI聊天消息
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

  // 模拟AI回复
  Future<String> getAIResponse(String userMessage) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));
    
    // 简单的关键词匹配回复
    final message = userMessage.toLowerCase();
    
    if (message.contains('焦虑') || message.contains('紧张')) {
      return '我理解你的焦虑。试试深呼吸：吸气4秒，屏息4秒，呼气4秒。重复几次会有帮助的。';
    } else if (message.contains('失眠') || message.contains('睡不着')) {
      return '失眠确实困扰。建议你试试睡前冥想，我们有专门的睡眠引导音频。另外，睡前一小时尽量远离电子设备。';
    } else if (message.contains('压力')) {
      return '工作压力是现代人的常见问题。记住，你已经很努力了。要不要听听放松的冥想音频？';
    } else if (message.contains('开心') || message.contains('高兴')) {
      return '很高兴听到你心情不错！保持这种积极的状态，你可以分享一下是什么让你这么开心吗？';
    } else {
      return '谢谢你的分享。我会一直在这里陪伴你。如果有什么困扰，随时可以告诉我。';
    }
  }
} 