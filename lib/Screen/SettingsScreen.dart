import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/ThemeProvider.dart';
import 'package:we_spilit/Screen/PrivacyPolicyScreen.dart';
import 'package:we_spilit/Screen/TermsOfServiceScreen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel(context, 'Appearance'),
          _card(context, [
            SwitchListTile.adaptive(
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode_outlined,
                color: scheme.primary,
              ),
              title: Text('Dark Mode',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
              subtitle: Text(
                isDark ? 'Dark theme active' : 'Light theme active',
                style: GoogleFonts.inter(fontSize: 12),
              ),
              value: isDark,
              activeColor: scheme.primary,
              onChanged: (val) => themeProvider.toggleTheme(val),
            ),
          ]),
          const SizedBox(height: 16),
          _sectionLabel(context, 'Notifications'),
          _card(context, [
            SwitchListTile.adaptive(
              secondary:
                  Icon(Icons.notifications_outlined, color: scheme.primary),
              title: Text('Push Notifications',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
              subtitle: Text('Expense alerts & reminders',
                  style: GoogleFonts.inter(fontSize: 12)),
              value: false,
              activeColor: scheme.primary,
              onChanged: (_) {},
            ),
            Divider(
                height: 1, indent: 56, color: Theme.of(context).dividerColor),
            SwitchListTile.adaptive(
              secondary: Icon(Icons.mail_outline, color: scheme.primary),
              title: Text('Email Notifications',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
              subtitle: Text('Weekly summary emails',
                  style: GoogleFonts.inter(fontSize: 12)),
              value: false,
              activeColor: scheme.primary,
              onChanged: (_) {},
            ),
          ]),
          const SizedBox(height: 16),
          _sectionLabel(context, 'About'),
          _card(context, [
            _infoTile(context, Icons.info_outline, 'App Version', '3.5.1'),
            Divider(
                height: 1, indent: 56, color: Theme.of(context).dividerColor),
            _navTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrivacyPolicyScreen(),
                ),
              ),
            ),
            Divider(
                height: 1, indent: 56, color: Theme.of(context).dividerColor),
            _navTile(
              context,
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TermsOfServiceScreen(),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _card(BuildContext context, List<Widget> children) {
    return Container(
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
  }

  Widget _infoTile(
      BuildContext context, IconData icon, String title, String trailing) {
    return ListTile(
      leading:
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
      trailing: trailing.isNotEmpty
          ? Text(trailing,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5)))
          : const Icon(Icons.chevron_right, size: 20),
    );
  }

  Widget _navTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading:
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
