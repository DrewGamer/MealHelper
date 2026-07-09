import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      debugPrint('Failed to sign in anonymously: $e');
      return null;
    }
  }

  /// Links the current anonymous account to an Email & Password
  Future<User?> linkWithEmailAndPassword(String email, String password) async {
    try {
      final credential = EmailAuthProvider.credential(email: email, password: password);
      final userCredential = await _auth.currentUser?.linkWithCredential(credential);
      return userCredential?.user;
    } catch (e) {
      debugPrint('Failed to link with email: $e');
      rethrow;
    }
  }

  /// Links the current anonymous account to a Google Account
  Future<User?> linkWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.currentUser?.linkWithCredential(credential);
      return userCredential?.user;
    } catch (e) {
      debugPrint('Failed to link with Google: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
