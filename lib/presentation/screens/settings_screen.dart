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
  bool _obscurePassword = true;

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

  Future<void> _signInGoogle() async {
    final confirm = await _showWarningDialog('Sign In', 'This will discard your current anonymous meals. Proceed?');
    if (confirm != true) return;

    setState(() => _isLoading = true);
    ref.read(isAuthenticatingProvider.notifier).state = true;
    try {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (user != null) _showSuccess('Successfully signed in!');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Error signing in.');
    } catch (e) {
      _showError('Failed to sign in.');
    }
    ref.read(isAuthenticatingProvider.notifier).state = false;
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _linkEmail() async {
    final result = await _showEmailPasswordDialog('Link Email Account', 'Link');
    if (result == true) {
      setState(() => _isLoading = true);
      try {
        final user = await ref.read(authRepositoryProvider).linkWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (user != null) _showSuccess('Successfully linked Email account!');
      } on FirebaseAuthException catch (e) {
        _showError(e.message ?? 'An error occurred linking Email.');
      } catch (e) {
        _showError('Failed to link account.');
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInEmail() async {
    final confirm = await _showWarningDialog('Sign In', 'This will discard your current anonymous meals. Proceed?');
    if (confirm != true) return;

    final result = await _showEmailPasswordDialog('Sign In to Existing Account', 'Sign In');
    if (result == true) {
      setState(() => _isLoading = true);
      ref.read(isAuthenticatingProvider.notifier).state = true;
      try {
        final user = await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (user != null) _showSuccess('Successfully signed in!');
      } on FirebaseAuthException catch (e) {
        _showError(e.message ?? 'Invalid email or password.');
      } catch (e) {
        _showError('Failed to sign in.');
      }
      ref.read(isAuthenticatingProvider.notifier).state = false;
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showWarningDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Proceed')),
        ],
      )
    );
  }

  Future<bool?> _showEmailPasswordDialog(String title, String actionText) async {
    _emailController.clear();
    _passwordController.clear();
    _obscurePassword = true;
    
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
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
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setDialogState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
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
                  child: Text(actionText),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    await ref.read(authRepositoryProvider).signOut();
    if (mounted) setState(() => _isLoading = false);
    _showSuccess('Signed out successfully.');
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
          final providers = providerData.map((e) => e.providerId).toList();
          
          final hasGoogle = providers.contains('google.com');
          final hasPassword = providers.contains('password');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(isAnonymous ? 'Anonymous User' : (user.email ?? 'Linked Account')),
                subtitle: Text('Providers: ${providers.isEmpty ? 'None' : providers.join(', ')}'),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Upgrade & Link Account', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              if (!hasGoogle) ...[
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _linkGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 32),
                  label: const Text('Link Google Account'),
                ),
                const SizedBox(height: 8),
              ],
              if (!hasPassword) ...[
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _linkEmail,
                  icon: const Icon(Icons.email),
                  label: const Text('Link Email & Password'),
                ),
                const SizedBox(height: 8),
              ],
              if (isAnonymous) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Log In to Existing Account', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87),
                  onPressed: _isLoading ? null : _signInGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 32),
                  label: const Text('Log In with Google'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87),
                  onPressed: _isLoading ? null : _signInEmail,
                  icon: const Icon(Icons.email),
                  label: const Text('Log In with Email'),
                ),
              ],
              if (!isAnonymous) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Account Management', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100, foregroundColor: Colors.red.shade900),
                  onPressed: _isLoading ? null : _signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
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
