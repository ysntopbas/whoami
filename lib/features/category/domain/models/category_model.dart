class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final List<String> items;
  final bool isCustom;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.items,
    this.isCustom = false,
  });

  CategoryModel copyWith({
    String? name,
    String? icon,
    List<String>? items,
    bool? isCustom,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      items: items ?? this.items,
      isCustom: isCustom ?? this.isCustom,
    );
  }
} 