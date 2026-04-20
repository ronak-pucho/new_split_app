import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/common/widgets/app_button.dart';
import 'package:we_spilit/common/widgets/app_text_field.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/provider/friends_provider.dart';
import 'package:we_spilit/model/friend_model.dart';

class CreateFriendScreen extends StatefulWidget {
  final FriendsModel? friend;
  const CreateFriendScreen({super.key, this.friend});
  @override
  State<CreateFriendScreen> createState() => _CreateFriendScreenState();
}

class _CreateFriendScreenState extends State<CreateFriendScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fNameCtrl = TextEditingController();
  final _lNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();
  bool _loading = false;

  bool get _isEditing => widget.friend != null;

  @override
  void initState() {
    super.initState();
    final f = widget.friend;
    if (f != null) {
      _fNameCtrl.text = f.fName;
      _lNameCtrl.text = f.lName;
      _phoneCtrl.text = f.fPhoneNumber;
      _upiCtrl.text = f.fUpiId;
    }
  }

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
      if (_isEditing) {
        final existing = widget.friend!;
        final updated = FriendsModel(
          fId: existing.fId,
          userId: existing.userId,
          fName: _fNameCtrl.text.trim(),
          lName: _lNameCtrl.text.trim(),
          fPhoneNumber: _phoneCtrl.text.trim(),
          fUpiId: _upiCtrl.text.trim(),
          description: existing.description,
          amount: existing.amount,
          members: existing.members,
          isExpenseDelete: existing.isExpenseDelete,
          isFriendsDelete: existing.isFriendsDelete,
        );
        await context.read<FriendsProvider>().updateFriend(friendsModel: updated);
      } else {
        await context.read<FriendsProvider>().setFireStoreFriends(
              fName: _fNameCtrl.text.trim(),
              lName: _lNameCtrl.text.trim(),
              fPhoneNumber: _phoneCtrl.text.trim(),
              fUpiId: _upiCtrl.text.trim(),
            );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditing ? 'Friend updated successfully!' : 'Friend added successfully! 🎉', style: GoogleFonts.inter()),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditing ? 'Failed to update friend.' : 'Failed to add friend.', style: GoogleFonts.inter()),
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
        title: Text(_isEditing ? 'Edit Friend' : 'Add Friend', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
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
                  child: Icon(_isEditing ? Icons.edit_outlined : Icons.person_add_outlined, color: Colors.white, size: 34),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(_isEditing ? 'Update Friend' : 'New Friend', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(_isEditing ? 'Edit the details below' : 'Fill in the details below', style: GoogleFonts.inter(fontSize: 13, color: scheme.onSurface.withOpacity(0.5))),
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _fNameCtrl,
                label: 'First Name',
                prefixIcon: Icons.person_outline,
                validator: (v) => v == null || v.trim().isEmpty ? 'First name is required' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _lNameCtrl,
                label: 'Last Name',
                prefixIcon: Icons.person_outline,
                validator: (v) => v == null || v.trim().isEmpty ? 'Last name is required' : null,
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
                validator: (v) => v == null || v.trim().isEmpty ? 'Phone number is required' : null,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20, color: scheme.primary),
                  labelStyle: GoogleFonts.inter(fontSize: 13, color: scheme.onSurface.withOpacity(0.6)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _upiCtrl,
                textInputAction: TextInputAction.done,
                validator: (v) => v == null || v.trim().isEmpty ? 'UPI ID is required' : null,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'UPI ID',
                  prefixIcon: Icon(Icons.payment, size: 20, color: scheme.primary),
                  labelStyle: GoogleFonts.inter(fontSize: 13, color: scheme.onSurface.withOpacity(0.6)),
                ),
              ),
              const SizedBox(height: 36),
              AppButton(
                label: _isEditing ? 'Save Changes' : 'Add Friend',
                isLoading: _loading,
                onPressed: _save,
                icon: _isEditing ? Icons.save_outlined : Icons.person_add_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
