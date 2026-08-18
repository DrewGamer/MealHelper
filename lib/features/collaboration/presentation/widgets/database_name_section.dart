import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/workspace_repository.dart';

class DatabaseNameSection extends ConsumerStatefulWidget {
  final String uid;
  const DatabaseNameSection({super.key, required this.uid});

  @override
  ConsumerState<DatabaseNameSection> createState() => _DatabaseNameSectionState();
}

class _DatabaseNameSectionState extends ConsumerState<DatabaseNameSection> {
  final _nameController = TextEditingController();
  bool _isUpdating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isUpdating = true);
    try {
      await ref.read(workspaceRepositoryProvider).updateDatabaseName(widget.uid, newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database name updated!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update name.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbNameAsync = ref.watch(databaseNameProvider(widget.uid));

    ref.listen<AsyncValue<String>>(databaseNameProvider(widget.uid), (previous, next) {
      if (next.hasValue && previous?.value != next.value) {
        if (_nameController.text.isEmpty || _nameController.text == previous?.value) {
          _nameController.text = next.value!;
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Name Your Database',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Set a custom name for your personal database:'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: dbNameAsync.when(
                data: (name) {
                  if (_nameController.text.isEmpty) {
                    _nameController.text = name;
                  }
                  return TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Database Name',
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Error: $e'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isUpdating ? null : _updateName,
              child: const Text('Update'),
            ),
          ],
        ),
      ],
    );
  }
}
