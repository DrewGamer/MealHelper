import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.userChanges();

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

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint('Failed to sign in with email: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Failed to sign in with Google: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogleCredential(OAuthCredential credential) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Failed to sign in with Google credential: $e');
      rethrow;
    }
  }

  /// Links the current anonymous account to an Email & Password
  Future<UserCredential?> linkWithEmailAndPassword(String email, String password) async {
    try {
      final credential = EmailAuthProvider.credential(email: email, password: password);
      return await _auth.currentUser?.linkWithCredential(credential);
    } catch (e) {
      debugPrint('Failed to link with email: $e');
      rethrow;
    }
  }

  /// Gets Google Credentials for linking/signing in without completing the sign in
  Future<OAuthCredential?> getGoogleCredential() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    return GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  /// Links the current anonymous account to a Google Account using an existing credential
  Future<UserCredential?> linkWithGoogleCredential(OAuthCredential credential) async {
    try {
      return await _auth.currentUser?.linkWithCredential(credential);
    } catch (e) {
      debugPrint('Failed to link with Google: $e');
      rethrow;
    }
  }

  Future<void> googleSignOut() async {
    await _googleSignIn.signOut();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
