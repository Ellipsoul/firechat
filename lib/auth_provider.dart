import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider {
  final googleSignIn = GoogleSignIn(); // Instantiate Google Sign In

  // Getter for the Google Sign In account
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!; // Exclamation = Non-nullable

  // Signing in
  Future<void> googleLogin() async {
    try {
      final googleUser = await GoogleSignIn().signIn(); // Sign in popup

      if (googleUser == null) return; // Escape if not authenticated

      _user = googleUser; // If successful, set the _user variable

      // Then create the credentials for Firebase
      final googleAuth = await googleUser.authentication;
      final authCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      // Use credentials to authenticate into Firebase
      await FirebaseAuth.instance.signInWithCredential(authCredential);
      // Catch the authentication error
    } on FirebaseAuthException catch (e) {
      AlertDialog(
        title: const Text("Authentication Error"),
        content: Text("Failed to sign in with Google: $e.message"),
      );
    }
  }

  // Signing out
  Future<void> signOut() async {
    // Disconnect from both Google and Firebase authentication
    await GoogleSignIn().disconnect();
    await FirebaseAuth.instance.signOut();
  }
}
