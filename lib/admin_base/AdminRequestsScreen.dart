import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/provider/admin_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final requests = provider.requests;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Account Support Requests',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
      ),
      body: requests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No pending requests found',
                      style: GoogleFonts.inter(
                          color: scheme.onSurface.withOpacity(0.5))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (ctx, i) {
                final req = requests[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3)),
                    ],
                    border: Border.all(color: AppColors.error.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: AppColors.error, size: 20),
                              const SizedBox(width: 8),
                              Text(req.userName,
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          Text(timeago.format(req.timestamp),
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: scheme.onSurface.withOpacity(0.5))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(req.userEmail,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: scheme.onSurface.withOpacity(0.5))),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      Text('Message:',
                          style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.onSurface.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(req.message,
                            style: GoogleFonts.inter(height: 1.4)),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _showReactivateDialog(ctx, req),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: Text('Reactivate Account',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showReactivateDialog(BuildContext ctx, dynamic req) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reactivate User?',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: AppColors.success)),
        content: Text(
            'This will mark the request as resolved and fully restore ${req.userName}\'s access to the application immediately.',
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.inter())),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final provider = context.read<AdminProvider>();
                await provider.toggleUserStatus(
                    req.userId, req.userEmail, 'active');
                await provider.resolveRequest(req.requestId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Account Activated!',
                        style: GoogleFonts.inter()),
                    backgroundColor: AppColors.success,
                  ));
                }
              } catch (_) {}
            },
            child: Text('Activate',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, color: AppColors.success)),
          ),
        ],
      ),
    );
  }
}
