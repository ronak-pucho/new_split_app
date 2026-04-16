import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/MainScreen.dart';
import 'package:we_spilit/Screen/LoginScreen.dart';
import 'package:we_spilit/admin_base/AdminDashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_spilit/provider/admin_provider.dart';
import 'package:we_spilit/provider/category_provider.dart';
import 'package:we_spilit/Screen/InactiveAccountScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.75, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  Future<void> _navigate() async {
    // Pre-fetch categories for global usage
    if (mounted) context.read<CategoryProvider>().fetchCategories();

    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    if (user != null) {
      final isAdmin = await AdminProvider.isAdmin(user.uid);
      if (!mounted) return;
      if (isAdmin) {
        context.read<AdminProvider>().logAdminLogin(user.uid, user.email);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else {
        // Fetch specific user document status before permitting normal app load
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final status = doc.exists ? (doc.data()?['status'] as String? ?? 'active') : 'active';
        
        if (!mounted) return;
        if (status == 'inactive') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const InactiveAccountScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainScreen()),
          );
        }
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F0F23), const Color(0xFF1A1A35)]
                : [const Color(0xFF5C6BC0), const Color(0xFF26C6DA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Image.asset('asset/logo.png'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'We Split',
                    style: GoogleFonts.inter(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Split expenses with ease',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
