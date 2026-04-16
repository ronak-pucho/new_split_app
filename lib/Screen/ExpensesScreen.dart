import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/Screen/AddExpenseScreen.dart';
import 'package:we_spilit/common/helper/helper.dart';
import 'package:we_spilit/common/widgets/avatar_widget.dart';
import 'package:we_spilit/provider/friends_provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});
  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final expenses = context.watch<FriendsProvider>().getExpense();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: scheme.primary,
            title: Text('Expenses', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
            // actions: [
            //   IconButton(
            //     icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            //     onPressed: () => Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (_) => const AddExpenseScreen())),
            //   ),
            // ],
          ),
          expenses.isEmpty
              ? SliverFillRemaining(child: _buildEmpty(scheme))
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildExpenseCard(ctx, expenses[i]),
                      childCount: expenses.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
        icon: const Icon(Icons.add),
        label: Text('Add Expense', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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
              child: Icon(Icons.receipt_long_outlined, size: 44, color: scheme.primary),
            ),
            const SizedBox(height: 20),
            Text('No expenses yet', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Add an expense to get started', style: GoogleFonts.inter(fontSize: 14, color: scheme.onSurface.withOpacity(0.5))),
          ],
        ),
      );

  Widget _buildExpenseCard(BuildContext context, dynamic expense) {
    final provider = context.read<FriendsProvider>();
    final scheme = Theme.of(context).colorScheme;
    final perHead = expense.amount != null && expense.members != null ? divideAmount(expense.amount!, expense.members!) : 0.0;

    return Dismissible(
      key: Key('exp_${expense.fId}_${expense.description}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => provider.deleteExpense(expense.fId),
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
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetails(context, expense),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AvatarWidget(
                  name: joinString(expense.fName, expense.lName),
                  radius: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        joinString(expense.fName, expense.lName),
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expense.description ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 12, color: scheme.onSurface.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${expense.amount}',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: scheme.primary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${perHead.toStringAsFixed(2)}/each',
                      style: GoogleFonts.inter(fontSize: 11, color: scheme.onSurface.withOpacity(0.45)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Delete Expense?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          content: Text('This cannot be undone.', style: GoogleFonts.inter()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.inter())),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: GoogleFonts.inter(color: Colors.red))),
          ],
        ),
      );

  void _showDetails(BuildContext context, dynamic expense) {
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(joinString(expense.fName, expense.lName), style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _detailRow(context, 'Amount', '₹${expense.amount}'),
            _detailRow(context, 'Members', '${expense.members}'),
            _detailRow(context, 'Per Person', '₹${divideAmount(expense.amount!, expense.members!).toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Divider(color: scheme.primary.withOpacity(0.3)),
            const SizedBox(height: 4),
            Text(expense.description ?? '', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13)),
            const SizedBox(height: 8),
            Text(
              'Paid by ${joinString(expense.fName, expense.lName)}',
              style: GoogleFonts.inter(color: scheme.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
