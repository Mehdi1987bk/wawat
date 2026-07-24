import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../../services/wawat_content.dart';
import 'deal_status.dart';

const _steps = ['proposal_pending', 'accepted', 'picked_up', 'delivered', 'completed'];
const _stepIcons = [
  PhosphorIconsBold.paperPlaneTilt,
  PhosphorIconsBold.handshake,
  PhosphorIconsBold.package,
  PhosphorIconsBold.mapPin,
  PhosphorIconsBold.check,
];
const _stepKeys = [
  'deals.step.proposal',
  'deals.step.accepted',
  'deals.step.picked_up',
  'deals.step.delivered',
  'deals.step.done',
];
const _stepFallbacks = ['Təklif', 'Qəbul', 'Götürüldü', 'Çatdı', 'Bitdi'];

/// The 5-node happy-path stepper (Təklif → Qəbul → Götürüldü → Çatdı → Bitdi).
/// Only meaningful for the non-terminal-branch statuses; callers should hide
/// this widget for disputed/cancelled/declined/expired.
class DealStepper extends StatelessWidget {
  final String status;
  final Map<String, String> content;

  const DealStepper({super.key, required this.status, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = _steps.indexOf(status);
    final activeIndex = currentIndex < 0 ? 0 : currentIndex;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: WawatDark.border) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: dealInk900.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        // Align nodes and connectors to the top so the 2px line sits on the
        // circle's vertical center (13px), not below it because of the labels.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final segDone = (i ~/ 2) < activeIndex;
            return Expanded(
              // Circle is 26px tall → center at 13; a 2px line at top:12 spans
              // 12–14, centering it exactly on the node row.
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(top: 12),
                color: segDone ? dealBrand : (isDark ? WawatDark.border : dealInk200),
              ),
            );
          }
          final index = i ~/ 2;
          final isDone = index < activeIndex;
          final isNow = index == activeIndex;
          final isFinalDone = index == 4 && status == 'completed';
          Color bg;
          Color fg;
          if (isFinalDone) {
            bg = dealEmerald600;
            fg = Colors.white;
          } else if (isDone) {
            bg = dealBrand;
            fg = Colors.white;
          } else if (isNow) {
            bg = isDark ? WawatDark.surface : Colors.white;
            fg = dealBrand;
          } else {
            bg = isDark ? WawatDark.surfaceAlt : dealInk100;
            fg = isDark ? WawatDark.textMuted : dealInk400;
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  border: isNow
                      ? Border.all(color: dealBrand, width: 2)
                      : null,
                ),
                child: Icon(_stepIcons[index], size: 13, color: fg),
              ),
              const SizedBox(height: 5),
              Text(
                WawatContent.text(content, _stepKeys[index], _stepFallbacks[index]),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isNow
                      ? dealBrand
                      : (isDone || isFinalDone)
                          ? (isDark ? WawatDark.textSecondary : dealInk500)
                          : (isDark ? WawatDark.textMuted : dealInk400),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
