import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/string_extensions.dart';
import '../../auth/data/auth_repository.dart';
import '../../collaboration/data/workspace_repository.dart';
import '../../ingredients/data/ingredient_options_repository.dart';
import '../data/meals_repository.dart';
import '../domain/meal.dart';
import 'widgets/ingredient_picker_dialog.dart';

class MealDetailScreen extends ConsumerStatefulWidget {
  final Meal? meal;

  const MealDetailScreen({super.key, this.meal});

  @override
  ConsumerState<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends ConsumerState<MealDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  String? _selectedProteinSource;
  List<String> _selectedIngredients = [];
  bool _excludeFromAuto = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.meal?.name ?? '');
    _descController = TextEditingController(text: widget.meal?.description ?? '');
    _selectedProteinSource = widget.meal?.proteinSource;
    _selectedIngredients = List.from(widget.meal?.ingredients ?? []);
    _excludeFromAuto = widget.meal?.excludeFromAuto ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveMeal() async {
    if (_formKey.currentState!.validate()) {
      final dbId = ref.read(activeDatabaseIdStreamProvider).value;
      final userId = ref.read(authRepositoryProvider).currentUser?.uid;
      
      if (dbId == null || userId == null) return;

      final repo = ref.read(mealsRepositoryProvider);

      if (widget.meal == null) {
        // Create new
        final newMeal = Meal(
          id: const Uuid().v4(),
          name: _nameController.text,
          description: _descController.text,
          proteinSource: _selectedProteinSource,
          ingredients: _selectedIngredients,
          createdBy: userId,
          excludeFromAuto: _excludeFromAuto,
        );
        await repo.addMeal(dbId, newMeal);
      } else {
        // Update existing
        final updatedMeal = widget.meal!.copyWith(
          name: _nameController.text,
          description: _descController.text,
          proteinSource: _selectedProteinSource,
          ingredients: _selectedIngredients,
          excludeFromAuto: _excludeFromAuto,
        );
        await repo.updateMeal(dbId, updatedMeal);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _deleteMeal() async {
    if (widget.meal != null) {
      final dbId = ref.read(activeDatabaseIdStreamProvider).value;
      if (dbId != null) {
        await ref.read(mealsRepositoryProvider).deleteMeal(dbId, widget.meal!.id);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _showAddIngredientDialog(List<String> availableIngredients) async {
    final selected = await IngredientPickerDialog.show(
      context,
      availableIngredients: availableIngredients,
      initialSelectedIngredients: _selectedIngredients,
    );
    if (selected != null && mounted) {
      setState(() {
        _selectedIngredients = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.meal != null;
    final ingredientOptionsAsync = ref.watch(ingredientOptionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Meal' : 'Add Meal'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteMeal,
            )
        ],
      ),
      body: ingredientOptionsAsync.when(
        data: (options) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    SwitchListTile(
                      title: const Text('Exclude from auto-generation'),
                      contentPadding: EdgeInsets.zero,
                      value: _excludeFromAuto,
                      onChanged: (val) {
                        setState(() {
                          _excludeFromAuto = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    if (options.proteinSources.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Add protein sources in the Ingredients tab',
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Protein Source (optional)'),
                        initialValue: (_selectedProteinSource != null && options.proteinSources.contains(_selectedProteinSource))
                            ? _selectedProteinSource
                            : null,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('None'),
                          ),
                          ...options.proteinSources.sortedAlphabetically().map((protein) {
                            return DropdownMenuItem<String>(
                              value: protein,
                              child: Text(protein),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedProteinSource = value;
                          });
                        },
                      ),
                    
                    const SizedBox(height: 20),
                    
                    Text('Ingredients (optional)', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (options.ingredients.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Add ingredients in the Ingredients tab',
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8.0,
                        children: [
                          ..._selectedIngredients.where((ing) => options.ingredients.contains(ing)).map((ingredient) {
                            return Chip(
                              label: Text(ingredient),
                              onDeleted: () {
                                setState(() {
                                  _selectedIngredients.remove(ingredient);
                                });
                              },
                            );
                          }),
                          ActionChip(
                            label: const Text('+ Add'),
                            onPressed: () => _showAddIngredientDialog(options.ingredients),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveMeal,
                      child: const Text('Save'),
                    )
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text('Error loading options')),
      ),
    );
  }
}
