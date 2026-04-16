import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/Screen/LoginScreen.dart';
import 'package:we_spilit/common/widgets/app_button.dart';
import 'package:we_spilit/common/widgets/app_text_field.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/provider/auth_provider.dart';
import 'package:we_spilit/provider/user_provider.dart';

class InactiveAccountScreen extends StatefulWidget {
  const InactiveAccountScreen({super.key});

  @override
  State<InactiveAccountScreen> createState() => _InactiveAccountScreenState();
}

class _InactiveAccountScreenState extends State<InactiveAccountScreen> {
  final _msgCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Account Suspended',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_outline, size: 80, color: AppColors.error),
              const SizedBox(height: 24),
              Text(
                'Your account is inactive.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error),
              ),
              const SizedBox(height: 8),
              Text(
                'Please contact the administrator to request reactivation of your account. You will not be able to use the app until it is restored.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: scheme.onSurface.withOpacity(0.7),
                    height: 1.5),
              ),
              const SizedBox(height: 48),
              if (_submitted)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline, color: AppColors.success, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        'Your message has been successfully sent to the administrators. Please wait for them to review your account.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.success),
                      ),
                    ],
                  ),
                )
              else
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _msgCtrl,
                        label: 'Write message to Admin',
                        prefixIcon: Icons.message_outlined,
                        maxLines: 3,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Please enter a message'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Submit Request',
                        isLoading: _loading,
                        onPressed: _submitForm,
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              AppButton(
                label: 'Logout securely',
                isOutlined: true,
                foregroundColor: AppColors.error,
                onPressed: () async {
                  await context.read<AuthenticateProvider>().logout(context);
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<UserProvider>().submitActivationRequest(_msgCtrl.text);
      if (mounted) setState(() => _submitted = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to submit request', style: GoogleFonts.inter()),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
