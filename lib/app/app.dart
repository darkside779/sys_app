// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/company_provider.dart';
import '../providers/driver_provider.dart';
import '../providers/user_provider.dart';
import '../services/notification_service.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/user/user_dashboard.dart';
import 'theme.dart';

class DeliverySystemApp extends StatelessWidget {
  const DeliverySystemApp({super.key});
  
  // Navigator key for global navigation
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // Set navigator key for notification service
    NotificationService.setNavigatorKey(navigatorKey);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CompanyProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Delivery System',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            
            // Localization configuration
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('ar'), // Arabic
            ],
            
            // Determine locale based on user preference or system default
            locale: _getLocale(authProvider),
            
            // RTL support
            localeResolutionCallback: (locale, supportedLocales) {
              // Check if the current device locale is supported
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              // If the locale of the device is not supported, use the first one
              // from the list (English, in this case).
              return supportedLocales.first;
            },
            
            // Theme configuration
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light, // Force light mode only
            
            // Initial route - always start with splash screen
            home: const SplashScreen(),
            
            // Builder to handle RTL support
            builder: (context, child) {
              return Directionality(
                textDirection: _getTextDirection(context),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }

  Locale? _getLocale(AuthProvider authProvider) {
    // Get user's preferred language from user profile
    if (authProvider.user != null) {
      return Locale(authProvider.user!.language);
    }
    // For unauthenticated users, use the current app language
    return Locale(authProvider.currentLanguage);
  }

  TextDirection _getTextDirection(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
  }

  Widget _getInitialScreen(AuthProvider authProvider) {
    // Route to appropriate screen based on authentication state
    switch (authProvider.state) {
      case AuthState.authenticated:
        return const UserDashboard();
      case AuthState.unauthenticated:
        return const LoginScreen();
      case AuthState.loading:
      case AuthState.initial:
      default:
        return const SplashScreen();
    }
  }
}
