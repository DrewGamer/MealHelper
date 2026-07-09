import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/meal.dart';
import '../../providers.dart';

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
  late TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.meal?.name ?? '');
    _descController = TextEditingController(text: widget.meal?.description ?? '');
    _tagsController = TextEditingController(text: widget.meal?.tags.join(', ') ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _saveMeal() async {
    if (_formKey.currentState!.validate()) {
      final dbId = ref.read(activeDatabaseIdProvider);
      final userId = ref.read(authRepositoryProvider).currentUser?.uid;
      
      if (dbId == null || userId == null) return;

      final repo = ref.read(databaseRepositoryProvider);
      final tags = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      if (widget.meal == null) {
        // Create new
        final newMeal = Meal(
          id: const Uuid().v4(),
          name: _nameController.text,
          description: _descController.text,
          tags: tags,
          createdBy: userId,
        );
        await repo.addMeal(dbId, newMeal);
      } else {
        // Update existing
        final updatedMeal = widget.meal!.copyWith(
          name: _nameController.text,
          description: _descController.text,
          tags: tags,
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
      final dbId = ref.read(activeDatabaseIdProvider);
      if (dbId != null) {
        await ref.read(databaseRepositoryProvider).deleteMeal(dbId, widget.meal!.id);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.meal != null;

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMeal,
                child: const Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
