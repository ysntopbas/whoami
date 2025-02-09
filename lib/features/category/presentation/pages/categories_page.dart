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
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryCard(categories[index], isDownloadable: true);
      },
    );
  }

  Widget _buildCategoryCard(CategoryModel category, {bool isDownloadable = false}) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDownloadable ? Colors.grey[50] : Colors.white,
        ),
        child: Column(
          children: [
            Expanded(
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Like butonu ve sayısı
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        iconSize: 20,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                        icon: Icon(
                          category.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: category.isLiked ? Colors.blue : Colors.grey,
                        ),
                        onPressed: () {
                          ref.read(categoryProvider.notifier).toggleLike(category.id);
                        },
                      ),
                      Text(
                        category.likes.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  // Dislike butonu ve sayısı
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        iconSize: 20,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                        icon: Icon(
                          category.isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                          color: category.isDisliked ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          ref.read(categoryProvider.notifier).toggleDislike(category.id);
                        },
                      ),
                      Text(
                        category.dislikes.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  // İndirme/Silme butonu
                  if (isDownloadable)
                    IconButton(
                      iconSize: 20,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      icon: const Icon(Icons.download),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () async {
                        await ref.read(categoryProvider.notifier).downloadCategory(category);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('category_downloaded'.tr())),
                          );
                        }
                      },
                    )
                  else if (category.isDownloaded)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          iconSize: 20,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                          icon: const Icon(Icons.delete_outline),
                          color: Theme.of(context).colorScheme.error,
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
                                        SnackBar(content: Text('category_removed'.tr())),
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
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          elevation: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Ana içerik
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
                      // Silme butonu (eğer indirilmiş kategoriyse)
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
                ),
                // Like/Dislike bölümü
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Like butonu ve sayısı
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            iconSize: 20,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                            icon: Icon(
                              category.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                              color: category.isLiked ? Colors.blue : Colors.grey,
                            ),
                            onPressed: () {
                              ref.read(categoryProvider.notifier).toggleLike(category.id);
                            },
                          ),
                          Text(
                            category.likes.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      // Dislike butonu ve sayısı
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            iconSize: 20,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                            icon: Icon(
                              category.isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                              color: category.isDisliked ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              ref.read(categoryProvider.notifier).toggleDislike(category.id);
                            },
                          ),
                          Text(
                            category.dislikes.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
        return _buildCategoryCard(customCategory);
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