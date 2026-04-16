import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/Screen/LoginScreen.dart';
import 'package:we_spilit/Screen/SettingsScreen.dart';
import 'package:we_spilit/common/widgets/app_button.dart';
import 'package:we_spilit/common/widgets/app_text_field.dart';
import 'package:we_spilit/common/widgets/avatar_widget.dart';
import 'package:we_spilit/common/widgets/loading_overlay.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/provider/auth_provider.dart';
import 'package:we_spilit/provider/user_provider.dart';
import 'package:we_spilit/provider/category_provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;
    final fireUser = FirebaseAuth.instance.currentUser;
    final scheme = Theme.of(context).colorScheme;

    return LoadingOverlay(
      isLoading: userProvider.isLoading,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 290,
              pinned: true,
              backgroundColor: scheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [scheme.onSurface.withOpacity(0.70), scheme.primary.withOpacity(0.50)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          // Avatar with camera button overlay
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              AvatarWidget(
                                imageUrl: user?.photoUrl,
                                name: user?.userName ?? fireUser?.email ?? 'U',
                                radius: 42,
                              ),
                              // GestureDetector(
                              // onTap: _pickAndUploadImage,
                              // child: Container(
                              //   padding: const EdgeInsets.all(6),
                              //   decoration: const BoxDecoration(
                              //     color: Colors.white,
                              //     shape: BoxShape.circle,
                              //   ),
                              //   child: Icon(Icons.camera_alt, size: 16, color: scheme.primary),
                              // ),
                              // ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            user?.userName ?? fireUser?.displayName ?? 'User',
                            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.userEmail ?? fireUser?.email ?? '',
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
                          ),
                          if (user?.category != null)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user!.category!,
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                              ),
                            ),
                        ],
                      ), // closes column
                    ), // closes padding
                  ), // closes safe area
                ), // closes container
              ), // closes flexible space bar
              title: Text('Profile', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () => _showEditSheet(context),
                ),
              ],
            ),

            // ── Info cards ───────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _infoCard(context, [
                    _infoRow(context, Icons.email_outlined, 'Email', user?.userEmail ?? fireUser?.email ?? '—'),
                    _divider(context),
                    _infoRow(context, Icons.phone_outlined, 'Phone', user?.phoneNumber ?? '—'),
                    _divider(context),
                    _infoRow(context, Icons.category_outlined, 'Category', user?.category ?? '—'),
                    _divider(context),
                    _infoRow(context, Icons.verified_user_outlined, 'Status', user?.status ?? 'active'),
                  ]),
                  const SizedBox(height: 12),
                  _actionTile(
                    context,
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _actionTile(
                    context,
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    isDestructive: false,
                    onTap: () => _confirmLogout(context),
                  ),
                  const SizedBox(height: 8),
                  _actionTile(
                    context,
                    icon: Icons.delete_forever_outlined,
                    label: 'Delete Account',
                    isDestructive: true,
                    onTap: () => _confirmDelete(context),
                  ),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  Widget _infoCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(BuildContext ctx, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(ctx).colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 11, color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.5))),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext ctx) => Divider(height: 1, indent: 50, color: Theme.of(ctx).dividerColor);

  Widget _actionTile(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap, bool isDestructive = false}) {
    final color = isDestructive ? AppColors.error : Theme.of(context).colorScheme.onSurface;
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
              ),
              Icon(Icons.chevron_right, size: 20, color: color.withOpacity(0.4)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Image picker ─────────────────────────────────────────────────────────
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;
    if (!mounted) return;
    await context.read<UserProvider>().updateProfile(imageFile: File(picked.path));
  }

  // ── Edit bottom sheet ────────────────────────────────────────────────────
  void _showEditSheet(BuildContext context) {
    final catProv = context.read<CategoryProvider>();
    final availableCats = catProv.categories.map((c) => c.categoryName).toList();

    final user = context.read<UserProvider>().currentUser;
    final nameCtrl = TextEditingController(text: user?.userName ?? '');
    final phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');

    String? selectedCat = user?.category;
    if (selectedCat == null || !availableCats.contains(selectedCat)) {
      selectedCat = availableCats.isNotEmpty ? availableCats.first : null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setBS) {
          return Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Edit Profile', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(controller: nameCtrl, label: 'Full Name', prefixIcon: Icons.person_outline),
                const SizedBox(height: 12),
                AppTextField(controller: phoneCtrl, label: 'Phone', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: availableCats.contains(selectedCat) ? selectedCat : (availableCats.isNotEmpty ? availableCats.first : null),
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: availableCats.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.inter()))).toList(),
                  onChanged: availableCats.isEmpty ? null : (v) => setBS(() => selectedCat = v),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Save Changes',
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await context.read<UserProvider>().updateProfile(
                          userName: nameCtrl.text.trim(),
                          phoneNumber: phoneCtrl.text.trim(),
                          category: selectedCat ?? 'Other',
                        );
                  },
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('You will be signed out.', style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.inter())),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              await context.read<AuthenticateProvider>().logout(context);
              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text('Logout', style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Account?', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.error)),
        content: Text(
          'This action is permanent and cannot be undone. All your data will be deleted.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.inter())),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<UserProvider>().deleteAccount();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              } catch (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    'Re-authentication required. Please log out and log in again.',
                    style: GoogleFonts.inter(),
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            child: Text('Delete', style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
