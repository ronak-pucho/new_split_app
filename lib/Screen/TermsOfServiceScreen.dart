import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
                                Icons.description_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Terms of Service',
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
                    icon: Icons.check_circle_outline,
                    title: '1. Acceptance of Terms',
                    content: _acceptanceContent,
                  ),
                  _section(
                    context,
                    icon: Icons.apps_outlined,
                    title: '2. Description of Service',
                    content: _descriptionContent,
                  ),
                  _section(
                    context,
                    icon: Icons.account_circle_outlined,
                    title: '3. User Accounts',
                    content: _accountsContent,
                  ),
                  _section(
                    context,
                    icon: Icons.rule_outlined,
                    title: '4. Acceptable Use',
                    content: _acceptableUseContent,
                  ),
                  _section(
                    context,
                    icon: Icons.payments_outlined,
                    title: '5. Payments & UPI',
                    content: _paymentsContent,
                  ),
                  _section(
                    context,
                    icon: Icons.people_alt_outlined,
                    title: '6. Friend Data & Content',
                    content: _friendDataContent,
                  ),
                  _section(
                    context,
                    icon: Icons.copyright_outlined,
                    title: '7. Intellectual Property',
                    content: _ipContent,
                  ),
                  _section(
                    context,
                    icon: Icons.gavel_outlined,
                    title: '8. Disclaimers & Liability',
                    content: _disclaimerContent,
                  ),
                  _section(
                    context,
                    icon: Icons.block_outlined,
                    title: '9. Termination',
                    content: _terminationContent,
                  ),
                  _section(
                    context,
                    icon: Icons.language_outlined,
                    title: '10. Governing Law',
                    content: _governingLawContent,
                  ),
                  _section(
                    context,
                    icon: Icons.edit_note_outlined,
                    title: '11. Changes to Terms',
                    content: _changesContent,
                  ),
                  _section(
                    context,
                    icon: Icons.mail_outline,
                    title: '12. Contact Us',
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
              'Please read these Terms of Service carefully before using We Split. By creating an account or using the app, you agree to be bound by these terms. If you do not agree, please do not use We Split.',
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
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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

  static const String _acceptanceContent = '''By downloading, installing, or using We Split, you confirm that:

• You are at least 13 years of age (or the minimum legal age in your country)
• You have read and understood these Terms of Service
• You agree to comply with all terms stated herein
• If you are using We Split on behalf of an organisation, you have the authority to bind that organisation to these terms

These Terms of Service constitute a legally binding agreement between you and We Split.''';

  static const String _descriptionContent = '''We Split is a mobile application that helps users:

• Track shared expenses with friends and groups
• Split bills and calculate individual shares
• Facilitate UPI payment by displaying UPI IDs and generating QR codes
• Manage friends, groups, and expense categories

We Split is a tool to help you track and organise expenses. We do not process, initiate, or guarantee any financial transactions. All payments are made independently through third-party UPI applications.

We reserve the right to modify, suspend, or discontinue any part of the service at any time with reasonable notice.''';

  static const String _accountsContent = '''Account Registration
• You must provide accurate and complete information when creating your account
• You are responsible for maintaining the confidentiality of your login credentials
• You must notify us immediately of any unauthorised use of your account
• One person may only maintain one account

Account Responsibilities
• You are responsible for all activity that occurs under your account
• Do not share your account credentials with others
• You may not create an account if you have been previously banned from We Split

Account Status
• Accounts may be set to "inactive" by administrators if usage violates these terms
• You may request deletion of your account at any time by contacting us''';

  static const String _acceptableUseContent = '''You agree to use We Split only for lawful purposes. You must NOT:

• Use the app to record or facilitate illegal transactions or money laundering
• Enter false, misleading, or fraudulent expense information
• Harass, impersonate, or harm other users
• Attempt to gain unauthorised access to any part of the service or other users' accounts
• Reverse engineer, decompile, or tamper with the app
• Use automated tools or bots to access the service
• Upload malicious code or files
• Violate any applicable local, national, or international law or regulation

Violation of these terms may result in immediate account suspension or termination and, where appropriate, referral to law enforcement authorities.''';

  static const String _paymentsContent = '''UPI Payment Facilitation
• We Split displays UPI IDs and generates QR codes to help you settle expenses conveniently
• We Split does NOT process payments — all transactions occur in your UPI app (GPay, PhonePe, Paytm, etc.)
• We are not responsible for failed, incorrect, or disputed UPI payments
• Always verify the UPI ID and amount before completing a transaction in your UPI app

No Financial Liability
• We Split makes no guarantee that displayed UPI IDs are current or correct
• You are solely responsible for verifying payment details with the recipient
• We Split is not a licensed payment service provider, bank, or financial institution
• Disputes over payments must be resolved directly between the parties involved''';

  static const String _friendDataContent = '''Your Content
• You are responsible for all data you enter into We Split, including friend details, UPI IDs, and expense descriptions
• You represent that you have the right to share any information you enter about other individuals

Friends' Information
• When you add a friend, you are responsible for ensuring the information is accurate
• You must have the consent of any individual whose personal information (name, phone number, UPI ID) you add to the app
• Do not add sensitive personal information beyond what is necessary for expense tracking

Data Accuracy
• We Split does not verify the accuracy of friend or expense information you enter
• Expense calculations are based solely on the data you provide''';

  static const String _ipContent = '''We Split Ownership
• The We Split application, including its design, code, branding, and content, is owned by We Split and protected by copyright and intellectual property laws
• You are granted a limited, non-exclusive, non-transferable licence to use the app for personal, non-commercial purposes

Restrictions
• You may not copy, reproduce, distribute, or create derivative works of the app without our express written permission
• You may not remove any copyright, trademark, or proprietary notices from the app

Your Content
• You retain ownership of the expense data and information you enter
• By using We Split, you grant us a limited licence to store and process your data solely to provide the service''';

  static const String _disclaimerContent = '''Disclaimer of Warranties
We Split is provided "as is" and "as available" without warranties of any kind, either express or implied, including but not limited to:
• Accuracy or reliability of expense calculations
• Uninterrupted or error-free service
• Fitness for a particular purpose

Limitation of Liability
To the maximum extent permitted by applicable law, We Split and its developers shall not be liable for:
• Any indirect, incidental, or consequential damages
• Loss of data or financial loss arising from your use of the app
• Disputes between users regarding shared expenses or payments
• Errors in UPI payment details leading to incorrect transfers

Our total liability to you for any claim arising from your use of We Split shall not exceed the amount you paid us in the 12 months preceding the claim (which, for a free app, is zero).''';

  static const String _terminationContent = '''By You
• You may stop using We Split at any time
• To delete your account and data, contact us at the email address below

By Us
We reserve the right to suspend or terminate your account, with or without notice, if:
• You violate these Terms of Service
• Your account is involved in fraudulent or illegal activity
• Continued use poses a risk to other users or the service

Effect of Termination
• Upon termination, your right to use We Split ceases immediately
• We may retain certain data as required by law or for legitimate business purposes, as described in our Privacy Policy''';

  static const String _governingLawContent = '''These Terms of Service shall be governed by and construed in accordance with the laws of India, without regard to its conflict of law provisions.

Dispute Resolution
• In the event of any dispute, both parties agree to first attempt resolution through good-faith negotiation
• If negotiation fails, disputes shall be subject to the exclusive jurisdiction of the courts located in Ahmedabad, Gujarat, India

If any provision of these terms is found to be unenforceable, the remaining provisions shall continue in full force and effect.''';

  static const String _changesContent = '''We may update these Terms of Service from time to time.

• We will notify you of material changes through an in-app notification or email
• The "Last updated" date at the top will reflect the most recent revision
• Your continued use of We Split after changes take effect constitutes your acceptance of the revised terms
• If you do not agree to the updated terms, you must stop using We Split and may request account deletion

We encourage you to review these Terms periodically.''';

  static const String _contactContent = '''If you have any questions about these Terms of Service, please contact us:

Email: legal@wesplit.app
Support: support@wesplit.app

We aim to respond to all enquiries within 5 business days.

We Split
Ahmedabad, Gujarat, India''';
}
