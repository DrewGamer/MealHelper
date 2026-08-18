import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'collaboration_screen.dart';

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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }
  
  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  Future<String?> _showThreeWayDialog(String title, String content, String option1, String option2) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, 'cancel'), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, 'fresh'), child: Text(option2)),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, 'keep'), child: Text(option1)),
        ],
      )
    );
  }

  Future<void> _handleGoogleFlow(bool isLoginIntent) async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final credential = await ref.read(authRepositoryProvider).getGoogleCredential();
      if (credential == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      if (isLoginIntent) {
        // Direct Login Intent - Optimistic Link
        try {
          await ref.read(authRepositoryProvider).linkWithGoogleCredential(credential);
          
          // If we reach here, the account did NOT exist and was just created/linked.
          if (mounted) setState(() => _isLoading = false);
          final choice = await _showThreeWayDialog(
            'Account Created',
            'No existing account was found for this Google profile, so a new one was created. Would you like to link your guest data to it, or start fresh?',
            'Keep Guest Data',
            'Start Fresh'
          );

          if (choice == 'keep') {
            if (mounted) _showSuccess('Account created and guest data preserved!');
          } else if (choice == 'fresh') {
            if (mounted) setState(() => _isLoading = true);
            final authNotifier = ref.read(isAuthenticatingProvider.notifier);
            final authRepo = ref.read(authRepositoryProvider);
            authNotifier.set(true);
            try {
              await FirebaseAuth.instance.currentUser?.delete();
              await authRepo.signInWithGoogleCredential(credential);
              if (mounted) _showSuccess('Fresh account created!');
            } finally {
              authNotifier.reset();
            }
          } else {
            // Cancel -> undo the creation
            if (mounted) setState(() => _isLoading = true);
            await FirebaseAuth.instance.currentUser?.unlink('google.com');
            await ref.read(authRepositoryProvider).googleSignOut();
            if (mounted) _showSuccess('Cancelled. You are still a guest.');
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
            if (mounted) setState(() => _isLoading = false);
            final confirm = await _showWarningDialog(
              'Account Exists', 
              'This Google account already exists. Logging in will discard your guest data. Proceed?'
            );
            if (confirm == true) {
              if (mounted) setState(() => _isLoading = true);
              final authNotifier = ref.read(isAuthenticatingProvider.notifier);
              final authRepo = ref.read(authRepositoryProvider);
              authNotifier.set(true);
              try {
                await FirebaseAuth.instance.currentUser?.delete();
                await authRepo.signInWithGoogleCredential(credential);
                if (mounted) _showSuccess('Successfully signed in!');
              } finally {
                authNotifier.reset();
              }
            } else {
              await ref.read(authRepositoryProvider).googleSignOut();
            }
          } else {
            if (mounted) _showError(e.message ?? 'An error occurred with Google Sign-In.');
            await ref.read(authRepositoryProvider).googleSignOut();
          }
        }
      } else {
        // Link Intent
        try {
          await ref.read(authRepositoryProvider).linkWithGoogleCredential(credential);
          if (mounted) _showSuccess('Successfully linked Google account! Your meals are saved.');
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
            if (mounted) _showError('This Google account is already registered to someone else.');
          } else {
            if (mounted) _showError(e.message ?? 'An error occurred linking Google account.');
          }
          await ref.read(authRepositoryProvider).googleSignOut();
        }
      }
    } catch (e) {
      if (mounted) _showError('Failed to complete Google flow.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailFlow(bool isLoginIntent) async {
    final title = isLoginIntent ? 'Sign In to Existing Account' : 'Link Email Account';
    final action = isLoginIntent ? 'Sign In' : 'Link';
    
    final result = await _showEmailPasswordDialog(title, action);
    if (result != true) return;

    if (mounted) setState(() => _isLoading = true);
    
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (isLoginIntent) {
        // Direct Login Intent - Optimistic Link
        try {
          await ref.read(authRepositoryProvider).linkWithEmailAndPassword(email, password);
          
          // If we reach here, the account did NOT exist and was just created/linked.
          if (mounted) setState(() => _isLoading = false);
          final choice = await _showThreeWayDialog(
            'Account Created',
            'No existing account was found for this email, so a new one was created. Would you like to link your guest data to it, or start fresh?',
            'Keep Guest Data',
            'Start Fresh'
          );

          if (choice == 'keep') {
            if (mounted) _showSuccess('Account created and guest data preserved!');
          } else if (choice == 'fresh') {
            if (mounted) setState(() => _isLoading = true);
            final authNotifier = ref.read(isAuthenticatingProvider.notifier);
            authNotifier.set(true);
            try {
              await FirebaseAuth.instance.currentUser?.delete();
              await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
              if (mounted) _showSuccess('Fresh account created!');
            } finally {
              authNotifier.reset();
            }
          } else {
            // Cancel -> undo the creation
            if (mounted) setState(() => _isLoading = true);
            await FirebaseAuth.instance.currentUser?.unlink('password');
            if (mounted) _showSuccess('Cancelled. You are still a guest.');
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use' || e.code == 'credential-already-in-use') {
            if (mounted) setState(() => _isLoading = false);
            final confirm = await _showWarningDialog(
              'Account Exists', 
              'This email is already registered. Logging in will discard your guest data. Proceed?'
            );
            if (confirm == true) {
              if (mounted) setState(() => _isLoading = true);
              final authNotifier = ref.read(isAuthenticatingProvider.notifier);
              authNotifier.set(true);
              try {
                await ref.read(authRepositoryProvider).signInWithEmailAndPassword(email, password);
                if (mounted) _showSuccess('Successfully signed in!');
              } on FirebaseAuthException catch (signInError) {
                if (mounted) _showError(signInError.message ?? 'Invalid email or password.');
              } finally {
                authNotifier.reset();
              }
            }
          } else {
            if (mounted) _showError(e.message ?? 'An error occurred with Email Sign-In.');
          }
        }
      } else {
        // Link Intent
        try {
          await ref.read(authRepositoryProvider).linkWithEmailAndPassword(email, password);
          if (mounted) _showSuccess('Successfully linked Email account! Your meals are saved.');
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use' || e.code == 'credential-already-in-use') {
             if (mounted) _showError('This email is already registered to someone else.');
          } else {
            if (mounted) _showError(e.message ?? 'An error occurred linking Email account.');
          }
        }
      }
    } catch (e) {
      if (mounted) _showError('Failed to complete Email flow.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _linkGoogle() => _handleGoogleFlow(false);
  Future<void> _signInGoogle() => _handleGoogleFlow(true);
  Future<void> _linkEmail() => _handleEmailFlow(false);
  Future<void> _signInEmail() => _handleEmailFlow(true);

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
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Collaboration & Workspaces'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CollaborationScreen()),
                  );
                },
              ),
              const Divider(),

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
