import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../domain/models/ingredient_options.dart';

class IngredientManagerScreen extends ConsumerWidget {
  const IngredientManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(ingredientOptionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
      ),
      body: optionsAsync.when(
        data: (options) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSection(
                context,
                ref,
                title: 'PROTEIN SOURCES',
                items: options.proteinSources,
                isProtein: true,
              ),
              const SizedBox(height: 24.0),
              _buildSection(
                context,
                ref,
                title: 'INGREDIENTS',
                items: options.ingredients,
                isProtein: false,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required List<String> items,
    required bool isProtein,
  }) {
    // Sort items alphabetically
    final sortedItems = List<String>.from(items)..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8.0),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              if (sortedItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Tap + to add your first ${isProtein ? 'protein source' : 'ingredient'}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              for (final item in sortedItems)
                ListTile(
                  title: Text(item),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showEditDialog(context, ref, item, isProtein),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => _showDeleteConfirmDialog(context, ref, item, isProtein),
                      ),
                    ],
                  ),
                ),
              if (sortedItems.isNotEmpty)
                const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.add),
                title: Text('Add ${isProtein ? 'Protein Source' : 'Ingredient'}'),
                onTap: () => _showAddDialog(context, ref, isProtein),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref, bool isProtein) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${isProtein ? 'Protein Source' : 'Ingredient'}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final dbId = ref.read(activeDatabaseIdStreamProvider).value;
      if (dbId == null) return;

      final repo = ref.read(ingredientOptionsRepositoryProvider);
      if (isProtein) {
        await repo.addProteinSource(dbId, result);
      } else {
        await repo.addIngredient(dbId, result);
      }
    }
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, String oldName, bool isProtein) async {
    final controller = TextEditingController(text: oldName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${isProtein ? 'Protein Source' : 'Ingredient'}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != oldName) {
      final dbId = ref.read(activeDatabaseIdStreamProvider).value;
      if (dbId == null) return;

      final repo = ref.read(ingredientOptionsRepositoryProvider);
      if (isProtein) {
        await repo.renameProteinSource(dbId, oldName, result);
      } else {
        await repo.renameIngredient(dbId, oldName, result);
      }
    }
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, String item, bool isProtein) async {
    final dbId = ref.read(activeDatabaseIdStreamProvider).value;
    if (dbId == null) return;

    final repo = ref.read(ingredientOptionsRepositoryProvider);
    
    int count = 0;
    try {
      if (isProtein) {
        count = await repo.getAffectedMealsCountByProtein(dbId, item);
      } else {
        count = await repo.getAffectedMealsCountByIngredient(dbId, item);
      }
    } catch (e) {
      // Ignore count fetch errors
    }

    if (!context.mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete?'),
        content: count > 0
            ? Text("'$item' is used in $count meal(s). Deleting it will remove it from those meals. Are you sure?")
            : Text("Delete '$item'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (isProtein) {
        await repo.removeProteinSource(dbId, item);
      } else {
        await repo.removeIngredient(dbId, item);
      }
    }
  }
}
