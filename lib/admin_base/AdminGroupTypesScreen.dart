import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/model/group_type_model.dart';
import 'package:we_spilit/provider/group_type_provider.dart';
import 'package:we_spilit/common/widgets/app_button.dart';
import 'package:we_spilit/common/widgets/app_text_field.dart';

class AdminGroupTypesScreen extends StatefulWidget {
  const AdminGroupTypesScreen({super.key});

  @override
  State<AdminGroupTypesScreen> createState() => _AdminGroupTypesScreenState();
}

class _AdminGroupTypesScreenState extends State<AdminGroupTypesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typeProv = context.watch<GroupTypeProvider>();
    final scheme = Theme.of(context).colorScheme;

    final filtered = typeProv.groupTypes
        .where((c) => c.name.toLowerCase().contains(_query))
        .toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('Group Type', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        onPressed: () => _showDialog(context, null),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: const Color(0xFF7B1FA2),
            title: Text('Group Types (${typeProv.groupTypes.length})',
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
                    hintText: 'Search group types…',
                    hintStyle: GoogleFonts.inter(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
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
          ),
          typeProv.isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
              : filtered.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                      child: Text('No group types found.',
                          style: GoogleFonts.inter(
                              color: scheme.onSurface.withOpacity(0.4))),
                    ))
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) =>
                              _buildCard(ctx, filtered[i], typeProv),
                          childCount: filtered.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, GroupTypeModel gt, GroupTypeProvider provider) {
    return Dismissible(
      key: Key(gt.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context, gt),
      onDismissed: (_) {
        provider.deleteGroupType(gt.id, gt.name);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${gt.name} deleted', style: GoogleFonts.inter()),
          backgroundColor: AppColors.error,
        ));
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
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF7B1FA2).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.style_outlined, color: Color(0xFF7B1FA2)),
          ),
          title: Text(gt.name,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF7B1FA2)),
            onPressed: () => _showDialog(context, gt),
          ),
          onTap: () => _showDialog(context, gt),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, GroupTypeModel gt) =>
      showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Delete Group Type?',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, color: AppColors.error)),
          content: Text(
            'Are you sure you want to delete ${gt.name}?\nExisting groups with this type will retain the name but it will lose association.',
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

  void _showDialog(BuildContext context, GroupTypeModel? existing) {
    final isEdit = existing != null;
    final ctrl = TextEditingController(text: isEdit ? existing.name : '');
    final formKey = GlobalKey<FormState>();
    bool loading = false;

    showModalBottomSheet(
       context: context,
       isScrollControlled: true,
       shape: const RoundedRectangleBorder(
           borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
       builder: (ctx) {
         return StatefulBuilder(builder: (ctx, setBS) {
           return Padding(
             padding: EdgeInsets.fromLTRB(24, 24, 24,
                 MediaQuery.of(ctx).viewInsets.bottom + 32),
             child: Form(
               key: formKey,
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(isEdit ? 'Edit Group Type' : 'New Group Type',
                       style: GoogleFonts.inter(
                           fontSize: 18, fontWeight: FontWeight.w700)),
                   const SizedBox(height: 16),
                   AppTextField(
                     controller: ctrl,
                     label: 'Type Name',
                     prefixIcon: Icons.label_outline,
                     validator: (v) => v == null || v.trim().isEmpty
                         ? 'Name cannot be empty'
                         : null,
                   ),
                   const SizedBox(height: 24),
                   AppButton(
                     label: isEdit ? 'Save Changes' : 'Create',
                     isLoading: loading,
                     onPressed: () async {
                       if (!formKey.currentState!.validate()) return;
                       setBS(() => loading = true);
                       try {
                         final prov = context.read<GroupTypeProvider>();
                         if (isEdit) {
                           await prov.updateGroupType(existing.id, ctrl.text);
                         } else {
                           await prov.addGroupType(ctrl.text);
                         }
                         if (ctx.mounted) {
                           Navigator.pop(ctx);
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                             content: Text('Saved successfully', style: GoogleFonts.inter()),
                             backgroundColor: AppColors.success,
                           ));
                         }
                       } catch (_) {
                         if (ctx.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                             content: Text('Failed to save group type', style: GoogleFonts.inter()),
                             backgroundColor: AppColors.error,
                           ));
                         }
                       } finally {
                         if (ctx.mounted) setBS(() => loading = false);
                       }
                     },
                   ),
                 ],
               ),
             ),
           );
         });
       },
    );
  }
}
