import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/provider/admin_provider.dart';
import 'package:we_spilit/model/account_request_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminChatScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const AdminChatScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final _msgCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.userName, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
            Text(widget.userEmail, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _showReactivateDialog,
            child: Text('REACTIVATE', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
          )
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('account_requests').where('userId', isEqualTo: widget.userId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No messages found', style: GoogleFonts.inter(color: Colors.grey)));
            }
            
            final docs = snapshot.data!.docs;
            final requests = docs.map((d) => AccountRequestModel.fromJson(d.data() as Map<String, dynamic>)).toList();
            requests.sort((a, b) => a.timestamp.compareTo(b.timestamp));

            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

            final lastReq = requests.isNotEmpty ? requests.last : null;
            final needsReply = lastReq != null && lastReq.adminReply == null && lastReq.status == 'pending';

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    itemBuilder: (ctx, i) {
                      final req = requests[i];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8, right: 48),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: scheme.onSurface.withOpacity(0.05),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(4),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(req.message, style: GoogleFonts.inter(fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(timeago.format(req.timestamp), style: GoogleFonts.inter(fontSize: 10, color: scheme.onSurface.withOpacity(0.5))),
                                ],
                              ),
                            ),
                          ),
                          if (req.adminReply != null)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12, left: 48),
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE91E63),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(4),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(req.adminReply!, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                                    const SizedBox(height: 4),
                                    Text(timeago.format(req.adminReplyTime ?? DateTime.now()), style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                _buildInputBar(needsReply ? lastReq.requestId : null),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputBar(String? targetRequestId) {
    if (targetRequestId == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Text('Waiting for user response...', textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.grey)),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              decoration: InputDecoration(
                hintText: 'Type your reply...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF7B1FA2),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: () async {
                if (_msgCtrl.text.trim().isEmpty) return;
                final text = _msgCtrl.text.trim();
                _msgCtrl.clear();
                try {
                  await context.read<AdminProvider>().replyToRequest(targetRequestId, text);
                } catch (_) {}
              },
            ),
          )
        ],
      ),
    );
  }

  void _showReactivateDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reactivate User?', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.success)),
        content: Text('This will mark the requests as resolved and restore the user\'s access.', style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.inter())),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final provider = context.read<AdminProvider>();
                await provider.toggleUserStatus(widget.userId, widget.userEmail, 'active');
                
                final snap = await FirebaseFirestore.instance.collection('account_requests').where('userId', isEqualTo: widget.userId).where('status', isEqualTo: 'pending').get();
                for (var doc in snap.docs) {
                  await provider.resolveRequest(doc.id);
                }
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account Activated!', style: GoogleFonts.inter()), backgroundColor: AppColors.success));
                  Navigator.pop(context);
                }
              } catch (_) {}
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
            child: Text('Activate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ]
      )
    );
  }
}
