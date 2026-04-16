import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/common/widgets/app_button.dart';
import 'package:we_spilit/common/widgets/app_text_field.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/core/utils/validators.dart';
import 'package:we_spilit/provider/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthenticateProvider>().resetPassword(
            email: _emailCtrl.text.trim(),
          );
      if (!mounted) return;
      setState(() => _sent = true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not send reset email.',
            style: GoogleFonts.inter()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mark_email_read_outlined,
                size: 40, color: AppColors.success),
          ),
          const SizedBox(height: 24),
          Text('Check your inbox!',
              style: GoogleFonts.inter(
                  fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(
            'A password reset link has been sent to\n${_emailCtrl.text.trim()}',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 14,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Back to Login',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.lock_reset_outlined,
              size: 28, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 24),
        Text('Reset Password',
            style: GoogleFonts.inter(
                fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          "Enter your email and we'll send you a link to reset your password.",
          style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.55)),
        ),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: AppTextField(
            controller: _emailCtrl,
            label: 'Email Address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            textInputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'Send Reset Link',
          isLoading: _loading,
          onPressed: _send,
        ),
      ],
    );
  }
}
