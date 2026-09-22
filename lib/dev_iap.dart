import 'package:flutter/material.dart';

import 'screens/payments/iap/iap_demo_screen.dart';

/// Promotion IAP products can be tested without signing in to the main app.
///
/// İşə salmaq (iOS simulyatorda, yerli StoreKit ilə):
///   fvm flutter run -t lib/dev_iap.dart
///
/// Qeyd: yerli StoreKit alış pəncərəsi Xcode launch tələb edə bilər —
/// Runner sxemində StoreKit Configuration = WawatProducts.storekit seçilib.
void main() {
  runApp(const _DevIapApp());
}

class _DevIapApp extends StatelessWidget {
  const _DevIapApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Wawat IAP dev',
      debugShowCheckedModeBanner: false,
      home: IapDemoScreen(),
    );
  }
}
