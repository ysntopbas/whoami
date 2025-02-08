import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;

class AddCategoryModal extends ConsumerStatefulWidget {
  const AddCategoryModal({super.key});

  @override
  ConsumerState<AddCategoryModal> createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends ConsumerState<AddCategoryModal> {
  final _formKey = GlobalKey<FormState>();
  final _categoryNameController = TextEditingController();
  final _itemsController = TextEditingController();
  String _selectedEmoji = '📝';

  @override
  void dispose() {
    _categoryNameController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          child: EmojiPicker(
            onEmojiSelected: (category, emoji) {
              setState(() {
                _selectedEmoji = emoji.emoji;
              });
              Navigator.pop(context);
            },
            textEditingController: TextEditingController(),
            config: Config(
              replaceEmojiOnLimitExceed: false,
              columns: 7,
              emojiSizeMax: 32.0 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.30 : 1.0),
              verticalSpacing: 0,
              horizontalSpacing: 0,
              initCategory: Category.SMILEYS,
              bgColor: Theme.of(context).scaffoldBackgroundColor,
              indicatorColor: Theme.of(context).colorScheme.primary,
              iconColor: Colors.grey,
              iconColorSelected: Theme.of(context).colorScheme.primary,
              backspaceColor: Theme.of(context).colorScheme.primary,
              recentsLimit: 28,
              noRecents: Text(
                'no_recents'.tr(),
                style: const TextStyle(fontSize: 20, color: Colors.black26),
                textAlign: TextAlign.center,
              ),
              categoryIcons: const CategoryIcons(),
              buttonMode: ButtonMode.MATERIAL,
            ),
          ),
        );
      },
    );
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      // Her satırı ayrı bir öğe olarak al ve boş satırları filtrele
      final items = _itemsController.text
          .split('\n')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();

      if (items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('items_empty_warning'.tr())),
        );
        return;
      }

      ref.read(categoryProvider.notifier).addCategory(
            _categoryNameController.text.trim(),
            items,
            Localizations.localeOf(context).languageCode,
            _selectedEmoji,
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
            InkWell(
              onTap: _showEmojiPicker,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Text(
                  _selectedEmoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryNameController,
              decoration: InputDecoration(
                labelText: "category_name".tr(),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "category_name_warning".tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _itemsController,
              decoration: InputDecoration(
                labelText: "category_items".tr(),
                hintText: "category_items_hint".tr(),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "category_items_warning".tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("cancel".tr()),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveCategory,
                  child: Text("save".tr()),
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