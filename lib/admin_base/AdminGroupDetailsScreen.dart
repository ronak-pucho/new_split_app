import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/provider/admin_provider.dart';
import 'package:we_spilit/model/group_model.dart';
import 'package:we_spilit/model/user_model.dart';

class AdminGroupDetailsScreen extends StatelessWidget {
  final GroupModel group;
  const AdminGroupDetailsScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final adminProvider = context.watch<AdminProvider>();
    
    final List<UserModel> groupMembers = [];
    for (var uid in group.friends) {
      final user = adminProvider.users.where((u) => u.userId == uid).firstOrNull;
      if (user != null) {
        groupMembers.add(user);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(group.groupName, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.05),
              border: Border(bottom: BorderSide(color: scheme.primary.withOpacity(0.1))),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: scheme.primary.withOpacity(0.2),
                  child: const Icon(Icons.group, size: 36, color: Color(0xFF7B1FA2)),
                ),
                const SizedBox(height: 16),
                Text(group.groupName, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${group.groupType} • ${groupMembers.length} Members', 
                    style: GoogleFonts.inter(fontSize: 14, color: scheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: group.isActive ? AppColors.success.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    group.isActive ? 'Active' : 'Inactive',
                    style: GoogleFonts.inter(
                      fontSize: 13, 
                      fontWeight: FontWeight.w600, 
                      color: group.isActive ? AppColors.success : Colors.grey
                    )
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupMembers.length,
              itemBuilder: (context, index) {
                final member = groupMembers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2)
                      )
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: scheme.primary.withOpacity(0.1),
                      child: Text(
                        member.userName.isNotEmpty ? member.userName[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7B1FA2)),
                      ),
                    ),
                    title: Text(member.userName, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    subtitle: Text(member.userEmail, style: GoogleFonts.inter(fontSize: 12, color: scheme.onSurface.withOpacity(0.5))),
                  ),
                );
              },
            ),
          )
        ],
      )
    );
  }
}
