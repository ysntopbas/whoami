import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';

class AddCategoryModal extends ConsumerStatefulWidget {
  const AddCategoryModal({super.key});

  @override
  ConsumerState<AddCategoryModal> createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends ConsumerState<AddCategoryModal> {
  final _formKey = GlobalKey<FormState>();
  final _categoryNameController = TextEditingController();
  final List<TextEditingController> _itemControllers = [TextEditingController()];

  @override
  void dispose() {
    _categoryNameController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewItemField() {
    setState(() {
      _itemControllers.add(TextEditingController());
    });
  }

  void _removeItemField(int index) {
    setState(() {
      _itemControllers[index].dispose();
      _itemControllers.removeAt(index);
    });
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final items = _itemControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      ref.read(categoryProvider.notifier).addCategory(
            _categoryNameController.text.trim(),
            items,
            Localizations.localeOf(context).languageCode,
          );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _categoryNameController,
              decoration: InputDecoration(
                labelText: "category_name".tr(),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "category_name_warning".tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ...List.generate(_itemControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _itemControllers[index],
                        decoration: InputDecoration(
                          labelText: '${"name".tr()} ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _removeItemField(index),
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addNewItemField,
              icon: const Icon(Icons.add),
              label:  Text("add_item".tr()),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:  Text("cancel".tr()),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveCategory,
                  child:  Text("save".tr()),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} 