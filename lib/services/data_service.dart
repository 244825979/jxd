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

  // 静态帖子数据
  final List<Post> _posts = [
    Post(
      id: 'post_1',
      content: '今天感觉有点低落，但看到窗外的阳光，还是努力给自己一个微笑。',
      imageUrl: 'assets/images/posts/sunshine.jpg',
      tags: ['今日心情'],
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      authorAvatar: AppImages.user1,
      likeCount: 12,
      commentCount: 5,
    ),
    Post(
      id: 'post_2',
      content: '深夜，一杯热茶，一份安静。有时候孤独也是一种享受。',
      tags: ['来自深夜的我', '孤独瞬间'],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      authorAvatar: AppImages.user2,
      likeCount: 28,
      commentCount: 12,
      isLiked: true,
      isBookmarked: true,
    ),
    Post(
      id: 'post_3',
      content: '今天尝试了5分钟冥想，感觉内心平静了很多。推荐给大家！',
      tags: ['治愈系语录', '冥想'],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      authorAvatar: AppImages.user3,
      likeCount: 15,
      commentCount: 8,
    ),
    Post(
      id: 'post_4',
      content: '失眠的夜晚，听着雨声，想起了很多往事。或许这就是成长吧。',
      imageUrl: 'assets/images/posts/rainy_night.jpg',
      tags: ['来自深夜的我', '失眠'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      authorAvatar: AppImages.user4,
      likeCount: 35,
      commentCount: 18,
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
    '失眠',
    '焦虑',
    '压力',
    '成长',
    '冥想',
    '感悟',
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