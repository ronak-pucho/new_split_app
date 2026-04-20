import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/MainScreen.dart';
import 'package:we_spilit/Screen/LoginScreen.dart';
import 'package:we_spilit/common/widgets/app_button.dart';
import 'package:we_spilit/common/widgets/app_text_field.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/core/utils/validators.dart';
import 'package:we_spilit/provider/auth_provider.dart';
import 'package:we_spilit/provider/admin_provider.dart';
import 'package:we_spilit/provider/category_provider.dart';
import 'package:we_spilit/provider/friends_provider.dart';
import 'package:we_spilit/provider/user_provider.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _category;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final authProvider = context.read<AuthenticateProvider>();
      final userProvider = context.read<UserProvider>();
      final user = await authProvider.createEmailAccount(
          _emailCtrl.text.trim(), _passCtrl.text);
      if (user != null) {
        await userProvider.setUserData(
          id: user.uid,
          userName: _nameCtrl.text.trim(),
          userEmail: user.email!,
          phoneNumber: _phoneCtrl.text.trim(),
          category: _category ?? 'Other',
        );
        if (!mounted) return;
        context
            .read<AdminProvider>()
            .logUserAction(user.uid, user.email, 'user_registered');

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Account created! Welcome 🎉', style: GoogleFonts.inter()),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      String msg = 'Account creation failed.';
      if (e.toString().contains('email-already-in-use')) {
        msg = 'This email is already registered.';
      } else if (e.toString().contains('weak-password')) {
        msg = 'Password is too weak (min 6 characters).';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: GoogleFonts.inter()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Future<void> _googleSignIn() async {
  //   setState(() => _loading = true);
  //   try {
  //     final authProvider = context.read<AuthenticateProvider>();
  //     final userProvider = context.read<UserProvider>();
  //     final friendsProvider = context.read<FriendsProvider>();
  //     final cred = await authProvider.loginWithGoogle();
  //     final user = cred?.user;
  //     if (user != null) {
  //       await userProvider.setUserData(
  //         id: user.uid,
  //         userName: user.displayName ?? '',
  //         userEmail: user.email ?? '',
  //       );
  //       await friendsProvider.getAllFriends();
  //       if (!mounted) return;
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (_) => MainScreen()),
  //         (route) => false,
  //       );
  //     }
  //   } catch (_) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Google sign-in failed.', style: GoogleFonts.inter()),
  //       backgroundColor: AppColors.error,
  //       behavior: SnackBarBehavior.floating,
  //     ));
  //   } finally {
  //     if (mounted) setState(() => _loading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final catProv = context.watch<CategoryProvider>();
    final availableCats =
        catProv.categories.map((c) => c.categoryName).toList();
    if (availableCats.isNotEmpty && _category == null) {
      _category = availableCats.first;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient:
                  isDark ? AppColors.darkGradient : AppColors.primaryGradient,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Header
                  Text('Create Account',
                      style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Join We Split today',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 32),
                  // Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 30,
                            offset: const Offset(0, 10))
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _nameCtrl,
                            label: 'Full Name',
                            prefixIcon: Icons.person_outline,
                            validator: Validators.name,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _emailCtrl,
                            label: 'Email Address',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _phoneCtrl,
                            label: 'Phone Number (optional)',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: Validators.phone,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          // Category dropdown
                          DropdownButtonFormField<String>(
                            value: availableCats.contains(_category)
                                ? _category
                                : (availableCats.isNotEmpty
                                    ? availableCats.first
                                    : null),
                            decoration: InputDecoration(
                              labelText: 'Category',
                              prefixIcon: Icon(Icons.category_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20),
                            ),
                            items: availableCats
                                .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c, style: GoogleFonts.inter())))
                                .toList(),
                            onChanged: availableCats.isEmpty
                                ? null
                                : (v) => setState(() => _category = v),
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
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            label: 'Create Account',
                            isLoading: _loading,
                            onPressed: _signUp,
                          ),
                          // const SizedBox(height: 12),
                          // AppButton(
                          //   label: 'Continue with Google',
                          //   icon: Icons.g_mobiledata_rounded,
                          //   isOutlined: true,
                          //   backgroundColor:
                          //       Theme.of(context).colorScheme.primary,
                          //   foregroundColor:
                          //       Theme.of(context).colorScheme.primary,
                          //   onPressed: _loading ? null : _googleSignIn,
                          // ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?',
                          style: GoogleFonts.inter(fontSize: 13)),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen())),
                        child: Text('Sign In',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
