import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../collaboration/data/workspace_repository.dart';
import '../../home/presentation/home_screen.dart';
import '../data/auth_repository.dart';
import 'welcome_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isAuthenticating = ref.watch(isAuthenticatingProvider);

    // Safety net: auto-reset the authenticating flag when auth state
    // resolves to a valid user. This handles the case where the
    // SettingsScreen is disposed mid-sign-in before its finally block
    // can reset the flag (e.g., guest → Google/Email login).
    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          ref.read(workspaceRepositoryProvider).initializeUserIfNeeded(user.uid, user.email);
        }
        if (user != null && ref.read(isAuthenticatingProvider)) {
          // Auth completed successfully — clear the loading flag.
          ref.read(isAuthenticatingProvider.notifier).reset();
        }
      });
    });

    return authState.when(
      data: (user) {
        if (isAuthenticating) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (user == null) {
          return const WelcomeScreen();
        }
        return const HomeScreen();
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, trace) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
