import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/common/widgets/app_button.dart';
import 'package:we_spilit/common/widgets/app_text_field.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/model/group_model.dart';
import 'package:we_spilit/provider/friends_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});
  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String? _selectedType;
  final List<String> _selectedFriends = [];
  bool _loading = false;

  static const _types = [
    {'icon': Icons.home_outlined, 'label': 'Home'},
    {'icon': Icons.flight_outlined, 'label': 'Trip'},
    {'icon': Icons.people_outline, 'label': 'Friend'},
    {'icon': Icons.fastfood_outlined, 'label': 'Foodie'},
    {'icon': Icons.sports_esports_outlined, 'label': 'Buddy'},
    {'icon': Icons.family_restroom_outlined, 'label': 'Family'},
    {'icon': Icons.school_outlined, 'label': 'Study'},
    {'icon': Icons.more_horiz, 'label': 'Other'},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a group type.', style: GoogleFonts.inter()),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _loading = true);
    try {
      final groupId = DateTime.now().millisecondsSinceEpoch.toString();
      final groupModel = GroupModel(
        groupId: groupId,
        groupName: _nameCtrl.text.trim(),
        groupType: _selectedType!,
        friends: _selectedFriends,
      );
      await context.read<FriendsProvider>().setFirebaseGroupData(groupModel);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Group created successfully! 🎉', style: GoogleFonts.inter()),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to create group.', style: GoogleFonts.inter()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group name
              AppTextField(
                controller: _nameCtrl,
                label: 'Group Name',
                prefixIcon: Icons.group_outlined,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Group name is required'
                    : null,
              ),
              const SizedBox(height: 24),

              // Type selector
              Text('Group Type',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface.withOpacity(0.55),
                      letterSpacing: 0.8)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _types.map((t) {
                  final label = t['label'] as String;
                  final icon = t['icon'] as IconData;
                  final selected = _selectedType == label;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? scheme.primary
                            : scheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? scheme.primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon,
                              size: 18,
                              color: selected ? Colors.white : scheme.primary),
                          const SizedBox(width: 6),
                          Text(label,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : scheme.primary)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Friend selector
              Text('Add Friends',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface.withOpacity(0.55),
                      letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Consumer<FriendsProvider>(builder: (ctx, provider, _) {
                final friends = provider.getFriend();
                if (friends.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('No friends yet. Add friends first.',
                        style: GoogleFonts.inter(
                            color: scheme.onSurface.withOpacity(0.4))),
                  );
                }
                return Container(
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
                    children: friends.map((f) {
                      final checked = _selectedFriends.contains(f.fId);
                      return CheckboxListTile.adaptive(
                        title: Text('${f.fName} ${f.lName}',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500)),
                        subtitle: Text(f.fPhoneNumber,
                            style:
                                GoogleFonts.inter(fontSize: 12)),
                        value: checked,
                        activeColor: scheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onChanged: (val) => setState(() {
                          if (val == true) {
                            _selectedFriends.add(f.fId);
                          } else {
                            _selectedFriends.remove(f.fId);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                );
              }),
              const SizedBox(height: 32),
              AppButton(
                label: 'Create Group',
                isLoading: _loading,
                onPressed: _createGroup,
                icon: Icons.group_add_outlined,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
