import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../presentation/resourses/wawat_dark.dart';
import '../../services/app_update_service.dart';
import '../../services/localization_service.dart';

class ForcedUpdateScreen extends StatefulWidget {
  const ForcedUpdateScreen({super.key, required this.info});

  final AppUpdateInfo info;

  @override
  State<ForcedUpdateScreen> createState() => _ForcedUpdateScreenState();
}

class _ForcedUpdateScreenState extends State<ForcedUpdateScreen> {
  static const _brand = Color(0xFF017BFE);
  bool _openingStore = false;

  Future<void> _openStore() async {
    if (_openingStore) return;
    final uri = Uri.tryParse(widget.info.storeUrl?.trim() ?? '');
    if (uri == null || !uri.hasScheme) {
      _showStoreError();
      return;
    }

    setState(() => _openingStore = true);
    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) _showStoreError();
    } catch (_) {
      _showStoreError();
    } finally {
      if (mounted) setState(() => _openingStore = false);
    }
  }

  void _showStoreError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t('update.store_error'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? WawatDark.bg : const Color(0xFFF3F7FC);
    final card = isDark ? WawatDark.surface : Colors.white;
    final ink = isDark ? WawatDark.textPrimary : const Color(0xFF0F172A);
    final secondary =
        isDark ? WawatDark.textSecondary : const Color(0xFF64748B);
    final title = widget.info.title?.trim();
    final message = widget.info.message?.trim();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 136,
                  height: 136,
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(38),
                    boxShadow: [
                      BoxShadow(
                        color: _brand.withValues(alpha: 0.15),
                        blurRadius: 44,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    color: _brand,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  title == null || title.isEmpty ? t('update.title') : title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ink,
                    fontSize: 27,
                    height: 1.12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 330),
                  child: Text(
                    message == null || message.isEmpty
                        ? t('update.description')
                        : message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondary,
                      fontSize: 15,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (widget.info.latestVersion != null) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _brand.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      t('update.version', {
                        'version': widget.info.latestVersion!,
                      }),
                      style: const TextStyle(
                        color: _brand,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _openingStore ? null : _openStore,
                    style: FilledButton.styleFrom(
                      backgroundColor: _brand,
                      disabledBackgroundColor: _brand.withValues(alpha: 0.55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: _openingStore
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.storefront_rounded),
                    label: Text(
                      t('update.button'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
