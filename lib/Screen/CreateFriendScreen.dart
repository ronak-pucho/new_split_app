import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/common/widgets/app_button.dart';
import 'package:we_spilit/common/widgets/app_text_field.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/provider/friends_provider.dart';

class CreateFriendScreen extends StatefulWidget {
  const CreateFriendScreen({super.key});
  @override
  State<CreateFriendScreen> createState() => _CreateFriendScreenState();
}

class _CreateFriendScreenState extends State<CreateFriendScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fNameCtrl = TextEditingController();
  final _lNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _fNameCtrl.dispose();
    _lNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<FriendsProvider>().setFireStoreFriends(
            fName: _fNameCtrl.text.trim(),
            lName: _lNameCtrl.text.trim(),
            fPhoneNumber: _phoneCtrl.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Friend added successfully! 🎉', style: GoogleFonts.inter()),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add friend.', style: GoogleFonts.inter()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friend',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon header
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [scheme.primary, scheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_add_outlined,
                      color: Colors.white, size: 34),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text('New Friend',
                    style: GoogleFonts.inter(
                        fontSize: 22, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text('Fill in the details below',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: scheme.onSurface.withOpacity(0.5))),
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _fNameCtrl,
                label: 'First Name',
                prefixIcon: Icons.person_outline,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'First name is required'
                    : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _lNameCtrl,
                label: 'Last Name',
                prefixIcon: Icons.person_outline,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Last name is required'
                    : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Phone number is required'
                    : null,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(Icons.phone_outlined,
                      size: 20, color: scheme.primary),
                  labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: scheme.onSurface.withOpacity(0.6)),
                ),
              ),
              const SizedBox(height: 36),
              AppButton(
                label: 'Add Friend',
                isLoading: _loading,
                onPressed: _save,
                icon: Icons.person_add_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
