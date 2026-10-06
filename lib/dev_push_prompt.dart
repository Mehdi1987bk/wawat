import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'services/push_notification_service.dart';
import 'services/push_permission_prompt.dart';

/// Bildiriş icazəsi üçün hazırlanmış ekranı serverdən asılı olmadan yoxlamaq.
///
/// İşə salmaq:
///   fvm flutter run -t lib/dev_push_prompt.dart
///
/// Hər düymə `maybeAskPushPermission()` çağırır — yəni real statusu oxuyur və
/// lazım olanda öz izah listini göstərir. Sistem dialoqu da realdır: «icazə
/// ver» deyəndən sonra status dəyişir və aşağıdaki sətir onu göstərir.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const _DevPushPromptApp());
}

class _DevPushPromptApp extends StatelessWidget {
  const _DevPushPromptApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Wawat push dev',
      debugShowCheckedModeBanner: false,
      home: _DevPushPromptScreen(),
    );
  }
}

class _DevPushPromptScreen extends StatefulWidget {
  const _DevPushPromptScreen();

  @override
  State<_DevPushPromptScreen> createState() => _DevPushPromptScreenState();
}

class _DevPushPromptScreenState extends State<_DevPushPromptScreen> {
  String _status = '…';

  @override
  void initState() {
    super.initState();
    _readStatus();
  }

  Future<void> _readStatus() async {
    final status = await PushNotificationService().permissionStatus();
    if (!mounted) return;
    setState(() => _status = status.name);
  }

  Future<void> _ask(PushPromptTrigger trigger) async {
    await resetPushPromptHistory();
    if (!mounted) return;
    await maybeAskPushPermission(context, trigger);
    await _readStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Push icazəsi'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Sistem statusu: $_status'),
          const SizedBox(height: 16),
          _button('Elan yerləşdirildi', PushPromptTrigger.listingCreated),
          _button('Təklif göndərildi', PushPromptTrigger.proposalSent),
          _button('Mesaj göndərildi', PushPromptTrigger.messageSent),
          const SizedBox(height: 24),
          const Text('İcazə verilməyəndə ayarlar ekranında görünən xəbərdarlıq:'),
          const SizedBox(height: 8),
          const PushPermissionDeniedBanner(),
        ],
      ),
    );
  }

  Widget _button(String label, PushPromptTrigger trigger) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ElevatedButton(
          onPressed: () => _ask(trigger),
          child: Text(label),
        ),
      );
}
