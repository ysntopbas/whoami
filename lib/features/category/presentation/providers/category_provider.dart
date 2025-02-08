import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/category_model.dart';

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<CategoryModel>>((ref) {
  return CategoryNotifier();
});

class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  CategoryNotifier()
      : super([
          // Varsayılan kategoriler
          CategoryModel(
            id: '1',
            name: 'Hayvanlar',
            icon: '🐾',
            items: ['Aslan', 'Kaplan', 'Fil'],
          ),
          CategoryModel(
            id: '2',
            name: 'Meslekler',
            icon: '👨‍💼',
            items: ['Doktor', 'Öğretmen', 'Mühendis'],
          ),
        ]);

  void addCategory(String name, List<String> items) {
    final newCategory = CategoryModel(
      id: const Uuid().v4(),
      name: name,
      icon: '📝', // Varsayılan icon
      items: items,
      isCustom: true,
    );
    state = [...state, newCategory];
  }

  void deleteCategory(String id) {
    state = state.where((category) => category.id != id).toList();
  }
} 