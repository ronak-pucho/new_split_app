import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_spilit/provider/user_provider.dart';
import 'package:we_spilit/model/account_request_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _msgCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

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

  Future<void> _submitMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    
    setState(() => _loading = true);
    try {
      await context.read<UserProvider>().submitActivationRequest(text);
      _msgCtrl.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        String errMsg = 'Failed to submit request';
        if (e.toString().contains('Message limit reached')) {
          errMsg = e.toString().replaceFirst('Exception: ', '');
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errMsg, style: GoogleFonts.inter()),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: uid == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('account_requests').where('userId', isEqualTo: uid).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 64, color: scheme.onSurface.withOpacity(0.2)),
                                const SizedBox(height: 16),
                                Text('Start a conversation with support.', style: GoogleFonts.inter(color: scheme.onSurface.withOpacity(0.5))),
                              ],
                            ),
                          );
                        }

                        final docs = snapshot.data!.docs;
                        final requests = docs.map((d) => AccountRequestModel.fromJson(d.data() as Map<String, dynamic>)).toList();
                        requests.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: requests.length,
                          itemBuilder: (ctx, i) {
                            final req = requests[i];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // User Bubble (Right)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8, left: 48),
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF7B1FA2),
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
                                        Text(req.message, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                                        const SizedBox(height: 4),
                                        Text(timeago.format(req.timestamp), style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
                                      ],
                                    ),
                                  ),
                                ),
                                // Admin Bubble (Left) if replied
                                if (req.adminReply != null)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12, right: 48),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: scheme.onSurface.withOpacity(0.08),
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
                                          Text(req.adminReply!, style: GoogleFonts.inter(fontSize: 14, color: scheme.onSurface)),
                                          const SizedBox(height: 4),
                                          Text('Admin • ${timeago.format(req.adminReplyTime ?? DateTime.now())}', style: GoogleFonts.inter(fontSize: 10, color: scheme.onSurface.withOpacity(0.5))),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (_) => _submitMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _loading
                      ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                      : CircleAvatar(
                          backgroundColor: const Color(0xFF7B1FA2),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white, size: 18),
                            onPressed: _submitMessage,
                          ),
                        )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
