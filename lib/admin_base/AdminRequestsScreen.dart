import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/provider/admin_provider.dart';
import 'package:we_spilit/model/account_request_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:we_spilit/admin_base/AdminChatScreen.dart';

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

    // Grouping requests by user
    final Map<String, List<AccountRequestModel>> grouped = {};
    for (var req in requests) {
      if (grouped[req.userId] == null) grouped[req.userId] = [];
      grouped[req.userId]!.add(req);
    }
    
    final groupedList = grouped.entries.map((e) => e.value).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Account Support Requests',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
      ),
      body: groupedList.isEmpty
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
              itemCount: groupedList.length,
              itemBuilder: (ctx, i) {
                final userGroup = groupedList[i];
                userGroup.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                final recentReq = userGroup.first;
                final unrepliedCount = userGroup.where((r) => r.adminReply == null).length;

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => AdminChatScreen(
                          userId: recentReq.userId,
                          userName: recentReq.userName,
                          userEmail: recentReq.userEmail,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: scheme.onSurface.withOpacity(0.05))),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF7B1FA2).withOpacity(0.1),
                          child: Text(recentReq.userName.isNotEmpty ? recentReq.userName[0].toUpperCase() : 'U', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFF7B1FA2))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(recentReq.userName, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(
                                recentReq.message,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(fontSize: 13, color: scheme.onSurface.withOpacity(0.6)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(timeago.format(recentReq.timestamp), style: GoogleFonts.inter(fontSize: 11, color: scheme.onSurface.withOpacity(0.5))),
                            if (unrepliedCount > 0) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: Text('$unrepliedCount', style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                              )
                            ]
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
