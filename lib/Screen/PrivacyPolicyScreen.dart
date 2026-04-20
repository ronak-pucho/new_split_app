import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Gradient App Bar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: scheme.primary,
            leading: const BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.onSurface.withOpacity(0.70),
                      scheme.primary.withOpacity(0.50),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.privacy_tip_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Privacy Policy',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Last updated: April 17, 2025',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _introCard(context),
                  const SizedBox(height: 16),
                  _section(
                    context,
                    icon: Icons.person_outline,
                    title: '1. Information We Collect',
                    content: _informationContent,
                  ),
                  _section(
                    context,
                    icon: Icons.settings_suggest_outlined,
                    title: '2. How We Use Your Information',
                    content: _howWeUseContent,
                  ),
                  _section(
                    context,
                    icon: Icons.share_outlined,
                    title: '3. Information Sharing',
                    content: _sharingContent,
                  ),
                  _section(
                    context,
                    icon: Icons.lock_outline,
                    title: '4. Data Security',
                    content: _securityContent,
                  ),
                  _section(
                    context,
                    icon: Icons.payment_outlined,
                    title: '5. UPI & Payment Data',
                    content: _paymentContent,
                  ),
                  _section(
                    context,
                    icon: Icons.people_outline,
                    title: '6. Friends & Contacts',
                    content: _contactsContent,
                  ),
                  _section(
                    context,
                    icon: Icons.child_care_outlined,
                    title: '7. Children\'s Privacy',
                    content: _childrenContent,
                  ),
                  _section(
                    context,
                    icon: Icons.tune_outlined,
                    title: '8. Your Rights & Choices',
                    content: _rightsContent,
                  ),
                  _section(
                    context,
                    icon: Icons.update_outlined,
                    title: '9. Changes to This Policy',
                    content: _changesContent,
                  ),
                  _section(
                    context,
                    icon: Icons.mail_outline,
                    title: '10. Contact Us',
                    content: _contactContent,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _introCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withOpacity(0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: scheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'We Split ("we", "our", or "us") is committed to protecting your privacy. This policy explains how we collect, use, and protect your personal information when you use the We Split expense-splitting application.',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                height: 1.6,
                color: scheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: scheme.primary, size: 18),
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              color: scheme.primary.withOpacity(0.10),
              height: 1,
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                height: 1.7,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section content strings ─────────────────────────────────────────────

  static const String _informationContent = '''We collect the following types of information:

Account Information
• Full name and email address when you create an account
• Phone number (optional, used for friend discovery)
• Profile photo (optional, uploaded by you)
• Account category (Personal, Business, Student, or Other)

Usage Information
• Expense records including amounts, descriptions, and member counts
• Friend connections you create within the app
• Group information and associated expenses
• App activity logs for debugging and analytics

Device Information
• Device type and operating system version
• App version and crash reports
• Anonymized usage analytics''';

  static const String _howWeUseContent = '''We use the collected information to:

• Provide and maintain the We Split service
• Display your expense history and friend balances
• Enable expense splitting calculations and UPI payment facilitation
• Send push notifications for expense alerts and reminders (if enabled)
• Send weekly summary emails (if you opt in)
• Improve app performance and fix bugs
• Detect and prevent fraud or abuse
• Comply with legal obligations

We do not use your data for targeted advertising or sell it to third parties for marketing purposes.''';

  static const String _sharingContent = '''We do not sell your personal information. We may share your data only in the following limited circumstances:

With Other Users
• Your name and profile photo are visible to friends you connect with inside the app.
• Expense details are visible to all members of a shared expense.

Service Providers
• Firebase (Google) — authentication, database, and cloud storage
• These providers process data only as instructed by us and are bound by confidentiality agreements.

Legal Requirements
• We may disclose information if required by law, court order, or government authority.

Business Transfers
• If We Split is acquired or merged, your data may be transferred as part of that transaction. We will notify you beforehand.''';

  static const String _securityContent = '''We implement industry-standard security measures to protect your data:

• All data is transmitted over HTTPS/TLS encrypted connections
• User authentication is handled by Firebase Authentication with secure token management
• Data is stored in Google Firebase Firestore with strict access rules
• Passwords are never stored; authentication uses secure Firebase mechanisms
• Profile photos are stored in Firebase Cloud Storage with access controls

While we strive to protect your information, no method of transmission over the internet is 100% secure. We encourage you to use a strong, unique password and keep your account credentials confidential.''';

  static const String _paymentContent = '''We Split facilitates UPI payment by displaying UPI IDs to help you settle expenses. Please note:

• We Split does not process payments directly — we display UPI IDs so you can complete payments in your preferred UPI app (GPay, PhonePe, Paytm, etc.)
• We do not store any banking credentials, card numbers, or bank account details
• UPI IDs stored in the app are entered voluntarily by you for your friends
• We generate QR codes based on the UPI ID you provide — this is processed locally on your device
• All financial transactions happen outside of We Split through your UPI provider''';

  static const String _contactsContent = '''When you add friends in We Split:

• You manually enter friend details (name, phone number, UPI ID)
• We Split does not automatically access your device's contact list
• Friend data is stored in our database and linked to your account
• You can delete a friend at any time, which removes their associated expense data
• Friends you add do not receive any notification from We Split unless they are also registered users''';

  static const String _childrenContent = '''We Split is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13.

If you are a parent or guardian and believe your child has provided us with personal information, please contact us immediately at the email below. We will promptly delete such information from our records.

Users aged 13–18 should use the app only with parental or guardian consent.''';

  static const String _rightsContent = '''You have the following rights regarding your personal data:

Access & Portability
• View all your personal data through the Account screen
• Request a copy of your data by contacting us

Correction
• Update your name, phone number, and profile photo at any time in the Account screen

Deletion
• Delete individual expenses or friends from the app
• Request full account deletion by contacting us — we will delete your data within 30 days

Notifications
• Disable push notifications at any time in your device settings or the Settings screen
• Opt out of email notifications in the Settings screen

To exercise any of these rights, please contact us using the details in the Contact section.''';

  static const String _changesContent = '''We may update this Privacy Policy from time to time to reflect changes in our practices or legal requirements.

• We will notify you of significant changes through a notice in the app or via email
• The "Last updated" date at the top of this page will be revised accordingly
• Continued use of We Split after any changes constitutes your acceptance of the updated policy

We encourage you to review this policy periodically to stay informed about how we protect your information.''';

  static const String _contactContent = '''If you have any questions, concerns, or requests regarding this Privacy Policy, please contact us:

Email: privacy@wesplit.app
Support: support@wesplit.app

We aim to respond to all privacy-related enquiries within 5 business days.

We Split
Ahmedabad, Gujarat, India''';
}
