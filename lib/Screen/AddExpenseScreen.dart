import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/common/helper/helper.dart';
import 'package:we_spilit/common/widgets/app_button.dart';
import 'package:we_spilit/common/widgets/app_text_field.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/core/utils/validators.dart';
import 'package:we_spilit/model/friend_model.dart';
import 'package:we_spilit/provider/friends_provider.dart';
import 'package:we_spilit/provider/search_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final FriendsModel? expense;
  const AddExpenseScreen({super.key, this.expense});
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _memberCtrl = TextEditingController();
  FriendsModel? _selectedFriend;
  bool _loading = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    if (e != null) {
      _selectedFriend = e;
      _descCtrl.text = e.description ?? '';
      _amountCtrl.text = (e.amount ?? 0).toString();
      _memberCtrl.text = (e.members ?? 1).toString();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _memberCtrl.dispose();
    super.dispose();
  }

  Future<void> _addExpense() async {
    if (_selectedFriend == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a friend.', style: GoogleFonts.inter()),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final updatedFriend = FriendsModel(
        fId: _selectedFriend!.fId,
        userId: _selectedFriend!.userId,
        fName: _selectedFriend!.fName,
        lName: _selectedFriend!.lName,
        fPhoneNumber: _selectedFriend!.fPhoneNumber,
        fUpiId: _selectedFriend!.fUpiId,
        description: _descCtrl.text.trim(),
        amount: int.tryParse(_amountCtrl.text.trim()) ?? 0,
        members: int.tryParse(_memberCtrl.text.trim()) ?? 1,
        isExpenseDelete: _selectedFriend!.isExpenseDelete,
        isFriendsDelete: _selectedFriend!.isFriendsDelete,
      );
      await context.read<FriendsProvider>().setFireStoreExpanse(friendsModel: updatedFriend);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditing ? 'Expense updated successfully!' : 'Expense added successfully!', style: GoogleFonts.inter()),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditing ? 'Failed to update expense.' : 'Failed to add expense.', style: GoogleFonts.inter()),
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
        title: Text(_isEditing ? 'Edit Expense' : 'Add Expense', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Friend selector (disabled during edit) ─────────────────
              Text('With you and:',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.onSurface.withOpacity(0.55), letterSpacing: 0.8)),
              const SizedBox(height: 10),
              if (_isEditing) ...[
                if (_selectedFriend != null) _selectedFriendChip(scheme),
              ] else ...[
                AppTextField(
                  controller: _searchCtrl,
                  label: 'Search friend',
                  prefixIcon: Icons.search,
                  onChanged: (val) {
                    context.read<SearchProvider>().searchEvent(
                          val.trim().toLowerCase(),
                          context.read<FriendsProvider>().getFriend().map((e) => joinString(e.fName, e.lName).trim().toLowerCase()).toList(),
                        );
                  },
                ),
                const SizedBox(height: 8),
                Consumer<SearchProvider>(builder: (ctx, searchProv, _) {
                  if (searchProv.searchResult.isEmpty) {
                    return _selectedFriend != null ? _selectedFriendChip(scheme) : const SizedBox.shrink();
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10)],
                    ),
                    child: Column(
                      children: searchProv.searchResult.map((name) {
                        final friend = context.read<FriendsProvider>().addSearchData(name);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: scheme.primary.withOpacity(0.15),
                            child: Text(
                              name[0].toUpperCase(),
                              style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700),
                            ),
                          ),
                          title: Text(name.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' '),
                              style: GoogleFonts.inter()),
                          onTap: () {
                            setState(() {
                              _selectedFriend = friend;
                              _searchCtrl.clear();
                            });
                            context.read<SearchProvider>().clearSearch();
                          },
                        );
                      }).toList(),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 24),

              // ── Expense form ───────────────────────────────────────────
              Text('Expense Details',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.onSurface.withOpacity(0.55), letterSpacing: 0.8)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    AppTextField(
                      controller: _descCtrl,
                      label: 'Description',
                      prefixIcon: Icons.description_outlined,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Description is required' : null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _amountCtrl,
                      label: 'Total Amount (₹)',
                      prefixIcon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                      validator: Validators.amount,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _memberCtrl,
                      label: 'Number of Members',
                      prefixIcon: Icons.people_outline,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required';
                        }
                        final n = int.tryParse(v);
                        if (n == null || n < 1) return 'Enter a valid number';
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),

              // ── Preview ────────────────────────────────────────────────
              if (_selectedFriend != null && _amountCtrl.text.isNotEmpty && _memberCtrl.text.isNotEmpty) _buildPreview(scheme),

              const SizedBox(height: 32),
              AppButton(
                label: _isEditing ? 'Save Changes' : 'Add Expense',
                isLoading: _loading,
                onPressed: _addExpense,
                icon: _isEditing ? Icons.save_outlined : Icons.add_circle_outline,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectedFriendChip(ColorScheme scheme) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person, size: 18, color: scheme.primary),
            const SizedBox(width: 8),
            Text(
              '${_selectedFriend!.fName} ${_selectedFriend!.lName}',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: scheme.primary),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => setState(() => _selectedFriend = null),
              child: Icon(Icons.close_rounded, size: 16, color: scheme.primary),
            ),
          ],
        ),
      );

  Widget _buildPreview(ColorScheme scheme) {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final members = int.tryParse(_memberCtrl.text) ?? 1;
    final perHead = members > 0 ? amount / members : 0;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary.withOpacity(0.08), scheme.secondary.withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _previewStat('Total', '₹${amount.toStringAsFixed(0)}', scheme),
          Container(width: 1, height: 36, color: scheme.primary.withOpacity(0.2)),
          _previewStat('Members', '$members', scheme),
          Container(width: 1, height: 36, color: scheme.primary.withOpacity(0.2)),
          _previewStat('Per Person', '₹${perHead.toStringAsFixed(2)}', scheme),
        ],
      ),
    );
  }

  Widget _previewStat(String label, String value, ColorScheme scheme) => Column(
        children: [
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: scheme.primary)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: scheme.onSurface.withOpacity(0.5))),
        ],
      );
}
