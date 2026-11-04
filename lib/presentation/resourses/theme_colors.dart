import 'package:flutter/material.dart';

import 'wawat_dark.dart';

const Color _lScreen = Color(0xFFF4F6F9);
const Color _lFill = Color(0xFFF1F5F9);
const Color _lInk900 = Color(0xFF0F172A);
const Color _lInk600 = Color(0xFF475569);
const Color _lInk500 = Color(0xFF64748B);
const Color _lInk400 = Color(0xFF94A3B8);
const Color _lInk300 = Color(0xFFCBD5E1);
const Color _lBrand = Color(0xFF017BFE);
const Color _lBrand50 = Color(0xFFEAF3FE);

Color cScreen(bool d) => d ? WawatDark.bg : _lScreen;
Color cCard(bool d) =>
    d ? WawatDark.surface : Colors.white;
Color cBar(bool d) => d ? WawatDark.bar : Colors.white;
Color cFill(bool d) => d ? WawatDark.surfaceAlt : _lFill;

Color cText(bool d) => d ? WawatDark.textPrimary : _lInk900;
Color cText2(bool d) => d ? WawatDark.textSecondary : _lInk500;
Color cText3(bool d) =>
    d ? WawatDark.textSecondary : _lInk600;
Color cMuted(bool d) => d ? WawatDark.textMuted : _lInk400;
Color cFaint(bool d) =>
    d ? WawatDark.iconMuted : _lInk300;

Color cLine(bool d) => d
    ? WawatDark.divider
    : _lInk900.withValues(alpha: .06);
Color cBorder(bool d) =>
    d ? WawatDark.border : _lInk900.withValues(alpha: .08);

const Color cBrandFill = _lBrand;
Color cBrandText(bool d) =>
    d ? WawatDark.brandText : _lBrand;
Color cBrandSoft(bool d) =>
    d ? WawatDark.brandChip : _lBrand50;
Color cBrandBadge(bool d) =>
    d ? WawatDark.brandBadge : _lBrand50;

BoxBorder? cCardBorder(bool d) =>
    d ? Border.all(color: WawatDark.border) : null;

List<BoxShadow>? cCardShadow(bool d, List<BoxShadow>? light) =>
    d ? WawatDark.cardShadow : light;
