import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/Screen/AccountScreen.dart';
import 'package:we_spilit/Screen/CreateFriendScreen.dart';
import 'package:we_spilit/common/helper/helper.dart';
import 'package:we_spilit/common/widgets/avatar_widget.dart';
import 'package:we_spilit/model/friend_model.dart';
import 'package:we_spilit/provider/friends_provider.dart';
import 'package:we_spilit/provider/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = context.watch<UserProvider>().currentUser;
    final friends = context.watch<FriendsProvider>().getFriend();

    // Total shared across all friends
    double totalShared = 0;
    for (final f in friends) {
      if (f.amount != null && f.members != null && f.members! > 0) {
        totalShared += divideAmount(f.amount!, f.members!);
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Gradient App Bar ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: scheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.onSurface.withOpacity(0.70), scheme.primary.withOpacity(0.50)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, ${user?.userName.split(' ').first ?? 'there'} 👋',
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Manage your shared expenses',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AvatarWidget(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AccountScreen(),
                                    ));
                              },
                              imageUrl: user?.photoUrl,
                              name: user?.userName ?? 'U',
                              radius: 24,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Summary pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.receipt_long, size: 16, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                '₹${totalShared.toStringAsFixed(2)} total shared',
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // title: Text('Friends', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
            // actions: [
            //   IconButton(
            //     icon: const Icon(Icons.person_add_outlined,
            //         color: Colors.white),
            //     tooltip: 'Add Friend',
            //     onPressed: () => Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (_) => const CreateFriendScreen()),
            //     ),
            //   ),
            // ],
          ),

          // ── Body ─────────────────────────────────────────────────────────
          friends.isEmpty
              ? SliverFillRemaining(child: _buildEmpty(scheme))
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildFriendCard(ctx, friends[i]),
                      childCount: friends.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateFriendScreen()),
        ),
        icon: const Icon(Icons.person_add_outlined),
        label: Text('Add Friend', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmpty(ColorScheme scheme) {
    return Center(
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
            child: Icon(Icons.people_outline, size: 44, color: scheme.primary),
          ),
          const SizedBox(height: 20),
          Text('No friends yet', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Add a friend to start splitting expenses', style: GoogleFonts.inter(fontSize: 14, color: scheme.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildFriendCard(BuildContext context, FriendsModel friend) {
    final provider = context.read<FriendsProvider>();
    final scheme = Theme.of(context).colorScheme;
    final hasExpense = friend.amount != null && friend.amount! > 0 && friend.members != null;
    final perHead = hasExpense ? divideAmount(friend.amount!, friend.members!) : 0.0;

    return Dismissible(
      key: Key(friend.fId),
      direction: DismissDirection.endToStart,
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
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => provider.deleteFriends(friend.fId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: AvatarWidget(
            name: '${friend.fName} ${friend.lName}',
            radius: 24,
          ),
          title: Text(
            '${friend.fName} ${friend.lName}',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          subtitle: hasExpense
              ? Text(
                  '₹${perHead.toStringAsFixed(2)} each',
                  style: GoogleFonts.inter(fontSize: 12, color: scheme.primary),
                )
              : Text('No expenses yet', style: GoogleFonts.inter(fontSize: 12, color: scheme.onSurface.withOpacity(0.4))),
          trailing: IconButton(
            icon: Icon(Icons.qr_code_2_outlined, color: scheme.primary),
            onPressed: () => _showQrDialog(context, friend),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Remove Friend?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          content: Text('This will remove the friend and their expenses.', style: GoogleFonts.inter()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey))),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Remove', style: GoogleFonts.inter(color: Colors.red))),
          ],
        ),
      );

  void _showQrDialog(BuildContext context, FriendsModel f) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${f.fName} ${f.lName}', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('asset/qr.jpeg', width: 180, height: 180, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            Text(
              f.amount != null ? 'Shared: ₹${f.amount!.toStringAsFixed(0)}' : 'No expenses yet',
              style: GoogleFonts.inter(fontSize: 14),
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
}
