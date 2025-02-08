class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final List<String> items;
  final bool isCustom;
  final String language;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.items,
    required this.language,
    this.isCustom = false,
  });

  CategoryModel copyWith({
    String? name,
    String? icon,
    List<String>? items,
    bool? isCustom,
    String? language,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      items: items ?? this.items,
      isCustom: isCustom ?? this.isCustom,
      language: language ?? this.language,
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
      'isCustom': false, // Firebase'e gönderirken false olarak işaretliyoruz
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
} 