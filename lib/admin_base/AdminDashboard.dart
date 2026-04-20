import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_spilit/Screen/LoginScreen.dart';
import 'package:we_spilit/admin_base/AdminAnalyticsScreen.dart';
import 'package:we_spilit/admin_base/AdminReportsScreen.dart';
import 'package:we_spilit/admin_base/AdminUserListScreen.dart';
import 'package:we_spilit/admin_base/AdminGroupsScreen.dart';
import 'package:we_spilit/admin_base/AdminSettingsScreen.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/provider/admin_provider.dart';
import 'package:we_spilit/provider/auth_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _DashboardHome(),
    const AdminUserListScreen(),
    const AdminAnalyticsScreen(),
    const AdminSettingsScreen(),
    const AdminReportsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AdminProvider>();
      await provider.fetchAllUsers();
      await provider.fetchLogs();
      await provider.fetchRequests();
      await provider.fetchAllGroups();
      
      if (mounted) {
        final unreplied = provider.requests.where((r) => r.adminReply == null).toList();
        if (unreplied.isNotEmpty) {
          final Set<String> names = unreplied.map((r) => r.userName).toSet();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Pending Replies', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.error)),
              content: Text('Please reply to pending messages from:\n\n${names.join('\n')}', style: GoogleFonts.inter()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                )
              ]
            )
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final adminProvider = context.watch<AdminProvider>();
    final requestsCount = adminProvider.requests.length;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF7B1FA2),
        unselectedItemColor: scheme.onSurface.withOpacity(0.4),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: requestsCount > 0,
              label: Text('$requestsCount'),
              backgroundColor: AppColors.error,
              child: const Icon(Icons.people_outline),
            ),
            activeIcon: Badge(
              isLabelVisible: requestsCount > 0,
              label: Text('$requestsCount'),
              backgroundColor: AppColors.error,
              child: const Icon(Icons.people),
            ),
            label: 'Users',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

// ── Dashboard Home Tab ──────────────────────────────────────────────────────
class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF7B1FA2),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.adminGradient,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text('Admin Panel',
                            style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('We Split — Control Center',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: Text('Dashboard',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Logout',
                onPressed: () => _confirmLogout(context),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── KPI cards ────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _kpiCard(
                        context,
                        label: 'Total Users',
                        value: '${adminProvider.totalUsers}',
                        icon: Icons.people_outline,
                        color: const Color(0xFF7B1FA2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _kpiCard(
                        context,
                        label: 'Active Users',
                        value: '${adminProvider.activeUsers}',
                        icon: Icons.person_outline,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _kpiCard(
                        context,
                        label: 'Categories',
                        value:
                            '${adminProvider.categoryDistribution.keys.length}',
                        icon: Icons.category_outlined,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _kpiCard(
                        context,
                        label: 'Audit Logs',
                        value: '${adminProvider.logs.length}',
                        icon: Icons.article_outlined,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminGroupsScreen())),
                        child: _kpiCard(
                          context,
                          label: 'Groups',
                          value: '${adminProvider.groups.length}',
                          icon: Icons.group_outlined,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: const SizedBox()), // Empty slot for balance
                  ],
                ),
                const SizedBox(height: 24),

                // ── Category breakdown ───────────────────────────────────
                Text('User Categories',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...adminProvider.categoryDistribution.entries.map((e) {
                  final pct = adminProvider.totalUsers > 0
                      ? e.value / adminProvider.totalUsers
                      : 0.0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600)),
                            Text('${e.value} users',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: pct,
                          backgroundColor:
                              const Color(0xFF7B1FA2).withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF7B1FA2)),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),
                // ── Recent Users ─────────────────────────────────────────
                Text('Recent Users',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...adminProvider.users.take(5).map((u) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8)
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor:
                                const Color(0xFF7B1FA2).withOpacity(0.15),
                            child: Text(
                              u.userName.isNotEmpty
                                  ? u.userName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: Color(0xFF7B1FA2),
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u.userName,
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600)),
                                Text(u.userEmail,
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: u.status == 'active'
                                  ? AppColors.success.withOpacity(0.15)
                                  : Colors.grey.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              u.status,
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: u.status == 'active'
                                      ? AppColors.success
                                      : Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(BuildContext context,
      {required String label,
      required String value,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5))),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('Exit the admin panel.', style: GoogleFonts.inter()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter())),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              final admin = FirebaseAuth.instance.currentUser;
              if (admin != null) {
                await context.read<AdminProvider>().logAdminLogout(admin.uid, admin.email);
              }
              await context.read<AuthenticateProvider>().logout(context);
              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text('Logout',
                style: GoogleFonts.inter(
                    color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
