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
  final _auth = FirebaseAuth.instance;

  // ── Create account with email ────────────────────────────────────────────
  Future<User?> createEmailAccount(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  // ── Sign in with email ───────────────────────────────────────────────────
  Future<void> signInEmailPassword(
      BuildContext context, String email, String password) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (!context.mounted) return;
    final user = credential.user;
    if (user == null) return;

    final admin = await AdminProvider.isAdmin(user.uid);

    if (!context.mounted) return;
    final friendsProvider = context.read<FriendsProvider>();
    final userProvider = context.read<UserProvider>();

    await userProvider.fetchCurrentUser();

    if (admin) {
      context.read<AdminProvider>().logAdminLogin(user.uid, user.email);
      await context.read<AdminProvider>().fetchAllUsers();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
        (route) => false,
      );
    } else {
      context.read<AdminProvider>().logUserAction(user.uid, user.email, 'user_login');
      
      final isInactive = userProvider.currentUser?.status == 'inactive';
      
      if (isInactive) {
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const InactiveAccountScreen()),
          (route) => false,
        );
      } else {
        await friendsProvider.getAllFriends();
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MainScreen()),
          (route) => false,
        );
      }
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────
  Future<UserCredential?> loginWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  // ── Password reset ────────────────────────────────────────────────────────
  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout(BuildContext context) async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      context.read<UserProvider>().clearUser();
    }
  }
}
