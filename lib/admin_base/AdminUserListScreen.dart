import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/model/user_model.dart';
import 'package:we_spilit/provider/admin_provider.dart';
import 'package:we_spilit/admin_base/AdminRequestsScreen.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});
  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final filtered = adminProvider.users
        .where((u) =>
            u.userName.toLowerCase().contains(_query) ||
            u.userEmail.toLowerCase().contains(_query))
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: const Color(0xFF7B1FA2),
            title: Text('Users (${adminProvider.totalUsers})',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, color: Colors.white)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) =>
                      setState(() => _query = v.trim().toLowerCase()),
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by name or email…',
                    hintStyle: GoogleFonts.inter(color: Colors.white54),
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.inbox_outlined, color: Colors.white),
                    tooltip: 'Support Inbox',
                    onPressed: () => Navigator.push(context, 
                        MaterialPageRoute(builder: (_) => const AdminRequestsScreen())),
                  ),
                  if (adminProvider.requests.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.redAccent, shape: BoxShape.circle),
                        child: Text('${adminProvider.requests.length}',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => adminProvider.fetchAllUsers(),
              ),
            ],
          ),
          adminProvider.isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
              : filtered.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                      child: Text('No users found.',
                          style: GoogleFonts.inter(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4))),
                    ))
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) =>
                              _buildUserCard(ctx, filtered[i], adminProvider),
                          childCount: filtered.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildUserCard(
      BuildContext context, UserModel user, AdminProvider provider) {
    return Dismissible(
      key: Key(user.userId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context, user),
      onDismissed: (_) => provider.deleteUser(user.userId, user.userEmail),
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF7B1FA2).withOpacity(0.15),
                backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.photoUrl == null || user.photoUrl!.isEmpty
                    ? Text(
                        user.userName.isNotEmpty
                            ? user.userName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: Color(0xFF7B1FA2),
                            fontWeight: FontWeight.w700,
                            fontSize: 18),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.userName,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(user.userEmail,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5))),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, children: [
                      if (user.category != null)
                        _chip(user.category!, const Color(0xFF7B1FA2)),
                      _chip(
                        user.status,
                        user.status == 'active'
                            ? AppColors.success
                            : Colors.grey,
                      ),
                      if (user.isAdmin) _chip('Admin', AppColors.warning),
                    ]),
                  ],
                ),
              ),
              // Status toggle & Delete
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (val) async {
                  if (val == 'delete') {
                    final confirmed = await _confirmDelete(context, user);
                    if (confirmed == true) {
                      await provider.deleteUser(user.userId, user.userEmail);
                    }
                  } else if (val == 'toggle') {
                    final newStatus = user.status == 'active' ? 'inactive' : 'active';
                    await provider.toggleUserStatus(user.userId, user.userEmail, newStatus);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${user.userName} is now $newStatus', style: GoogleFonts.inter()),
                        backgroundColor: newStatus == 'active' ? AppColors.success : AppColors.error,
                      ));
                    }
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(user.status == 'active' ? Icons.block : Icons.check_circle_outline, 
                             color: user.status == 'active' ? Colors.orange : AppColors.success, size: 20),
                        const SizedBox(width: 10),
                        Text(user.status == 'active' ? 'Suspend User' : 'Activate User', style: GoogleFonts.inter()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Text('Delete User', style: GoogleFonts.inter(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color)),
      );

  Future<bool?> _confirmDelete(BuildContext context, UserModel user) =>
      showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Delete User?',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, color: AppColors.error)),
          content: Text(
            'This will permanently delete ${user.userName} (${user.userEmail}) from the database.',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: GoogleFonts.inter())),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete',
                    style: GoogleFonts.inter(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700))),
          ],
        ),
      );
}
