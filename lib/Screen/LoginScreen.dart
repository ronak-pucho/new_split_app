import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/Screen/CreateAccount.dart';
import 'package:we_spilit/Screen/ForgotPasswordScreen.dart';
import 'package:we_spilit/common/widgets/app_button.dart';
import 'package:we_spilit/common/widgets/app_text_field.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/core/utils/validators.dart';
import 'package:we_spilit/provider/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthenticateProvider>().signInEmailPassword(
            context,
            _emailCtrl.text.trim(),
            _passCtrl.text,
          );
    } on Exception catch (e) {
      if (!mounted) return;
      _showError(_mapError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapError(String msg) {
    if (msg.contains('wrong-password') || msg.contains('invalid-credential')) {
      return 'Incorrect email or password.';
    }
    if (msg.contains('user-not-found')) {
      return 'No account found with this email.';
    }
    if (msg.contains('too-many-requests')) {
      return 'Too many attempts. Please try later.';
    }
    return 'Login failed. Please try again.';
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter()),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient background ─────────────────────────────────────────
          Container(
            height: size.height * 0.45,
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.darkGradient : AppColors.primaryGradient,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  // ── Logo ──────────────────────────────────────────────
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Image.asset('asset/logo.png'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text('We Split', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text('Sign in to continue', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                  ),
                  SizedBox(height: size.height * 0.07),
                  // ── Glass card ────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back!',
                              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
                          const SizedBox(height: 4),
                          Text('Enter your credentials to sign in',
                              style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                          const SizedBox(height: 24),
                          AppTextField(
                            controller: _emailCtrl,
                            label: 'Email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _passCtrl,
                            label: 'Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscure,
                            validator: Validators.password,
                            textInputAction: TextInputAction.done,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                              child: Text('Forgot password?', style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.primary)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppButton(
                            label: 'Sign In',
                            isLoading: _loading,
                            onPressed: _login,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // ── Google sign-in ────────────────────────────────────
                  // AppButton(
                  //   label: 'Continue with Google',
                  //   icon: Icons.g_mobiledata_rounded,
                  //   isOutlined: true,
                  //   backgroundColor: Theme.of(context).colorScheme.primary,
                  //   foregroundColor: Theme.of(context).colorScheme.primary,
                  //   onPressed: _loading ? null : _googleSignIn,
                  // ),
                  // const SizedBox(height: 24),
                  // ── Sign up link ──────────────────────────────────────
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?", style: GoogleFonts.inter(fontSize: 13)),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAccount())),
                          child: Text('Sign Up',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    try {
      final authProvider = context.read<AuthenticateProvider>();
      final credential = await authProvider.loginWithGoogle();
      if (credential?.user == null) return;
      if (!mounted) return;
      await authProvider.signInEmailPassword(context, credential!.user!.email ?? '', '');
    } catch (_) {
      if (!mounted) return;
      _showError('Google sign in failed.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
