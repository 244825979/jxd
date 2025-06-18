class UserData {
  final List<String> favoriteAudios; // 收藏的音频ID
  final List<String> bookmarkedPosts; // 收藏的动态ID
  final List<String> likedPosts; // 点赞的动态ID
  final List<String> myPostIds; // 我的发布ID
  final Map<String, dynamic> settings; // 设置数据

  UserData({
    this.favoriteAudios = const [],
    this.bookmarkedPosts = const [],
    this.likedPosts = const [],
    this.myPostIds = const [],
    this.settings = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'favoriteAudios': favoriteAudios,
      'bookmarkedPosts': bookmarkedPosts,
      'likedPosts': likedPosts,
      'myPostIds': myPostIds,
      'settings': settings,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      favoriteAudios: List<String>.from(json['favoriteAudios'] ?? []),
      bookmarkedPosts: List<String>.from(json['bookmarkedPosts'] ?? []),
      likedPosts: List<String>.from(json['likedPosts'] ?? []),
      myPostIds: List<String>.from(json['myPostIds'] ?? []),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
    );
  }

  UserData copyWith({
    List<String>? favoriteAudios,
    List<String>? bookmarkedPosts,
    List<String>? likedPosts,
    List<String>? myPostIds,
    Map<String, dynamic>? settings,
  }) {
    return UserData(
      favoriteAudios: favoriteAudios ?? this.favoriteAudios,
      bookmarkedPosts: bookmarkedPosts ?? this.bookmarkedPosts,
      likedPosts: likedPosts ?? this.likedPosts,
      myPostIds: myPostIds ?? this.myPostIds,
      settings: settings ?? this.settings,
    );
  }

  UserData addFavoriteAudio(String audioId) {
    final newFavorites = [...favoriteAudios];
    if (!newFavorites.contains(audioId)) {
      newFavorites.add(audioId);
    }
    return copyWith(favoriteAudios: newFavorites);
  }

  UserData removeFavoriteAudio(String audioId) {
    final newFavorites = favoriteAudios.where((id) => id != audioId).toList();
    return copyWith(favoriteAudios: newFavorites);
  }

  UserData addBookmarkedPost(String postId) {
    final newBookmarks = [...bookmarkedPosts];
    if (!newBookmarks.contains(postId)) {
      newBookmarks.add(postId);
    }
    return copyWith(bookmarkedPosts: newBookmarks);
  }

  UserData removeBookmarkedPost(String postId) {
    final newBookmarks = bookmarkedPosts.where((id) => id != postId).toList();
    return copyWith(bookmarkedPosts: newBookmarks);
  }

  UserData addMyPost(String postId) {
    final newPosts = [...myPostIds];
    if (!newPosts.contains(postId)) {
      newPosts.add(postId);
    }
    return copyWith(myPostIds: newPosts);
  }

  UserData addLikedPost(String postId) {
    final newLikedPosts = [...likedPosts];
    if (!newLikedPosts.contains(postId)) {
      newLikedPosts.add(postId);
    }
    return copyWith(likedPosts: newLikedPosts);
  }

  UserData removeLikedPost(String postId) {
    final newLikedPosts = likedPosts.where((id) => id != postId).toList();
    return copyWith(likedPosts: newLikedPosts);
  }

  bool isAudioFavorite(String audioId) {
    return favoriteAudios.contains(audioId);
  }

  bool isPostBookmarked(String postId) {
    return bookmarkedPosts.contains(postId);
  }

  bool isPostLiked(String postId) {
    return likedPosts.contains(postId);
  }
} 