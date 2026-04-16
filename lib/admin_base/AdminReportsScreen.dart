import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/model/admin_log_model.dart';
import 'package:we_spilit/provider/admin_provider.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final logs = adminProvider.logs;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF7B1FA2),
            title: Text('Reports & Logs',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => adminProvider.fetchLogs(),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: logs.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7B1FA2).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.article_outlined,
                                size: 40, color: Color(0xFF7B1FA2)),
                          ),
                          const SizedBox(height: 16),
                          Text('No audit logs yet',
                              style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text('Admin actions will appear here',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.45))),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildLogCard(ctx, logs[i]),
                      childCount: logs.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, AdminLogModel log) {
    final scheme = Theme.of(context).colorScheme;
    final icon = _iconForAction(log.action);
    final color = _colorForAction(log.action);
    final label = _labelForAction(log.action);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(label,
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: color)),
                    ),
                    const Spacer(),
                    Text(
                      _formatTime(log.timestamp),
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: scheme.onSurface.withOpacity(0.4)),
                    ),
                  ],
                ),
                if (log.targetEmail != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    log.targetEmail!,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
                if (log.adminUid != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'By admin: ${log.adminUid!.substring(0, 8)}…',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: scheme.onSurface.withOpacity(0.45)),
                  ),
                ],
                if (log.oldData != null || log.newData != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: scheme.onSurface.withOpacity(0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (log.oldData != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.remove_circle_outline, 
                                size: 14, color: AppColors.error),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text('Previous: ${log.oldData}', 
                                  style: GoogleFonts.inter(
                                    fontSize: 12, 
                                    color: scheme.onSurface.withOpacity(0.7))),
                              ),
                            ],
                          ),
                        if (log.oldData != null && log.newData != null)
                          const SizedBox(height: 6),
                        if (log.newData != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.add_circle_outline, 
                                size: 14, color: AppColors.success),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text('Updated: ${log.newData}', 
                                  style: GoogleFonts.inter(
                                    fontSize: 12, 
                                    fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForAction(String action) {
    switch (action) {
      case 'user_deleted':
        return Icons.person_remove_outlined;
      case 'user_created':
        return Icons.person_add_outlined;
      case 'admin_login':
        return Icons.admin_panel_settings_outlined;
      case 'admin_logout':
        return Icons.logout_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _colorForAction(String action) {
    switch (action) {
      case 'user_deleted':
        return AppColors.error;
      case 'user_created':
        return AppColors.success;
      case 'admin_login':
        return const Color(0xFF7B1FA2);
      case 'admin_logout':
        return AppColors.error;
      default:
        return AppColors.accent;
    }
  }

  String _labelForAction(String action) {
    switch (action) {
      case 'user_deleted':
        return 'USER DELETED';
      case 'user_created':
        return 'USER CREATED';
      case 'admin_login':
        return 'ADMIN LOGIN';
      case 'admin_logout':
        return 'ADMIN LOGOUT';
      default:
        return action.toUpperCase();
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
