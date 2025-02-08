import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/category_model.dart';

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<CategoryModel>>((ref) {
  return CategoryNotifier();
});

class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  CategoryNotifier() : super([]) {
    loadCategories('tr'); // Varsayılan olarak Türkçe kategorileri yükle
  }

  Future<void> loadCategories(String language) async {
    try {
      final jsonString = await rootBundle.loadString('assets/categories/$language.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      final categories = jsonList
          .map((json) => CategoryModel.fromJson(json))
          .toList();
      
      // Mevcut dildeki özel kategorileri al
      final customCategories = state.where((cat) => 
        cat.isCustom && cat.language == language
      ).toList();
      
      state = [...categories, ...customCategories];
    } catch (e) {
      print('Kategoriler yüklenirken hata oluştu: $e');
      // Hata durumunda mevcut özel kategorileri koru
      final customCategories = state.where((cat) => cat.isCustom).toList();
      state = [...customCategories];
    }
  }

  void addCategory(String name, List<String> items, String language) {
    final newCategory = CategoryModel(
      id: const Uuid().v4(),
      name: name,
      icon: '📝',
      items: items,
      language: language,
      isCustom: true,
    );
    state = [...state, newCategory];
  }

  void deleteCategory(String id) {
    state = state.where((category) => category.id != id).toList();
  }
} 