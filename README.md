App 名称：静心岛
主色调：#E8F5F9（浅雾蓝）+ #FFFDFD（白色背景）+ 点缀 #B3D9D6（薄荷绿）
定位关键词：情绪管理、治愈陪伴、AI对话、冥想白噪音、匿名分享、小众社交、心情记录、心理健康工具

基于HTML原型的Flutter版静心岛App架构设计文档

## 项目概述

静心岛是一款专注于情绪陪伴和心理健康的移动应用，提供AI情绪陪伴、冥想音频、匿名社区交流等功能。

## 功能需求

### 核心功能模块

1. **首页 (Home)**
   - 今日情绪打卡：心情选择器 + 文字/语音输入
   - AI情绪陪伴入口
   - 今日推荐：冥想、呼吸练习、治愈句子
   - 情绪趋势图简览

2. **声音馆 (Sound Library)**
   - 冥想音引导分类展示
   - 白噪音分类展示  
   - 音频播放器
   - 定时关闭功能

3. **广场 (Plaza)**
   - 热门话题标签
   - 匿名发布动态
   - 动态流浏览
   - 点赞、评论、收藏功能

4. **消息 (Messages)**
   - AI心伴私密对话
   - 通知中心

5. **我的 (Profile)**
   - 情绪画像展示
   - 收藏内容管理
   - 我的发布管理
   - 设置入口

## 项目架构

### 目录结构

```
lib/
├── main.dart                    # 应用入口
├── app.dart                     # App配置
├── constants/                   # 常量定义
│   ├── app_colors.dart         # 颜色常量
│   ├── app_images.dart         # 图片路径常量
│   └── app_strings.dart        # 文本常量
├── models/                     # 数据模型
│   ├── mood_record.dart        # 心情记录模型
│   ├── audio_item.dart         # 音频项目模型
│   ├── post.dart               # 动态帖子模型
│   ├── notification.dart       # 通知模型
│   └── user_data.dart          # 用户数据模型
├── services/                   # 服务层
│   ├── storage_service.dart    # 本地存储服务
│   ├── audio_service.dart      # 音频播放服务
│   └── data_service.dart       # 数据管理服务
├── widgets/                    # 通用组件
│   ├── common/                 # 通用组件
│   │   ├── custom_card.dart    # 自定义卡片
│   │   ├── mood_selector.dart  # 心情选择器
│   │   ├── audio_player_widget.dart # 音频播放器
│   │   └── post_card.dart      # 动态卡片
│   └── charts/                 # 图表组件
│       └── mood_chart.dart     # 心情趋势图
├── screens/                    # 页面
│   ├── main_screen.dart        # 主容器页面
│   ├── home/                   # 首页模块
│   │   ├── home_screen.dart    # 首页
│   │   └── ai_chat_screen.dart # AI对话页面
│   ├── sound_library/          # 声音馆模块
│   │   ├── sound_library_screen.dart # 声音馆首页
│   │   └── audio_player_screen.dart  # 音频播放页面
│   ├── plaza/                  # 广场模块
│   │   ├── plaza_screen.dart   # 广场首页
│   │   ├── publish_post_screen.dart # 发布动态页面
│   │   └── post_detail_screen.dart  # 动态详情页面
│   ├── messages/               # 消息模块
│   │   ├── messages_screen.dart # 消息首页
│   │   └── chat_screen.dart    # 聊天页面
│   └── profile/                # 我的模块
│       ├── profile_screen.dart # 我的首页
│       ├── my_collections_screen.dart # 我的收藏
│       ├── my_posts_screen.dart # 我的发布
│       └── settings_screen.dart # 设置页面
└── utils/                      # 工具类
    ├── date_utils.dart         # 日期工具
    └── audio_utils.dart        # 音频工具

assets/
├── images/                     # 图片资源
│   ├── avatars/               # 头像图片
│   │   ├── user_1.png
│   │   ├── user_2.png
│   │   └── ai_avatar.png
│   ├── backgrounds/           # 背景图片
│   └── icons/                 # 图标
└── audios/                    # 音频资源
    ├── meditation/            # 冥想音频
    └── white_noise/           # 白噪音
```

## 核心数据模型

### 1. MoodRecord (心情记录)
```dart
class MoodRecord {
  final String id;
  final DateTime date;
  final int moodValue;     // 1-5心情等级
  final String moodEmoji;  // 心情表情
  final String? note;      // 文字记录
  final String? voiceNote; // 语音记录路径
  
  MoodRecord({
    required this.id,
    required this.date,
    required this.moodValue,
    required this.moodEmoji,
    this.note,
    this.voiceNote,
  });
}
```

### 2. AudioItem (音频项目)
```dart
class AudioItem {
  final String id;
  final String title;
  final String description;
  final String coverImage;
  final String audioPath;
  final int duration;      // 秒数
  final AudioType type;    // 冥想/白噪音
  final String category;   // 分类
  final bool isFavorite;
  
  AudioItem({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.audioPath,
    required this.duration,
    required this.type,
    required this.category,
    this.isFavorite = false,
  });
}

enum AudioType { meditation, whiteNoise }
```

