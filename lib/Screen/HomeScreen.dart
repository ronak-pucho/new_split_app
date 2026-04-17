import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:we_spilit/Screen/AccountScreen.dart';
import 'package:we_spilit/Screen/CreateFriendScreen.dart';
import 'package:we_spilit/common/helper/helper.dart';
import 'package:we_spilit/common/widgets/avatar_widget.dart';
import 'package:we_spilit/model/friend_model.dart';
import 'package:we_spilit/provider/friends_provider.dart';
import 'package:we_spilit/provider/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = context.watch<UserProvider>().currentUser;
    final friends = context.watch<FriendsProvider>().getFriend();

    // Total shared across all friends
    double totalShared = 0;
    for (final f in friends) {
      if (f.amount != null && f.members != null && f.members! > 0) {
        totalShared += divideAmount(f.amount!, f.members!);
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Gradient App Bar ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, ${user?.userName.split(' ').first ?? 'there'} 👋',
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Manage your shared expenses',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AvatarWidget(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AccountScreen(),
                                    ));
                              },
                              imageUrl: user?.photoUrl,
                              name: user?.userName ?? 'U',
                              radius: 24,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Summary pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.receipt_long, size: 16, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                '₹${totalShared.toStringAsFixed(2)} total shared',
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // title: Text('Friends', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
            // actions: [
            //   IconButton(
            //     icon: const Icon(Icons.person_add_outlined,
            //         color: Colors.white),
            //     tooltip: 'Add Friend',
            //     onPressed: () => Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (_) => const CreateFriendScreen()),
            //     ),
            //   ),
            // ],
          ),

          // ── Body ─────────────────────────────────────────────────────────
          friends.isEmpty
              ? SliverFillRemaining(child: _buildEmpty(scheme))
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildFriendCard(ctx, friends[i]),
                      childCount: friends.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateFriendScreen()),
        ),
        icon: const Icon(Icons.person_add_outlined),
        label: Text('Add Friend', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmpty(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_outline, size: 44, color: scheme.primary),
          ),
          const SizedBox(height: 20),
          Text('No friends yet', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Add a friend to start splitting expenses', style: GoogleFonts.inter(fontSize: 14, color: scheme.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildFriendCard(BuildContext context, FriendsModel friend) {
    final provider = context.read<FriendsProvider>();
    final scheme = Theme.of(context).colorScheme;
    final hasExpense = friend.amount != null && friend.amount! > 0 && friend.members != null;
    final perHead = hasExpense ? divideAmount(friend.amount!, friend.members!) : 0.0;

    return Dismissible(
      key: Key(friend.fId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => provider.deleteFriends(friend.fId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: AvatarWidget(
            name: '${friend.fName} ${friend.lName}',
            radius: 24,
          ),
          title: Text(
            '${friend.fName} ${friend.lName}',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          subtitle: hasExpense
              ? Text(
                  '₹${perHead.toStringAsFixed(2)} each',
                  style: GoogleFonts.inter(fontSize: 12, color: scheme.primary),
                )
              : Text('No expenses yet', style: GoogleFonts.inter(fontSize: 12, color: scheme.onSurface.withOpacity(0.4))),
          trailing: IconButton(
            icon: Icon(Icons.qr_code_2_outlined, color: scheme.primary),
            onPressed: () => _showQrDialog(context, friend),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Remove Friend?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          content: Text('This will remove the friend and their expenses.', style: GoogleFonts.inter()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey))),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Remove', style: GoogleFonts.inter(color: Colors.red))),
          ],
        ),
      );

  void _showQrDialog(BuildContext context, FriendsModel f) {
    final upiId = f.fUpiId.trim();
    // A UPI payment URI: upi://pay?pa=<upiId>&pn=<name>
    final upiUri = 'upi://pay?pa=$upiId&pn=${Uri.encodeComponent('${f.fName} ${f.lName}')}&cu=INR';
    final GlobalKey qrKey = GlobalKey();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title row ────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${f.fName} ${f.lName}',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Save QR as Image',
                      icon: const Icon(Icons.download_rounded),
                      onPressed: () => _saveQrImage(qrKey, '${f.fName}_${f.lName}_qr', ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ── Body ─────────────────────────────────────────────
                if (upiId.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No UPI ID added for this friend.',
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  // ── QR Code ──────────────────────────────────────
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: RepaintBoundary(
                        key: qrKey,
                        child: QrImageView(
                          data: upiUri,
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF1A1A2E),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ── UPI ID pill ───────────────────────────────────
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Theme.of(ctx).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, size: 16, color: Theme.of(ctx).colorScheme.primary),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              upiId,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(ctx).colorScheme.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (f.amount != null) ...[
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Shared: ₹${f.amount!.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // ── Pay via UPI button ────────────────────────────
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.payment_rounded),
                    label: Text('Pay via UPI', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _launchUpiPayment(context, f);
                    },
                  ),
                ],
                const SizedBox(height: 8),
                // ── Close button ──────────────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Close', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Save QR as image ─────────────────────────────────────────────────────
  Future<void> _saveQrImage(GlobalKey repaintKey, String filename, BuildContext ctx) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'UPI QR Code',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save QR: $e', style: GoogleFonts.inter()), behavior: SnackBarBehavior.floating),
      );
    }
  }

  // ── UPI payment flow (url_launcher) ─────────────────────────────────────
  Future<void> _launchUpiPayment(BuildContext context, FriendsModel f) async {
    final amount = f.amount != null && f.members != null && f.members! > 0
        ? divideAmount(f.amount!, f.members!)
        : 0.0;

    final uri = Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': f.fUpiId,
        'pn': '${f.fName} ${f.lName}',
        'tn': 'Bill split via WeSplit',
        if (amount > 0) 'am': amount.toStringAsFixed(2),
        'cu': 'INR',
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No UPI app found on this device.', style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
