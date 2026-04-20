import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/provider/admin_provider.dart';
import 'AdminGroupDetailsScreen.dart';

class AdminGroupsScreen extends StatelessWidget {
  const AdminGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final adminProvider = context.watch<AdminProvider>();
    final groups = adminProvider.groups;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Groups', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: groups.isEmpty
          ? Center(child: Text('No groups found', style: GoogleFonts.inter()))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
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
                        offset: const Offset(0, 3)
                      )
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: scheme.primary.withOpacity(0.15),
                      child: const Icon(Icons.group, color: Color(0xFF7B1FA2)),
                    ),
                    title: Text(group.groupName, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Type: ${group.groupType}', style: GoogleFonts.inter(fontSize: 12)),
                        Text('Members: ${group.friends.length}', style: GoogleFonts.inter(fontSize: 12)),
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
                        MaterialPageRoute(builder: (_) => AdminGroupDetailsScreen(group: group)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
