import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<CategoryModel>>((ref) {
  return CategoryNotifier();
});

const String _customCategoriesKey = 'custom_categories';

class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  late SharedPreferences _prefs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  CategoryNotifier() : super([]) {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    loadCategories('tr');
  }

  Future<void> loadCategories(String language) async {
    try {
      // Firebase'den tüm kategorileri yükle (varsayılan ve paylaşılan)
      final snapshot = await _firestore
          .collection('categories')
          .where('language', isEqualTo: language)
          .get();

      final firebaseCategories = snapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data()))
          .toList();

      // Yerel kayıtlı özel kategorileri yükle
      final customCategories = await _loadCustomCategories(language);
      
      // İndirilmiş kategorileri filtrele
      final downloadedCategories = firebaseCategories
          .where((cat) => cat.isCustom && cat.isDownloaded)
          .toList();

      // Varsayılan kategorileri filtrele
      final defaultCategories = firebaseCategories
          .where((cat) => !cat.isCustom)
          .toList();

      state = [...defaultCategories, ...customCategories, ...downloadedCategories];
    } catch (e) {
      print("category_load_error".tr() + ' $e');
      final customCategories = await _loadCustomCategories(language);
      state = [...customCategories];
    }
  }

  Future<List<CategoryModel>> _loadCustomCategories(String language) async {
    try {
      final String? customCategoriesJson = _prefs.getString(_customCategoriesKey);
      if (customCategoriesJson != null) {
        final List<dynamic> customList = json.decode(customCategoriesJson);
        return customList
            .map((json) => CategoryModel.fromJson(json))
            .where((category) => category.isCustom)
            .toList();
      }
    } catch (e) {
      print("custom_categories_load_error".tr() + ' $e');
    }
    return [];
  }

  Future<void> _saveCustomCategories(List<CategoryModel> categories) async {
    final customCategories = categories.where((cat) => cat.isCustom).toList();
    final customCategoriesJson = json.encode(
      customCategories.map((cat) => cat.toJson()).toList()
    );
    await _prefs.setString(_customCategoriesKey, customCategoriesJson);
  }

  Future<void> addCategory(
    String name,
    List<String> items,
    String language,
    String icon,
  ) async {
    final newCategory = CategoryModel(
      id: const Uuid().v4(),
      name: name,
      icon: icon,
      items: items,
      language: language,
      isCustom: true,
    );
    state = [...state, newCategory];
    await _saveCustomCategories(state);
  }

  Future<void> deleteCategory(String id) async {
    state = state.where((category) => category.id != id).toList();
    await _saveCustomCategories(state);
  }

  Future<void> publishCategory(String id) async {
    // Firebase'e gönderilecek kategoriyi bul
    final categoryToPublish = state.firstWhere((cat) => cat.id == id);
    
    try {
      // Kategori custom değilse yayınlamayı reddet
      if (!categoryToPublish.isCustom) {
        throw "category_not_custom".tr();
      }
      
      // Firebase'e kategoriyi gönder
      await _firestore
          .collection('categories')
          .doc(categoryToPublish.id)
          .set(categoryToPublish.toFirebase());

      // Başarılı olursa listeden kaldır
      state = state.where((category) => category.id != id).toList();
      await _saveCustomCategories(state);
    } catch (e) {
      print("category_publish_error".tr() + ' $e');
      rethrow;
    }
  }

  // Paylaşılan kategorileri getir
  Future<List<CategoryModel>> getSharedCategories(String language) async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('language', isEqualTo: language)
          .where('isCustom', isEqualTo: true) // Sadece paylaşılan özel kategorileri al
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print("shared_categories_load_error".tr() + ' $e');
      return [];
    }
  }

  Future<void> downloadCategory(CategoryModel category) async {
    // Kategoriyi indirilenler listesine ekle
    final downloadedCategory = category.copyWith(isDownloaded: true);
    state = [...state, downloadedCategory];
    await _saveCustomCategories(state);
  }

  // Kategorileri türlerine göre filtreleme metodları
  List<CategoryModel> getDefaultCategories() {
    return state.where((cat) => !cat.isCustom && !cat.isDownloaded).toList();
  }

  List<CategoryModel> getCustomCategories() {
    return state.where((cat) => cat.isCustom).toList();
  }

  List<CategoryModel> getDownloadedCategories() {
    return state.where((cat) => cat.isDownloaded).toList();
  }

  // İndirilebilir kategorileri getir (henüz indirilmemiş paylaşılan kategoriler)
  Future<List<CategoryModel>> getDownloadableCategories(String language) async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('language', isEqualTo: language)
          .where('isCustom', isEqualTo: true)
          .get();

      final downloadableCategories = snapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data()))
          .where((category) => 
            // Henüz indirilmemiş kategorileri filtrele
            !state.any((stateCategory) => 
              stateCategory.id == category.id && stateCategory.isDownloaded
            )
          )
          .toList();

      return downloadableCategories;
    } catch (e) {
      print("downloadable_categories_load_error".tr() + ' $e');
      return [];
    }
  }

  // İndirilmiş kategoriyi cihazdan kaldır
  Future<void> removeDownloadedCategory(String categoryId) async {
    // Kategoriyi state'den kaldır ve isDownloaded'ı false yap
    state = state.where((cat) => cat.id != categoryId).toList();
    // Yerel depolamayı güncelle
    await _saveCustomCategories(state);
  }
} 