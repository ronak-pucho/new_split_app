import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/ThemeProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_spilit/admin_base/AdminCategoriesScreen.dart';
import 'package:we_spilit/admin_base/AdminGroupTypesScreen.dart';
import 'package:we_spilit/provider/admin_provider.dart';
import 'package:we_spilit/provider/group_type_provider.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final isDark = themeProvider.isDarkMode;
    final scheme = Theme.of(context).colorScheme;
    final adminUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF7B1FA2),
            title: Text('Admin Settings',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Admin info card ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B1FA2), Color(0xFFE91E63)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.admin_panel_settings,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Administrator',
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(
                              adminUser?.email ?? 'admin@wesplit.app',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Appearance ─────────────────────────────────────────
                _sectionLabel(context, 'Appearance'),
                _card(context, [
                  SwitchListTile.adaptive(
                    secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode_outlined,
                      color: const Color(0xFF7B1FA2),
                    ),
                    title: Text('Dark Mode',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                        isDark ? 'Dark theme active' : 'Light theme active',
                        style: GoogleFonts.inter(fontSize: 12)),
                    value: isDark,
                    activeColor: const Color(0xFF7B1FA2),
                    onChanged: (val) => themeProvider.toggleTheme(val),
                  ),
                ]),

                const SizedBox(height: 16),

                // ── Admin Preferences ─────────────────────────────────
                _sectionLabel(context, 'Admin Preferences'),
                _card(context, [
                  _infoTile(context, Icons.notifications_outlined,
                      'Push Notifications', false),
                  Divider(
                      height: 1,
                      indent: 56,
                      color: Theme.of(context).dividerColor),
                  _infoTile(context, Icons.security_outlined, 'Two-Factor Auth',
                      false),
                  Divider(
                      height: 1,
                      indent: 56,
                      color: Theme.of(context).dividerColor),
                  _infoTile(
                      context, Icons.history_outlined, 'Audit Logging', true),
                ]),

                const SizedBox(height: 16),

                // ── System ─────────────────────────────────────────────
                _sectionLabel(context, 'System'),
                _card(context, [
                  ListTile(
                    leading: const Icon(Icons.timer_outlined, color: Color(0xFF7B1FA2), size: 22),
                    title: Text('Support Cooldown', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                    subtitle: Text('Hours between support requests', style: GoogleFonts.inter(fontSize: 12)),
                    trailing: Text('${adminProvider.cooldownHours}h', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF7B1FA2))),
                    onTap: () => _showCooldownDialog(context, adminProvider),
                  ),
                  Divider(height: 1, indent: 56, color: Theme.of(context).dividerColor),
                  ListTile(
                    leading: const Icon(Icons.category_outlined,
                        color: Color(0xFF7B1FA2), size: 22),
                    title: Text('Manage Categories',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AdminCategoriesScreen())),
                  ),
                  Divider(
                      height: 1,
                      indent: 56,
                      color: Theme.of(context).dividerColor),
                  ListTile(
                    leading: const Icon(Icons.style_outlined,
                        color: Color(0xFF7B1FA2), size: 22),
                    title: Text('Manage Group Types',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      context.read<GroupTypeProvider>().fetchGroupTypes();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AdminGroupTypesScreen()));
                    },
                  ),
                  Divider(
                      height: 1,
                      indent: 56,
                      color: Theme.of(context).dividerColor),
                  ListTile(
                    leading: const Icon(Icons.info_outline,
                        color: Color(0xFF7B1FA2), size: 22),
                    title: Text('App Version',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                    trailing: Text('1.0.0',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: scheme.onSurface.withOpacity(0.5))),
                  ),
                  Divider(
                      height: 1,
                      indent: 56,
                      color: Theme.of(context).dividerColor),
                  ListTile(
                    leading: const Icon(Icons.cloud_outlined,
                        color: Color(0xFF7B1FA2), size: 22),
                    title: Text('Firebase Project',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                    trailing: Text('we-split',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: scheme.onSurface.withOpacity(0.5))),
                  ),
                ]),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: const Color(0xFF7B1FA2),
          ),
        ),
      );

  Widget _card(BuildContext context, List<Widget> children) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(children: children),
      );

  Widget _infoTile(
      BuildContext context, IconData icon, String title, bool value) {
    return StatefulBuilder(builder: (ctx, setS) {
      return SwitchListTile.adaptive(
        secondary: Icon(icon, color: const Color(0xFF7B1FA2), size: 22),
        title:
            Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        value: value,
        activeColor: const Color(0xFF7B1FA2),
        onChanged: (_) {},
      );
    });
  }

  void _showCooldownDialog(BuildContext context, AdminProvider provider) {
    final ctrl = TextEditingController(text: provider.cooldownHours.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Set Cooldown Limit',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Hours',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter())),
          ElevatedButton(
            onPressed: () async {
              final val = int.tryParse(ctrl.text.trim());
              if (val != null && val > 0) {
                await provider.updateCooldown(val);
              }
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B1FA2), foregroundColor: Colors.white),
            child: Text('Save', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
