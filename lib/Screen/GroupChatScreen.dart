import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/model/group_model.dart';
import 'package:we_spilit/model/group_message_model.dart';
import 'package:we_spilit/model/user_model.dart';
import 'package:we_spilit/common/widgets/app_button.dart';
import 'package:we_spilit/common/widgets/app_text_field.dart';
import 'package:we_spilit/Screen/CreateGroupScreen.dart';

class GroupChatScreen extends StatefulWidget {
  final GroupModel group;
  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _msgCtrl = TextEditingController();
  final _db = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    if (_currentUser == null) return;
    try {
      final doc = await _db.collection('users').doc(_currentUser!.uid).get();
      if (doc.exists) {
        setState(() {
          _currentUserName = UserModel.fromJson(doc.data()!).userName;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _clearLocalUnread(List<QueryDocumentSnapshot> docs) {
    if (_currentUser == null) return;
    final unreadDocs = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return false;
      final unread = data['unreadBy'] as List<dynamic>?;
      if (unread == null) return false;
      return unread.contains(_currentUser!.uid);
    }).toList();

    if (unreadDocs.isNotEmpty) {
      Future.microtask(() async {
        final batch = _db.batch();
        
        for (final doc in unreadDocs) {
          batch.update(doc.reference, {
            'unreadBy': FieldValue.arrayRemove([_currentUser!.uid])
          });
        }
        
        batch.update(_db.collection('groups').doc(widget.group.groupId), {
           'unreadCounts.${_currentUser!.uid}': 0
        });

        await batch.commit();
      });
    }
  }

  Future<void> _sendMessage({
    String? text,
    bool isExpense = false,
    double? amount,
    String? expenseDesc,
  }) async {
    final msgText = text?.trim() ?? '';
    if (msgText.isEmpty && !isExpense) return;
    if (_currentUser == null) return;

    final unreadList = widget.group.friends.where((id) => id != _currentUser!.uid).toList();

    final msgId = DateTime.now().millisecondsSinceEpoch.toString();
    final model = GroupMessageModel(
      messageId: msgId,
      senderId: _currentUser!.uid,
      senderName: _currentUserName ?? 'Unknown',
      text: msgText,
      isExpense: isExpense,
      expenseAmount: amount,
      expenseDescription: expenseDesc,
      totalMembers: widget.group.friends.length,
      unreadBy: unreadList,
      timestamp: DateTime.now(),
    );

    _msgCtrl.clear();

    final batch = _db.batch();
    
    batch.set(
       _db.collection('groups').doc(widget.group.groupId).collection('messages').doc(msgId),
       model.toJson()
    );

    final groupRef = _db.collection('groups').doc(widget.group.groupId);
    for (final uid in unreadList) {
       batch.update(groupRef, {'unreadCounts.$uid': FieldValue.increment(1)});
    }

    await batch.commit();
  }

  void _showAddSplitModal() {
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Split Share', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                AppTextField(
                  controller: descCtrl,
                  label: 'What was this for?',
                  prefixIcon: Icons.description_outlined,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: amountCtrl,
                  label: 'Total Amount (₹)',
                  prefixIcon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Invalid number';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Add Split to Chat',
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    _sendMessage(
                      isExpense: true,
                      amount: double.parse(amountCtrl.text.trim()),
                      expenseDesc: descCtrl.text.trim(),
                    );
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.groupName, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18)),
            Text('${widget.group.groupType} • ${widget.group.friends.length} Members', 
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: scheme.onSurface.withOpacity(0.7))),
          ],
        ),
        actions: [
          if (widget.group.isActive)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateGroupScreen(group: widget.group))),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('groups')
                  .doc(widget.group.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final docs = snapshot.data!.docs;
                _clearLocalUnread(docs);

                if (docs.isEmpty) {
                  return Center(
                    child: Text('Say hi or add a split to start!', 
                        style: GoogleFonts.inter(color: scheme.onSurface.withOpacity(0.5))),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final msg = GroupMessageModel.fromJson(docs[i].data() as Map<String, dynamic>);
                    final isMe = msg.senderId == _currentUser?.uid;
                    return _buildMessageBubble(msg, isMe, scheme);
                  },
                );
              },
            ),
          ),
          
          // Chat Input Area
          if (!widget.group.isActive)
            Container(
              width: double.infinity,
              color: scheme.primary.withOpacity(0.1),
              padding: const EdgeInsets.all(16),
              child: Text(
                'This group is inactive and read-only.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: scheme.primary),
              ),
            )
          else 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _showAddSplitModal,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.currency_rupee, color: scheme.primary, size: 20),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    style: GoogleFonts.inter(),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.inter(color: scheme.onSurface.withOpacity(0.4)),
                      filled: true,
                      fillColor: scheme.onSurface.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (v) => _sendMessage(text: v),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _sendMessage(text: _msgCtrl.text),
                  icon: Icon(Icons.send, color: scheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(GroupMessageModel msg, bool isMe, ColorScheme scheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(msg.senderName, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: scheme.onSurface.withOpacity(0.5))),
            ),
          msg.isExpense ? _buildExpenseBubble(msg, isMe, scheme) : _buildTextBubble(msg, isMe, scheme),
        ],
      ),
    );
  }

  Widget _buildTextBubble(GroupMessageModel msg, bool isMe, ColorScheme scheme) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? scheme.primary : scheme.onSurface.withOpacity(0.08),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
          bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
        ),
      ),
      child: Text(
        msg.text,
        style: GoogleFonts.inter(color: isMe ? Colors.white : scheme.onSurface, fontSize: 14),
      ),
    );
  }

  Widget _buildExpenseBubble(GroupMessageModel msg, bool isMe, ColorScheme scheme) {
    final total = msg.expenseAmount ?? 0.0;
    final membersCount = msg.totalMembers ?? widget.group.friends.length;
    final perHead = membersCount > 0 ? (total / membersCount) : total;

    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? scheme.primary.withOpacity(0.15) : scheme.onSurface.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isMe ? scheme.primary.withOpacity(0.3) : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long, color: isMe ? scheme.primary : scheme.onSurface.withOpacity(0.7), size: 18),
              const SizedBox(width: 8),
              Text('Split Added', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: isMe ? scheme.primary : scheme.onSurface.withOpacity(0.7))),
            ],
          ),
          const SizedBox(height: 8),
          Text(msg.expenseDescription ?? 'Unknown Expense', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total', style: GoogleFonts.inter(fontSize: 11, color: scheme.onSurface.withOpacity(0.5))),
                  Text('₹${total.toStringAsFixed(2)}', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.error)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Your Share', style: GoogleFonts.inter(fontSize: 11, color: scheme.onSurface.withOpacity(0.5))),
                  Text('₹${perHead.toStringAsFixed(2)}', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: scheme.primary)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
