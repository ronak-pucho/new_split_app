import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/Screen/SplashScreen.dart';
import 'package:we_spilit/ThemeProvider.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/firebase_options.dart';
import 'package:we_spilit/provider/admin_provider.dart';
import 'package:we_spilit/provider/auth_provider.dart';
import 'package:we_spilit/provider/friends_provider.dart';
import 'package:we_spilit/provider/search_provider.dart';
import 'package:we_spilit/provider/user_provider.dart';
import 'package:we_spilit/provider/category_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AuthenticateProvider()),
        ChangeNotifierProvider(create: (_) => FriendsProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: const WeSplitApp(),
    ),
  );
}

class WeSplitApp extends StatelessWidget {
  const WeSplitApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'We Split',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppColors.lightTheme(context),
      darkTheme: AppColors.darkTheme(context),
      home: const SplashScreen(),
    );
  }
}
