class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final List<String> items;
  final bool isCustom;
  final bool isDownloaded;
  final String language;
  final int likes;
  final bool isLiked;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.items,
    required this.language,
    this.isCustom = false,
    this.isDownloaded = false,
    this.likes = 0,
    this.isLiked = false,
  });

  CategoryModel copyWith({
    String? name,
    String? icon,
    List<String>? items,
    bool? isCustom,
    bool? isDownloaded,
    String? language,
    int? likes,
    bool? isLiked,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      items: items ?? this.items,
      isCustom: isCustom ?? this.isCustom,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      language: language ?? this.language,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      items: List<String>.from(json['items'] as List),
      language: json['language'] as String,
      isCustom: json['isCustom'] as bool? ?? false,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      likes: json['likes'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'items': items,
      'language': language,
      'isCustom': isCustom,
      'isDownloaded': isDownloaded,
      'likes': likes,
      'isLiked': isLiked,
    };
  }

  // Firebase'e gönderilecek format için toFirebase metodu
  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'items': items,
      'language': language,
      'isCustom': true, // Paylaşılan kategoriler true olarak işaretleniyor
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
} 