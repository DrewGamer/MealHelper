import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/firebase_options.dart';
import 'providers.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  
  runApp(const ProviderScope(child: MealHelperApp()));
}

class MealHelperApp extends ConsumerWidget {
  const MealHelperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Meal Helper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

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

