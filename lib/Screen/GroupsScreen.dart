import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/Screen/CreateGroupScreen.dart';
import 'package:we_spilit/model/group_model.dart';
import 'package:we_spilit/provider/friends_provider.dart';

class GroupsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: scheme.primary,
            title: Text('Groups', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
            // actions: [
            //   IconButton(
            //     icon: const Icon(Icons.group_add_outlined, color: Colors.white),
            //     onPressed: () => Navigator.push(context,
            //         MaterialPageRoute(builder: (_) => const CreateGroupScreen())),
            //   ),
            // ],
          ),
          Consumer<FriendsProvider>(builder: (context, provider, _) {
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: StreamBuilder<List<GroupModel>?>(
                stream: provider.getGroupData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                  }
                  final groups = snapshot.data;
                  if (groups == null || groups.isEmpty) {
                    return SliverFillRemaining(child: _buildEmpty(scheme));
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildGroupCard(ctx, groups[i], provider),
                      childCount: groups.length,
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateGroupScreen())),
        icon: const Icon(Icons.group_add_outlined),
        label: Text('New Group', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmpty(ColorScheme scheme) => Center(
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
              child: Icon(Icons.group_outlined, size: 44, color: scheme.primary),
            ),
            const SizedBox(height: 20),
            Text('No groups yet', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Create a group to split expenses together', style: GoogleFonts.inter(fontSize: 14, color: scheme.onSurface.withOpacity(0.5))),
          ],
        ),
      );

  Widget _buildGroupCard(BuildContext context, GroupModel group, FriendsProvider provider) {
    final scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: Key(group.groupId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) {
        provider.deleteGroup(group.groupId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${group.groupName} deleted', style: GoogleFonts.inter()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.group, color: Colors.white, size: 24),
          ),
          title: Text(group.groupName, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          subtitle: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(group.groupType, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: scheme.primary)),
              ),
              const SizedBox(width: 8),
              Text('${group.friends.length} members', style: GoogleFonts.inter(fontSize: 12, color: scheme.onSurface.withOpacity(0.45))),
            ],
          ),
          trailing: Icon(Icons.chevron_right, color: scheme.onSurface.withOpacity(0.3)),
          onTap: () => _showGroupDetails(context, group, provider),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Delete Group?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          content: Text('This cannot be undone.', style: GoogleFonts.inter()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.inter())),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: GoogleFonts.inter(color: Colors.red))),
          ],
        ),
      );

  void _showGroupDetails(BuildContext context, GroupModel group, FriendsProvider provider) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final names = <String>[];
    for (final id in group.friends) {
      final name = await provider.getFriendNameById(id);
      names.add(name ?? 'Unknown');
    }
    if (!context.mounted) return;
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(group.groupName, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${group.groupType}', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text('Members:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...names.map((n) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(children: [
                    const Icon(Icons.person_outline, size: 16),
                    const SizedBox(width: 6),
                    Text(n, style: GoogleFonts.inter()),
                  ]),
                )),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close', style: GoogleFonts.inter(fontWeight: FontWeight.w600)))],
      ),
    );
  }
}
