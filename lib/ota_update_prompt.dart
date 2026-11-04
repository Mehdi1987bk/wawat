import 'dart:async';
import 'dart:io' show Platform, exit;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import 'presentation/resourses/wawat_dark.dart';
import 'services/localization_service.dart';

enum _OtaStage { hidden, offer, downloading, restarting, nextLaunch, failed }

class OtaUpdatePrompt extends StatefulWidget {
  const OtaUpdatePrompt({super.key});

  @override
  State<OtaUpdatePrompt> createState() => _OtaUpdatePromptState();
}

class _OtaUpdatePromptState extends State<OtaUpdatePrompt>
    with WidgetsBindingObserver {
  static const _brand = Color(0xFF017BFE);
  static const _restartChannel = MethodChannel('az.buking.buking/app_restart');
  static const _showAfter = Duration(seconds: 6);

  static bool _closed = false;
  static bool _exitOnBackground = false;

  final ShorebirdUpdater _updater = ShorebirdUpdater();
  final Future<void> _notBefore = Future<void>.delayed(_showAfter);
  _OtaStage _stage = _OtaStage.hidden;
  bool _downloaded = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_lookForUpdate());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_exitOnBackground && state == AppLifecycleState.paused) exit(0);
    if (state == AppLifecycleState.resumed && _stage == _OtaStage.hidden) {
      unawaited(_lookForUpdate());
    }
  }

  Future<void> _lookForUpdate() async {
    if (_closed || _checking || !_updater.isAvailable) return;
    _checking = true;
    try {
      var status = UpdateStatus.upToDate;
      for (var attempt = 0; attempt < 4; attempt++) {
        if (attempt > 0) {
          await Future<void>.delayed(const Duration(seconds: 5));
          if (!mounted) return;
        }
        try {
          status = await _updater.checkForUpdate();
        } catch (_) {
          continue;
        }
        if (status == UpdateStatus.outdated ||
            status == UpdateStatus.restartRequired) {
          break;
        }
      }
      if (status != UpdateStatus.outdated &&
          status != UpdateStatus.restartRequired) {
        return;
      }
      if (status == UpdateStatus.restartRequired &&
          await _alreadyRunningNextPatch()) {
        return;
      }
      if (!await _canRestart()) {
        if (status == UpdateStatus.outdated) await _updater.update();
        if (await _hasPendingPatch()) _exitOnBackground = true;
        return;
      }
      await _notBefore;
      if (!mounted || _closed || _stage != _OtaStage.hidden) return;
      setState(() {
        _downloaded = status == UpdateStatus.restartRequired;
        _stage = _OtaStage.offer;
      });
    } catch (_) {
      return;
    } finally {
      _checking = false;
    }
  }

  Future<bool> _canRestart() async {
    if (!Platform.isIOS) return true;
    if (await _updater.readCurrentPatch() != null) return false;
    try {
      return await _restartChannel.invokeMethod<bool>('canRestart') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _alreadyRunningNextPatch() async {
    if (!Platform.isIOS) return false;
    try {
      final restartedInto =
          await _restartChannel.invokeMethod<int>('restartedIntoPatch');
      if (restartedInto == null) return false;
      return (await _updater.readNextPatch())?.number == restartedInto;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _hasPendingPatch() async {
    final (current, next) =
        await (_updater.readCurrentPatch(), _updater.readNextPatch()).wait;
    return next != null && next.number != current?.number;
  }

  Future<void> _update() async {
    if (_stage != _OtaStage.offer && _stage != _OtaStage.failed) return;
    setState(() => _stage = _OtaStage.downloading);
    if (!_downloaded) {
      try {
        await _updater.update();
        _downloaded = await _hasPendingPatch();
      } catch (_) {
        if (mounted) setState(() => _stage = _OtaStage.failed);
        return;
      }
      if (!mounted) return;
      if (!_downloaded) {
        setState(() => _stage = _OtaStage.failed);
        return;
      }
    }
    setState(() => _stage = _OtaStage.restarting);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    var restarting = false;
    try {
      final next = await _updater.readNextPatch();
      restarting = await _restartChannel
              .invokeMethod<bool>('restart', next?.number)
              .timeout(const Duration(seconds: 5), onTimeout: () => false) ??
          false;
    } catch (_) {
      restarting = false;
    }
    if (!restarting && mounted) _waitForNextLaunch();
  }

  void _waitForNextLaunch() {
    _exitOnBackground = true;
    setState(() => _stage = _OtaStage.nextLaunch);
  }

  void _close() {
    _closed = true;
    setState(() => _stage = _OtaStage.hidden);
  }

  @override
  Widget build(BuildContext context) {
    if (_stage == _OtaStage.hidden) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? WawatDark.bg : const Color(0xFFF3F7FC);
    final card = isDark ? WawatDark.surface : Colors.white;
    final ink = isDark ? WawatDark.textPrimary : const Color(0xFF0F172A);
    final secondary =
        isDark ? WawatDark.textSecondary : const Color(0xFF64748B);

    final busy =
        _stage == _OtaStage.downloading || _stage == _OtaStage.restarting;
    final (title, message, button) = switch (_stage) {
      _OtaStage.downloading => (
          t('update.ota_title'),
          t('update.ota_downloading_body'),
          t('update.ota_downloading_button'),
        ),
      _OtaStage.restarting => (
          t('update.ota_done_title'),
          t('update.ota_restarting_body'),
          t('update.ota_restarting_button'),
        ),
      _OtaStage.nextLaunch => (
          t('update.ota_done_title'),
          t('update.ota_next_launch_body'),
          t('common.continue'),
        ),
      _OtaStage.failed => (
          t('update.ota_failed_title'),
          t('update.ota_failed_body'),
          t('common.retry'),
        ),
      _ => (
          t('update.ota_title'),
          t('update.ota_body'),
          t('update.button'),
        ),
    };

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: Material(
        color: background,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 12),
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
                  title,
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
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondary,
                      fontSize: 15,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: busy
                        ? null
                        : (_stage == _OtaStage.nextLaunch ? _close : _update),
                    style: FilledButton.styleFrom(
                      backgroundColor: _brand,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _brand.withValues(alpha: 0.55),
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Icon(_stage == _OtaStage.nextLaunch
                            ? Icons.check_rounded
                            : Icons.download_rounded),
                    label: Text(
                      button,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: _stage == _OtaStage.failed
                      ? TextButton(
                          onPressed: _close,
                          child: Text(
                            t('common.close'),
                            style: TextStyle(
                              color: secondary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
