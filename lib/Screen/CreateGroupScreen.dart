import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/common/widgets/app_button.dart';
import 'package:we_spilit/common/widgets/app_text_field.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/model/group_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_spilit/model/user_model.dart';
import 'package:we_spilit/provider/friends_provider.dart';
import 'package:we_spilit/provider/group_type_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  final GroupModel? group;
  const CreateGroupScreen({super.key, this.group});
  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String? _selectedType;
  final List<String> _selectedFriends = [];
  String _userSearchQuery = '';
  bool _loading = false;

  bool get _isEditing => widget.group != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupTypeProvider>().fetchGroupTypes();
    });
    final g = widget.group;
    if (g != null) {
      _nameCtrl.text = g.groupName;
      _selectedType = g.groupType;
      _selectedFriends.addAll(g.friends);
    } else {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid != null) {
        _selectedFriends.add(currentUid);
      }
    }
  }

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
      final groupId = _isEditing ? widget.group!.groupId : DateTime.now().millisecondsSinceEpoch.toString();
      final groupModel = GroupModel(
        groupId: groupId,
        groupName: _nameCtrl.text.trim(),
        groupType: _selectedType!,
        friends: _selectedFriends,
      );
      if (_isEditing) {
        await context.read<FriendsProvider>().updateFirebaseGroupData(groupModel);
      } else {
        await context.read<FriendsProvider>().setFirebaseGroupData(groupModel);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(_isEditing ? 'Group updated successfully!' : 'Group created successfully! 🎉', style: GoogleFonts.inter()),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditing ? 'Failed to update group.' : 'Failed to create group.', style: GoogleFonts.inter()),
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
        title: Text(_isEditing ? 'Edit Group' : 'Create Group',
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
              Consumer<GroupTypeProvider>(
                builder: (ctx, gtProvider, _) {
                  if (gtProvider.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (gtProvider.groupTypes.isEmpty) {
                    return Text('No group types available.', style: GoogleFonts.inter(color: scheme.onSurface.withOpacity(0.5)));
                  }
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: gtProvider.groupTypes.map((gt) {
                      final label = gt.name;
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
                              Icon(Icons.label_outline,
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
                  );
                }
              ),
              const SizedBox(height: 24),

              // Friend selector
              Text('Add Members',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface.withOpacity(0.55),
                      letterSpacing: 0.8)),
              const SizedBox(height: 8),

              // Search input
              TextField(
                onChanged: (v) => setState(() => _userSearchQuery = v.trim().toLowerCase()),
                style: GoogleFonts.inter(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search users by name or email...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: scheme.onSurface.withOpacity(0.04),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users')
                    .where('userType', isEqualTo: 'user')
                    .where('status', isEqualTo: 'active')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text('No active users found on the platform.', style: GoogleFonts.inter(color: scheme.onSurface.withOpacity(0.4))),
                    );
                  }

                  final currentUid = FirebaseAuth.instance.currentUser?.uid;
                  final rawUsers = snapshot.data!.docs.map((d) => UserModel.fromJson(d.data() as Map<String, dynamic>)).toList();
                  
                  UserModel? me;
                  if (currentUid != null) {
                    try { me = rawUsers.firstWhere((u) => u.userId == currentUid); } catch(_) {}
                  }

                  final otherUsers = rawUsers
                    .where((u) => u.userId != currentUid) 
                    .where((u) => 
                       u.userName.toLowerCase().contains(_userSearchQuery) || 
                       u.userEmail.toLowerCase().contains(_userSearchQuery))
                    .toList();

                  final displayUsers = <UserModel>[];
                  if (me != null && (me.userName.toLowerCase().contains(_userSearchQuery) || me.userEmail.toLowerCase().contains(_userSearchQuery) || _userSearchQuery.isEmpty)) {
                     displayUsers.add(me);
                  }
                  displayUsers.addAll(otherUsers);

                  if (displayUsers.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text('No matching users found.', style: GoogleFonts.inter(color: scheme.onSurface.withOpacity(0.4))),
                    );
                  }

                  return Container(
                    constraints: const BoxConstraints(maxHeight: 320),
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: displayUsers.map((u) {
                          final isMe = u.userId == currentUid;
                          final checked = isMe ? true : _selectedFriends.contains(u.userId);

                          return CheckboxListTile.adaptive(
                          title: Text(isMe ? '${u.userName} (You)' : u.userName,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(u.userEmail,
                              style:
                                  GoogleFonts.inter(fontSize: 12, color: scheme.onSurface.withOpacity(0.5))),
                          secondary: CircleAvatar(
                            radius: 16,
                            backgroundColor: scheme.primary.withOpacity(0.15),
                            backgroundImage: u.photoUrl != null && u.photoUrl!.isNotEmpty ? NetworkImage(u.photoUrl!) : null,
                            child: u.photoUrl == null || u.photoUrl!.isEmpty ? Text(
                              u.userName.isNotEmpty ? u.userName[0].toUpperCase() : '?',
                              style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600, fontSize: 13),
                            ) : null,
                          ),
                          value: checked,
                          activeColor: scheme.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          onChanged: isMe ? null : (val) => setState(() {
                            if (val == true) {
                              _selectedFriends.add(u.userId);
                            } else {
                              _selectedFriends.remove(u.userId);
                            }
                          }),
                        );
                      }).toList(),
                      ),
                    ),
                  );
                }
              ),
              const SizedBox(height: 32),
              AppButton(
                label: _isEditing ? 'Save Changes' : 'Create Group',
                isLoading: _loading,
                onPressed: _createGroup,
                icon: _isEditing ? Icons.save_outlined : Icons.group_add_outlined,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