### 3. Post (动态帖子)
```dart
class Post {
  final String id;
  final String content;
  final String? imageUrl;
  final List<String> tags;
  final DateTime createdAt;
  final String authorAvatar;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isBookmarked;
  
  Post({
    required this.id,
    required this.content,
    this.imageUrl,
    required this.tags,
    required this.createdAt,
    required this.authorAvatar,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
  });
}
```

### 4. NotificationItem (通知)
```dart
class NotificationItem {
  final String id;
  final String title;
  final String content;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  
  NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });
}

enum NotificationType { aiReminder, comment, like, system }
```

### 5. UserData (用户数据)
```dart
class UserData {
  final List<String> favoriteAudios;    // 收藏的音频ID
  final List<String> bookmarkedPosts;   // 收藏的动态ID
  final List<String> myPostIds;         // 我的发布ID
  final Map<String, dynamic> settings;  // 设置数据
  
  UserData({
    this.favoriteAudios = const [],
    this.bookmarkedPosts = const [],
    this.myPostIds = const [],
    this.settings = const {},
  });
}
```

## 核心服务

### 1. StorageService (存储服务)
- 使用SharedPreferences进行本地数据持久化
- 管理心情记录、用户偏好设置、收藏数据等

### 2. AudioService (音频服务)
- 音频播放控制
- 定时关闭功能
- 播放进度管理

### 3. DataService (数据服务)
- 本地静态数据管理
- 模拟API数据返回
- 数据CRUD操作

## 实现计划

### 第一阶段：基础框架搭建 (1-2天)
1. **项目初始化**
   - 创建Flutter项目
   - 配置pubspec.yaml依赖
   - 设置基础目录结构

2. **常量和资源配置**
   - 定义颜色、字符串、图片路径常量
   - 准备本地图片和音频资源

3. **基础模型定义**
   - 创建所有数据模型类
   - 实现基础的序列化方法

### 第二阶段：核心服务开发 (2-3天)
1. **StorageService实现**
   - SharedPreferences封装
   - 数据存取方法

2. **DataService实现**
   - 静态数据初始化
   - 模拟数据CRUD操作

3. **AudioService基础实现**
   - 音频播放基础功能

### 第三阶段：主框架和导航 (1-2天)
1. **MainScreen实现**
   - 底部导航栏
   - 页面切换逻辑

2. **基础页面骨架**
   - 创建所有主要页面的基础结构

### 第四阶段：首页模块开发 (3-4天)
1. **心情打卡功能**
   - MoodSelector组件
   - 文字输入和数据保存

2. **AI陪伴入口**
   - 静态UI实现

3. **今日推荐展示**
   - 推荐内容卡片
   - 数据绑定

4. **情绪趋势图**
   - 基础图表展示

### 第五阶段：声音馆模块开发 (3-4天)
1. **音频列表展示**
   - 分类展示
   - 音频卡片组件

2. **音频播放器**
   - 播放控制界面
   - 进度条和时间显示

3. **定时关闭功能**
   - 定时器实现

### 第六阶段：广场模块开发 (3-4天)
1. **动态列表展示**
   - PostCard组件
   - 动态数据绑定

2. **发布功能**
   - 发布页面UI
   - 数据保存逻辑

3. **互动功能**
   - 点赞、收藏功能

### 第七阶段：消息和我的模块 (2-3天)
1. **消息页面**
   - 通知列表
   - AI对话入口

2. **个人中心**
   - 收藏管理
   - 我的发布
   - 设置页面

### 第八阶段：优化和完善 (2-3天)
1. **UI优化**
   - 细节调整
   - 动画效果

2. **性能优化**
   - 内存管理
   - 加载优化

3. **测试和调试**
   - 功能测试
   - Bug修复

## 技术要点

### 状态管理策略
- 页面级状态使用setState管理
- 跨页面数据通过服务类管理
- 简单数据传递使用构造函数参数

### 数据持久化策略
- 用户设置：SharedPreferences
- 心情记录：JSON格式存储在SharedPreferences
- 静态数据：代码中硬编码

### 音频播放策略
- 使用audioplayers包进行音频播放
- 支持后台播放和定时关闭
- 播放状态通过服务类管理

### UI设计策略
- 遵循Material Design规范
- 使用系统默认字体
- 颜色主题与HTML原型保持一致

## 依赖包列表

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2    # 本地存储
  audioplayers: ^5.2.1          # 音频播放
  fl_chart: ^0.65.0             # 图表组件
  image_picker: ^1.0.4          # 图片选择(发布动态用)
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## 性能考虑

1. **内存管理**
   - 及时释放不需要的资源
   - 音频播放器适当时机dispose

2. **加载优化**
   - 图片懒加载
   - 列表数据分页加载模拟

3. **流畅度保证**
   - 避免主线程阻塞
   - 合理使用异步操作

## 测试策略

1. **单元测试**
   - 数据模型测试
   - 服务类方法测试

2. **集成测试**
   - 页面跳转测试
   - 数据流测试

3. **手动测试**
   - 功能完整性测试
   - UI交互测试
