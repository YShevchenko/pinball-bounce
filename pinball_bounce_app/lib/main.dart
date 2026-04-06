import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/constants.dart';
import 'presentation/providers/providers.dart';
import 'services/ad_service.dart';
import 'services/consent_service.dart';
import 'services/iap_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Dark status bar for Neon Pulse theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  final prefs = await SharedPreferences.getInstance();

  // Request tracking/consent before initializing ads
  
  


  await ConsentService().requestConsent();

  // Initialize ad and IAP services before app starts
  final adService = AdService();
  try { await adService.initialize(); } catch (_) {}

  final iapService = IAPService();
  try { await iapService.initialize(); } catch (_) {}

  // Wire IAP purchases to update app state
  iapService.addListener((productId, success) {
    if (success && productId == GameConstants.removeAdsProductId) {
      adService.setAdsRemoved(true);
    }
  });

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        adServiceProvider.overrideWithValue(adService),
        iapServiceProvider.overrideWithValue(iapService),
      ],
      child: const PinballBounceApp(),
    ),
  );
}
