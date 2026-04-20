import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/Screen/AccountScreen.dart';
import 'package:we_spilit/Screen/ExpensesScreen.dart';
import 'package:we_spilit/provider/friends_provider.dart';
import 'package:we_spilit/provider/user_provider.dart';
import 'Screen/HomeScreen.dart';
import 'Screen/GroupsScreen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? _uid;

  // Stream of ALL group IDs the user belongs to, then we count unread messages
  // across all groups using a CollectionGroup query on 'messages'.
  Stream<int>? _totalUnreadStream;

  final List<Widget> _pages = [
    const HomeScreen(),
    GroupsScreen(),
    const ExpensesScreen(),
    const AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _uid = FirebaseAuth.instance.currentUser?.uid;
      if (_uid != null) {
        _totalUnreadStream = _buildUnreadStream(_uid!);
      }
    });
  }

  /// Listens to ALL messages (across every group) where unreadBy contains
  /// the current user. Uses a Firestore collectionGroup query so a single
  /// stream covers every group's messages subcollection.
  ///
  /// Requires a Firestore index:
  ///   Collection group : messages
  ///   Field            : unreadBy  (Arrays)
  Stream<int> _buildUnreadStream(String uid) {
    return FirebaseFirestore.instance.collectionGroup('messages').where('unreadBy', arrayContains: uid).snapshots().map((snap) => snap.docs.length);
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    await context.read<FriendsProvider>().getAllFriends();
    await context.read<UserProvider>().fetchCurrentUser();
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: StreamBuilder<int>(
        stream: _totalUnreadStream,
        builder: (context, snapshot) {
          final unreadCount = snapshot.data ?? 0;

          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: scheme.primary,
            unselectedItemColor: scheme.onSurface.withOpacity(0.45),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Friends',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                  child: const Icon(Icons.group_outlined),
                ),
                activeIcon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                  child: const Icon(Icons.group),
                ),
                label: 'Groups',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Expenses',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: user?.userName ?? 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}
