import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';

class CollaborationScreen extends ConsumerStatefulWidget {
  const CollaborationScreen({super.key});

  @override
  ConsumerState<CollaborationScreen> createState() => _CollaborationScreenState();
}

class _CollaborationScreenState extends ConsumerState<CollaborationScreen> {
  final _inviteCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  Future<void> _joinDatabase(String uid) async {
    final code = _inviteCodeController.text.trim();
    if (code.isEmpty) return;
    if (code == uid) {
      _showError("You cannot join your own database this way.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(databaseRepositoryProvider).joinDatabase(uid, code);
      _showSuccess('Successfully joined database!');
      _inviteCodeController.clear();
    } catch (e) {
      _showError('Failed to join database. Please check the code.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _switchToMyDatabase(String uid) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(databaseRepositoryProvider).switchActiveDatabase(uid, uid);
      _showSuccess('Switched back to your personal database.');
    } catch (e) {
      _showError('Failed to switch database.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final activeDbIdAsync = ref.watch(activeDatabaseIdStreamProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Collaboration')),
        body: const Center(child: Text('Not logged in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Collaboration')),
      body: activeDbIdAsync.when(
        data: (activeDbId) {
          final isUsingOwnDb = activeDbId == user.uid;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              DatabaseNameSection(uid: user.uid),
              const Divider(height: 48),
              const Text(
                'Share Your Database',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Give this code to someone else so they can join your database:'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        user.uid,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: user.uid));
                      _showSuccess('Copied to clipboard');
                    },
                  ),
                ],
              ),
              const Divider(height: 48),
              const Text(
                'Join a Database',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Enter an invite code to access someone else\'s database:'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inviteCodeController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Invite Code',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _joinDatabase(user.uid),
                    child: const Text('Join'),
                  ),
                ],
              ),
              const Divider(height: 48),
              const Text(
                'Active Workspace',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ref.watch(databaseNameProvider(activeDbId ?? user.uid)).when(
                data: (dbName) => Text('You are currently viewing: $dbName'),
                loading: () => const Text('You are currently viewing: Loading...'),
                error: (e, st) => const Text('You are currently viewing: Unknown Database'),
              ),
              if (!isUsingOwnDb) ...[
                const SizedBox(height: 8),
                Text('Active Database ID:\n$activeDbId', style: const TextStyle(fontFamily: 'monospace', color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _switchToMyDatabase(user.uid),
                  icon: const Icon(Icons.home),
                  label: const Text('Return to My Personal Database'),
                ),
              ],
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

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
      await ref.read(databaseRepositoryProvider).updateDatabaseName(widget.uid, newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database name updated!'), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update name.'), backgroundColor: Colors.red)
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
