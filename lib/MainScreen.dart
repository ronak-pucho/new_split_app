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

  final List<Widget> _pages = [
    const HomeScreen(),
    GroupsScreen(),
    const ExpensesScreen(),
    const AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Safe context read after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
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
      bottomNavigationBar: BottomNavigationBar(
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
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
      ),
    );
  }
}
