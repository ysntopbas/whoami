import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:whoami/features/category/domain/models/category_model.dart';
import '../providers/category_provider.dart';
import '../widgets/add_category_modal.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // initState benzeri bir etki için
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).loadCategories(context.locale.languageCode);
    });

    // Dil değişikliğini dinle
    ref.listen<Locale>(
      Provider((ref) => context.locale),
      (previous, next) {
        if (previous?.languageCode != next.languageCode) {
          ref.read(categoryProvider.notifier).loadCategories(next.languageCode);
        }
      },
    );

    final categories = ref.watch(categoryProvider);
    final defaultCategories = categories.where((c) => !c.isCustom).toList();
    final customCategories = categories.where((c) => c.isCustom).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('categories_title'.tr()),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Default Categories Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: defaultCategories.length,
              itemBuilder: (context, index) {
                final category = defaultCategories[index];
                return Card(
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      // TODO: Kategori detay sayfasına git
                    },
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
                        ),
                        Text(
                          '${category.items.length} ${"word".tr()}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Custom Categories Section
          if (customCategories.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "own_categories".tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: customCategories.length,
                itemBuilder: (context, index) {
                  final customCategory = customCategories[index];
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
              ),
            ),
          ],
        ],
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