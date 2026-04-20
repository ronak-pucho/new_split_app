import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/model/user_model.dart';
import 'package:we_spilit/provider/admin_provider.dart';
import 'package:we_spilit/admin_base/AdminRequestsScreen.dart';
import 'package:we_spilit/admin_base/AdminGroupDetailsScreen.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});
  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  final _groupSearchCtrl = TextEditingController();
  String _groupQuery = '';

  String? _filterStatus;
  String? _filterType;
  String? _filterCategory;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _groupSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final filtered = adminProvider.users.where((u) {
      final qMatches = u.userName.toLowerCase().contains(_query) || u.userEmail.toLowerCase().contains(_query);
      if (!qMatches) return false;

      if (_filterStatus != null && u.status != _filterStatus) return false;
      if (_filterType != null && (u.userType ?? 'user') != _filterType) return false;
      if (_filterCategory != null && u.category != _filterCategory) return false;

      return true;
    }).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF7B1FA2),
          foregroundColor: Colors.white,
          title: Text('Access Management', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Groups'),
            ],
          ),
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.inbox_outlined, color: Colors.white),
                  tooltip: 'Support Inbox',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRequestsScreen())),
                ),
                if (adminProvider.requests.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                      child: Text('${adminProvider.requests.length}',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                adminProvider.fetchAllUsers();
                adminProvider.fetchAllGroups();
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // ── USERS TAB ──
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    color: const Color(0xFF7B1FA2),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                            style: GoogleFonts.inter(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search by name or email…',
                              hintStyle: GoogleFonts.inter(color: Colors.white54),
                              prefixIcon: const Icon(Icons.search, color: Colors.white54),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.18),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: (_filterStatus != null || _filterType != null || _filterCategory != null)
                                ? AppColors.warning
                                : Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.filter_list, color: Colors.white),
                            onPressed: () => _showFilterDialog(context, adminProvider),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔹 Content
                adminProvider.isLoading
                    ? const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : filtered.isEmpty
                        ? SliverFillRemaining(
                            child: Center(
                              child: Text(
                                'No users found.',
                                style: GoogleFonts.inter(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                ),
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) => _buildUserCard(ctx, filtered[i], adminProvider),
                                childCount: filtered.length,
                              ),
                            ),
                          ),
              ],
            ),

            // ── GROUPS TAB ──
            _buildGroupsTab(context, adminProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsTab(BuildContext context, AdminProvider adminProvider) {
    final scheme = Theme.of(context).colorScheme;

    final groups = adminProvider.groups.where((g) {
      if (_groupQuery.isEmpty) return true;
      return g.groupName.toLowerCase().contains(_groupQuery);
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: const Color(0xFF7B1FA2),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              controller: _groupSearchCtrl,
              onChanged: (v) => setState(() => _groupQuery = v.trim().toLowerCase()),
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search groups by name...',
                hintStyle: GoogleFonts.inter(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        groups.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No groups found',
                    style: GoogleFonts.inter(),
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final group = groups[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: scheme.primary.withOpacity(0.15),
                            child: const Icon(Icons.group, color: Color(0xFF7B1FA2)),
                          ),
                          title: Text(
                            group.groupName,
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Type: ${group.groupType}',
                                style: GoogleFonts.inter(fontSize: 12),
                              ),
                              Text(
                                'Members: ${group.friends.length}',
                                style: GoogleFonts.inter(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Switch(
                            value: group.isActive,
                            activeColor: AppColors.success,
                            onChanged: (val) async {
                              await context.read<AdminProvider>().toggleGroupStatus(group.groupId, val);
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminGroupDetailsScreen(group: group),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: groups.length,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user, AdminProvider provider) {
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF7B1FA2).withOpacity(0.15),
                backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null || user.photoUrl!.isEmpty
                    ? Text(
                        user.userName.isNotEmpty ? user.userName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Color(0xFF7B1FA2), fontWeight: FontWeight.w700, fontSize: 18),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.userName, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(user.userEmail, style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, children: [
                      if (user.category != null) _chip(user.category!, const Color(0xFF7B1FA2)),
                      _chip(
                        user.status,
                        user.status == 'active' ? AppColors.success : Colors.grey,
                      ),
                      _chip(
                        (user.userType ?? 'user').toUpperCase(),
                        user.userType == 'admin' ? AppColors.warning : Colors.blue,
                      ),
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
                  } else if (val == 'toggle_type') {
                    final newType = user.userType == 'admin' ? 'user' : 'admin';
                    await provider.toggleUserType(user.userId, user.userEmail, newType);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${user.userName} role changed to $newType', style: GoogleFonts.inter()),
                        backgroundColor: AppColors.success,
                      ));
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
                    value: 'toggle_type',
                    child: Row(
                      children: [
                        Icon(user.userType == 'admin' ? Icons.person : Icons.admin_panel_settings,
                            color: user.userType == 'admin' ? Colors.blue : Colors.orange, size: 20),
                        const SizedBox(width: 10),
                        Text(user.userType == 'admin' ? 'Make User' : 'Make Admin', style: GoogleFonts.inter()),
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
        child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
      );

  void _showFilterDialog(BuildContext context, AdminProvider provider) {
    final categories = provider.categoryDistribution.keys.toList();

    showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter Users', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  if (_filterStatus != null || _filterType != null || _filterCategory != null)
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _filterStatus = null;
                          _filterType = null;
                          _filterCategory = null;
                        });
                      },
                      child: Text('Clear', style: GoogleFonts.inter(color: AppColors.error)),
                    )
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    SegmentedButton<String?>(
                      segments: const [
                        ButtonSegment(value: null, label: Text('All')),
                        ButtonSegment(
                            value: 'active',
                            label: Text(
                              'Active',
                              maxLines: 1,
                            )),
                        ButtonSegment(
                            value: 'inactive',
                            label: Text(
                              'Inactive',
                              maxLines: 1,
                            )),
                      ],
                      selected: {_filterStatus},
                      onSelectionChanged: (val) => setModalState(() => _filterStatus = val.first),
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        selectedBackgroundColor: const Color(0xFF7B1FA2).withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Role', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    SegmentedButton<String?>(
                      segments: const [
                        ButtonSegment(value: null, label: Text('All')),
                        ButtonSegment(value: 'admin', label: Text('Admin', maxLines: 1)),
                        ButtonSegment(value: 'user', label: Text('User', maxLines: 1)),
                      ],
                      selected: {_filterType},
                      onSelectionChanged: (val) => setModalState(() => _filterType = val.first),
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        selectedBackgroundColor: const Color(0xFF7B1FA2).withOpacity(0.2),
                      ),
                    ),
                    if (categories.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Category', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String?>(
                        value: _filterCategory,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Categories')),
                          ...categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                        ],
                        onChanged: (val) => setModalState(() => _filterCategory = val),
                      ),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: GoogleFonts.inter()),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); // Updates the main screen
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B1FA2), foregroundColor: Colors.white),
                  child: Text('Apply Filters', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                )
              ],
            );
          });
        });
  }

  Future<bool?> _confirmDelete(BuildContext context, UserModel user) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Delete User?', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.error)),
          content: Text(
            'This will permanently delete ${user.userName} (${user.userEmail}) from the database.',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.inter())),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w700))),
          ],
        ),
      );
}
