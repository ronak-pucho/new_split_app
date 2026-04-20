import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/MainScreen.dart';
import 'package:we_spilit/admin_base/AdminDashboard.dart';
import 'package:we_spilit/Screen/InactiveAccountScreen.dart';
import 'package:we_spilit/provider/admin_provider.dart';
import 'package:we_spilit/provider/friends_provider.dart';
import 'package:we_spilit/provider/user_provider.dart';

class AuthenticateProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─────────────────────────────────────────────
  // 🔹 Create account with email
  // ─────────────────────────────────────────────
  Future<User?> createEmailAccount(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  // ─────────────────────────────────────────────
  // 🔹 Sign in with email & password
  // ─────────────────────────────────────────────
  Future<void> signInEmailPassword(BuildContext context, String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!context.mounted) return;

      final user = credential.user;
      if (user == null) return;

      final friendsProvider = context.read<FriendsProvider>();
      final userProvider = context.read<UserProvider>();
      final adminProvider = context.read<AdminProvider>();

      // Fetch user data
      await userProvider.fetchCurrentUser();

      // 🔴 ADMIN CHECK (USER TYPE BASED)
      final isAdmin = userProvider.currentUser?.userType == 'admin';

      if (isAdmin) {
        // Admin logging
        adminProvider.logAdminLogin(user.uid, user.email);

        // Fetch all users for admin panel
        await adminProvider.fetchAllUsers();

        if (!context.mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
          (route) => false,
        );
      } else {
        // Normal user logging
        adminProvider.logUserAction(user.uid, user.email, 'user_login');

        final isInactive = userProvider.currentUser?.status == 'inactive';

        if (isInactive) {
          if (!context.mounted) return;

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const InactiveAccountScreen()),
            (route) => false,
          );
        } else {
          // Load friends data
          await friendsProvider.getAllFriends();

          if (!context.mounted) return;

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => MainScreen()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // 🔴 Error handling
      String message = "Login failed";

      if (e.code == 'user-not-found') {
        message = "No user found with this email";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password";
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  // 🔹 Google Sign-In
  // ─────────────────────────────────────────────
  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null || !context.mounted) return;

      final userProvider = context.read<UserProvider>();
      final friendsProvider = context.read<FriendsProvider>();

      await userProvider.fetchCurrentUser();

      final isAdmin = userProvider.currentUser?.userType == 'admin';

      if (isAdmin) {
        await context.read<AdminProvider>().fetchAllUsers();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
          (route) => false,
        );
      } else {
        await friendsProvider.getAllFriends();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
    }
  }

  // ─────────────────────────────────────────────
  // 🔹 Reset Password
  // ─────────────────────────────────────────────
  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─────────────────────────────────────────────
  // 🔹 Logout
  // ─────────────────────────────────────────────
  Future<void> logout(BuildContext context) async {
    await GoogleSignIn().signOut();
    await _auth.signOut();

    if (context.mounted) {
      context.read<UserProvider>().clearUser();
    }
  }
}
