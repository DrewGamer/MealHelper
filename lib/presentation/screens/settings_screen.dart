import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }
  
  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  Future<void> _linkGoogle() async {
    setState(() => _isLoading = true);
    try {
      final user = await ref.read(authRepositoryProvider).linkWithGoogle();
      if (user != null) {
        _showSuccess('Successfully linked Google account!');
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'An error occurred linking Google.');
    } catch (e) {
      _showError('Failed to link account.');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _linkEmail() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Link Email Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Link'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(() => _isLoading = true);
      try {
        final user = await ref.read(authRepositoryProvider).linkWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (user != null) {
          _showSuccess('Successfully linked Email account!');
        }
      } on FirebaseAuthException catch (e) {
        _showError(e.message ?? 'An error occurred linking Email.');
      } catch (e) {
        _showError('Failed to link account.');
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not signed in.'));
          }

          final isAnonymous = user.isAnonymous;
          final providerData = user.providerData;
          final providers = providerData.map((e) => e.providerId).join(', ');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(isAnonymous ? 'Anonymous User' : (user.email ?? 'Linked Account')),
                subtitle: Text('Providers: ${providers.isEmpty ? 'None' : providers}'),
              ),
              const Divider(),
              if (isAnonymous) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Secure your account data by linking a provider:'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _linkGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 32),
                  label: const Text('Link Google Account'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _linkEmail,
                  icon: const Icon(Icons.email),
                  label: const Text('Link Email & Password'),
                ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Your account is safely linked to a permanent provider.', style: TextStyle(color: Colors.green)),
                ),
              ],
              if (_isLoading) const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
