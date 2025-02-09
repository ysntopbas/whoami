import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:whoami/core/utils/orientation_manager.dart';
import 'package:whoami/features/category/domain/models/category_model.dart';
import '../providers/category_provider.dart';
import '../widgets/add_category_modal.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
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

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final defaultCategories = categories.where((cat) => !cat.isCustom && !cat.isDownloaded).toList();
    final customCategories = categories.where((cat) => cat.isCustom && !cat.isDownloaded).toList();
    final downloadedCategories = categories.where((cat) => cat.isDownloaded).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('categories_title'.tr()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Varsayılan Kategoriler
            _buildSectionTitle('all_categories'.tr()),
            _buildCategoryGrid(defaultCategories),

            // Kendi Kategorilerim
            if (customCategories.isNotEmpty) ...[
              _buildSectionTitle('own_categories'.tr()),
              _buildCustomCategoryList(customCategories),
            ],

            // İndirilmiş Kategoriler
            if (downloadedCategories.isNotEmpty) ...[
              _buildSectionTitle('downloaded_categories'.tr()),
              _buildCategoryGrid(downloadedCategories, isDownloaded: true),
            ],

            // İndirilebilir Kategoriler
            _buildSectionTitle('downloadable_categories'.tr()),
            FutureBuilder<List<CategoryModel>>(
              future: ref.read(categoryProvider.notifier).getDownloadableCategories(context.locale.languageCode),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return _buildDownloadableCategoryGrid(snapshot.data!);
                }
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('no_downloadable_categories'.tr()),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddCategoryModal(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDownloadableCategoryGrid(List<CategoryModel> categories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          color: Colors.grey[100], // Soluk ton
          child: InkWell(
            onTap: () async {
              try {
                await ref.read(categoryProvider.notifier).downloadCategory(category);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('category_downloaded'.tr())),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('category_download_error'.tr())),
                  );
                }
              }
            },
            child: Stack(
              children: [
                Padding(
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.download,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(List<CategoryModel> categories, {bool isDownloaded = false}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          child: Stack(
            children: [
              InkWell(
                onTap: () {
                  // TODO: Kategori detay sayfasına git
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
              if (isDownloaded)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('remove_category'.tr()),
                          content: Text('remove_category_confirm'.tr()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('cancel'.tr()),
                            ),
                            TextButton(
                              onPressed: () {
                                ref.read(categoryProvider.notifier)
                                    .removeDownloadedCategory(category.id);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('category_removed'.tr()),
                                  ),
                                );
                              },
                              child: Text(
                                'remove'.tr(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomCategoryList(List<CategoryModel> categories) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final customCategory = categories[index];
        return Card(
          child: ListTile(
            leading: Text(customCategory.icon),
            title: Text(customCategory.name),
            subtitle: Text(
                '${customCategory.items.length} ${"word".tr()}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.publish),
                  onPressed: () => _showPublishDialog(
                    context,
                    ref,
                    customCategory,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    ref
                        .read(categoryProvider.notifier)
                        .deleteCategory(customCategory.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPublishDialog(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("publish_warning_title".tr()),
          content: Text("publish_warning_message".tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("no".tr()),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  // Yükleniyor göster
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("category_publish_loading".tr())),
                  );
                  
                  await ref.read(categoryProvider.notifier).publishCategory(category.id);
                  
                  // Başarılı mesajı göster
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("category_publish_success".tr())),
                    );
                  }
                } catch (e) {
                  // Hata mesajı göster
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("error".tr()),
                        content: Text(e.toString()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("ok".tr()),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              child: Text("yes".tr()),
            ),
          ],
        );
      },
    );
  }
} 