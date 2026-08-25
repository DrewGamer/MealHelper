import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../collaboration/data/workspace_repository.dart';
import '../data/ingredient_options_repository.dart';
import '../data/ingredient_sort_notifier.dart';
import '../domain/ingredient_sort_option.dart';

class IngredientManagerScreen extends ConsumerStatefulWidget {
  const IngredientManagerScreen({super.key});

  @override
  ConsumerState<IngredientManagerScreen> createState() => _IngredientManagerScreenState();
}

class _IngredientManagerScreenState extends ConsumerState<IngredientManagerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final optionsAsync = ref.watch(ingredientOptionsStreamProvider);
    final sortOption = ref.watch(ingredientSortProvider);

    final options = optionsAsync.value;
    final proteinCount = options?.proteinSources.length;
    final ingredientCount = options?.ingredients.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
        actions: [
          PopupMenuButton<IngredientSortOption>(
            icon: const Icon(Icons.sort),
            initialValue: sortOption,
            onSelected: (option) {
              ref.read(ingredientSortProvider.notifier).setSortOption(option);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: IngredientSortOption.alphabetical,
                child: Text('Alphabetical'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: proteinCount != null
                  ? 'Protein Sources ($proteinCount)'
                  : 'Protein Sources',
            ),
            Tab(
              text: ingredientCount != null
                  ? 'Ingredients ($ingredientCount)'
                  : 'Ingredients',
            ),
          ],
        ),
      ),
      body: optionsAsync.when(
        data: (loadedOptions) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(
                context,
                items: loadedOptions.proteinSources,
                sortOption: sortOption,
                isProtein: true,
              ),
              _buildList(
                context,
                items: loadedOptions.ingredients,
                sortOption: sortOption,
                isProtein: false,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final isProtein = _tabController.index == 0;
          _showAddDialog(isProtein);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(
    BuildContext context, {
    required List<String> items,
    required IngredientSortOption sortOption,
    required bool isProtein,
  }) {
    final sortedItems = items.applySort(sortOption);

    if (sortedItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No ${isProtein ? 'protein sources' : 'ingredients'} yet. Tap + to add one.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: sortedItems.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = sortedItems[index];
        return ListTile(
          title: Text(item),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _showEditDialog(item, isProtein),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => _showDeleteConfirmDialog(item, isProtein),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddDialog(bool isProtein) async {
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

  Future<void> _showEditDialog(String oldName, bool isProtein) async {
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

  Future<void> _showDeleteConfirmDialog(String item, bool isProtein) async {
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

    if (!mounted) return;

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
