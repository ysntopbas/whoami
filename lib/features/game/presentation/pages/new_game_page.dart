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

  @override
  void initState() {
    super.initState();
    OrientationManager.forcePortrait();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    OrientationManager.forcePortrait();
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
    // Categories provider'dan kategorileri al
    final allCategories = ref.watch(categoryProvider);
    
    // Kategorileri filtrele
    final defaultCategories = allCategories.where((cat) => !cat.isCustom && !cat.isDownloaded).toList();
    final customCategories = allCategories.where((cat) => cat.isCustom && !cat.isDownloaded).toList();
    final downloadedCategories = allCategories.where((cat) => cat.isDownloaded).toList();

    // Arama filtresini uygula
    final filteredDefaultCategories = _getFilteredCategories(defaultCategories);
    final filteredCustomCategories = _getFilteredCategories(customCategories);
    final filteredDownloadedCategories = _getFilteredCategories(downloadedCategories);

    return Scaffold(
      appBar: AppBar(
        title: Text('new_game_title'.tr()),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'search_categories'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          // Kategori Listeleri
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Varsayılan Kategoriler
                if (filteredDefaultCategories.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'all_categories'.tr(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCategoryCard(filteredDefaultCategories[index]),
                      childCount: filteredDefaultCategories.length,
                    ),
                  ),
                ],

                // Kendi Kategorilerim
                if (filteredCustomCategories.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'own_categories'.tr(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCategoryCard(filteredCustomCategories[index]),
                      childCount: filteredCustomCategories.length,
                    ),
                  ),
                ],

                // İndirilmiş Kategoriler
                if (filteredDownloadedCategories.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'downloaded_categories'.tr(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCategoryCard(filteredDownloadedCategories[index]),
                      childCount: filteredDownloadedCategories.length,
                    ),
                  ),
                ],

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