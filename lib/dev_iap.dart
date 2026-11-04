import 'package:flutter/material.dart';

import 'screens/payments/iap/iap_demo_screen.dart';

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
