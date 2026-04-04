import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/providers.dart';
import 'presentation/screens/menu_screen.dart';

class PinballBounceApp extends ConsumerStatefulWidget {
  const PinballBounceApp({super.key});

  @override
  ConsumerState<PinballBounceApp> createState() => _PinballBounceAppState();
}

class _PinballBounceAppState extends ConsumerState<PinballBounceApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(progressProvider.notifier).load();

      // Wire IAP purchases -> progress + ads
      final progress = ref.read(progressProvider);
      if (progress.adsRemoved) {
        ref.read(adServiceProvider).setAdsRemoved(true);
      }

      ref.read(iapServiceProvider).addListener((productId, success) {
        if (success && productId == GameConstants.removeAdsProductId) {
          ref.read(progressProvider.notifier).setAdsRemoved(true);
          ref.read(adServiceProvider).setAdsRemoved(true);
        }
      });

      // Wire sound setting -> audio service
      ref.read(audioServiceProvider).enabled =
          ref.read(settingsProvider).soundEnabled;
    });

    // Keep audio service in sync with settings
    ref.listenManual(settingsProvider, (prev, next) {
      if (prev?.soundEnabled != next.soundEnabled) {
        ref.read(audioServiceProvider).enabled = next.soundEnabled;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Pinball Bounce',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: Locale(settings.locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MenuScreen(),
    );
  }
}
