import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Handles iOS App Tracking Transparency (ATT) and Google UMP consent.
class ConsentService {
  /// Request all necessary user consent.
  Future<void> requestConsent() async {
    if (Platform.isIOS) {
      final status =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }

    await _requestUmpConsent();
  }

  Future<void> _requestUmpConsent() async {
    final params = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _showConsentForm();
        }
      },
      (error) {
        // Consent info update failed; continue silently.
      },
    );
  }

  void _showConsentForm() {
    ConsentForm.loadConsentForm(
      (consentForm) {
        consentForm.show((formError) {
          // Form dismissed; continue.
        });
      },
      (formError) {
        // Form failed to load; continue silently.
      },
    );
  }
}
