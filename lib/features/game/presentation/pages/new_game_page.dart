import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:whoami/core/utils/orientation_manager.dart';
import 'package:whoami/features/category/domain/models/category_model.dart';
import 'package:whoami/features/category/presentation/providers/category_provider.dart';
import 'package:whoami/features/game/presentation/pages/game_settings_page.dart';

class NewGamePage extends ConsumerStatefulWidget {
  const NewGamePage({super.key});

  @override
  ConsumerState<NewGamePage> createState() => _NewGamePageState();
}

class _NewGamePageState extends ConsumerState<NewGamePage> {
  String _searchQuery = '';
  List<CategoryModel> _allCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    OrientationManager.forcePortrait();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    OrientationManager.forcePortrait();
    _loadAllCategories();
  }

  Future<void> _loadAllCategories() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      // Firebase'den tüm kategorileri çek
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('language', isEqualTo: context.locale.languageCode)
          .get();

      if (!mounted) return;

      setState(() {
        _allCategories = snapshot.docs
            .map((doc) => CategoryModel.fromJson(doc.data()))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("categories_load_error".tr())),
      );
    }
  }

  List<CategoryModel> _getFilteredCategories(List<CategoryModel> categories) {
    if (_searchQuery.isEmpty) return categories;
    return categories
        .where((category) =>
            category.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Local'den özel kategorileri al
    final myCategories = ref.watch(categoryProvider)
        .where((category) => category.isCustom)
        .toList();
    
    final filteredAllCategories = _getFilteredCategories(_allCategories);
    final filteredMyCategories = _getFilteredCategories(myCategories);

    return Scaffold(
      appBar: AppBar(
        title: Text('new_game'.tr()),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'search_categories'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    slivers: [
                      // Tüm Kategoriler Başlığı
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'all_categories'.tr(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                      // Tüm Kategoriler Grid
                      SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final category = filteredAllCategories[index];
                            return _buildCategoryCard(category);
                          },
                          childCount: filteredAllCategories.length,
                        ),
                      ),
                      // Kendi Kategorilerim Başlığı
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'own_categories'.tr(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                      // Kendi Kategorilerim Grid
                      SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final category = filteredMyCategories[index];
                            return _buildCategoryCard(category);
                          },
                          childCount: filteredMyCategories.length,
                        ),
                      ),
                      const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameSettingsPage(category: category),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${category.items.length} ${"word".tr()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 