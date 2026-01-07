import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:run_to_canada/app/env.dart';
import 'package:run_to_canada/core/constants/app_constants.dart';
import 'package:run_to_canada/core/constants/route_constants.dart';
import 'package:run_to_canada/core/navigation/app_router.dart';
import 'package:run_to_canada/core/theme/app_theme.dart';
import 'package:run_to_canada/firebase_options.dart';
import 'package:run_to_canada/core/data/services/hive_service.dart';
import 'package:run_to_canada/core/services/ad_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive local database
  await HiveService.init();

  // Initialize Mapbox with access token
  MapboxOptions.setAccessToken(Env.mapboxToken);

  // Initialize AdMob
  await AdService.initialize();

  // Preload interstitial ad
  AdService().loadInterstitialAd();

  // Set preferred orientations (portrait only for now)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style (will be overridden by theme)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Dark icons for light mode
      systemNavigationBarColor: Colors.white, // Light background
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    // Wrap app with ProviderScope for Riverpod state management
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      // App configuration
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme - Light theme default with dark theme support
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Respects user's device settings

      // Routing - start with initial screen (checks onboarding status)
      initialRoute: RouteConstants.initialRoute,
      onGenerateRoute: AppRouter.generateRoute,

      // Localization (for future implementation)
      // supportedLocales: const [
      //   Locale('en', 'US'),
      // ],
    );
  }
}
