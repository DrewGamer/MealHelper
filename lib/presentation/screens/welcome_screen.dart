import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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

  Future<void> _signInGuest() async {
    final authNotifier = ref.read(isAuthenticatingProvider.notifier);
    authNotifier.set(true);
    try {
      await ref.read(authRepositoryProvider).signInAnonymously();
    } catch (e) {
      _showError('Failed to sign in as guest.');
    }
    authNotifier.reset();
  }

  Future<void> _signInGoogle() async {
    final authNotifier = ref.read(isAuthenticatingProvider.notifier);
    authNotifier.set(true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Error signing in.');
    } catch (e) {
      _showError('Failed to sign in with Google.');
    }
    authNotifier.reset();
  }

  Future<void> _signInEmail() async {
    final result = await _showEmailPasswordDialog('Sign In with Email', 'Sign In');
    if (result == true) {
      final authNotifier = ref.read(isAuthenticatingProvider.notifier);
      authNotifier.set(true);
      try {
        await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } on FirebaseAuthException catch (e) {
        _showError(e.message ?? 'Invalid email or password.');
      } catch (e) {
        _showError('Failed to sign in with Email.');
      }
      authNotifier.reset();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.restaurant_menu, size: 80, color: Colors.green),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to Meal Helper',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Plan your meals and organize your week.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _signInGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 32),
                  label: const Text('Log In with Google', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _signInEmail,
                  icon: const Icon(Icons.email),
                  label: const Text('Log In with Email', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 32),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('OR', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _signInGuest,
                  child: const Text('Continue as Guest', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
