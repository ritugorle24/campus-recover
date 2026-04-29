import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/item_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/handover_provider.dart';
import 'providers/notification_provider.dart';

// SCREEN IMPORTS
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/items/report_item_screen.dart';
import 'screens/items/item_detail_screen.dart';
import 'screens/items/my_items_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/handover/generate_qr_screen.dart';
import 'screens/handover/scan_qr_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FindItCampusApp());
}

class FindItCampusApp extends StatelessWidget {
  const FindItCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => HandoverProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'FindIt Campus',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/', // CRITICAL: Points to SplashScreen
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const MainScreen(initialIndex: 0),
          '/report': (context) => const ReportItemScreen(),
          '/my-items': (context) => const MyItemsScreen(),
          '/leaderboard': (context) => const LeaderboardScreen(),
          // Other tabs handled by MainScreen or individual routes
          '/search': (context) => const MainScreen(initialIndex: 1),
          '/alerts': (context) => const MainScreen(initialIndex: 2),
          '/profile': (context) => const MainScreen(initialIndex: 3),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/item-detail') {
            final itemId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) => ItemDetailScreen(itemId: itemId ?? ''),
            );
          }
          if (settings.name == '/chat') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => ChatScreen(
                matchId: args?['matchId'] ?? '',
                otherUserName: args?['otherUserName'] ?? 'Unknown',
                otherUserId: args?['otherUserId'] ?? '',
              ),
            );
          }
          if (settings.name == '/generate-qr') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => GenerateQrScreen(matchId: args?['matchId'] ?? ''),
            );
          }
          if (settings.name == '/scan-qr') {
            return MaterialPageRoute(
              builder: (context) => const ScanQrScreen(),
            );
          }
          return null;
        },
      ),
    );
  }
}
