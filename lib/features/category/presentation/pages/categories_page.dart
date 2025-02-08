import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/category_provider.dart';
import '../widgets/add_category_modal.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('categories_title'.tr()),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
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
                          '${category.items.length} kelime',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (categories.any((c) => c.isCustom)) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kendi Kategorilerim',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount:
                    categories.where((c) => c.isCustom).toList().length,
                itemBuilder: (context, index) {
                  final customCategory =
                      categories.where((c) => c.isCustom).toList()[index];
                  return Card(
                    child: ListTile(
                      leading: Text(customCategory.icon),
                      title: Text(customCategory.name),
                      subtitle: Text(
                          '${customCategory.items.length} kelime'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          ref
                              .read(categoryProvider.notifier)
                              .deleteCategory(customCategory.id);
                        },
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
} 