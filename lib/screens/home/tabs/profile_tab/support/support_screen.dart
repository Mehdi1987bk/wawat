import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/screens/home/tabs/profile_tab/profile_tab_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:buking/presentation/resourses/theme_colors.dart';
import 'package:buking/presentation/resourses/wawat_colors.dart';
import 'package:buking/presentation/resourses/wawat_dark.dart';
import 'package:buking/services/theme_manager.dart';

import '../../../../../data/network/request/support_request.dart';
import '../../../../../generated/l10n.dart';

class SupportScreen extends BaseScreen {
  SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends BaseState<SupportScreen, ProfileTabBloc> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      bloc.support(SupportRequest(message: _descriptionController.text.trim()));
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);

      if (mounted) {
        _showSuccessDialog();
        _descriptionController.clear();
      }
    }
  }

  void _showSuccessDialog() {
    final isDark = Provider.of<ThemeManager>(context, listen: false).isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? cCard(isDark) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                gradient: WawatColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              S.of(context).bvetgh423rfc,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: isDark ? cText(isDark) : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).bnmkuy43545g3,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? cText2(isDark) : Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).ok,
                style: TextStyle(
                    color: isDark ? cBrandText(isDark) : WawatColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget body() {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        final isDark = themeManager.isDarkMode;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: isDark ? cScreen(isDark) : Colors.white,
            appBar: AppBar(
              backgroundColor: isDark ? cBar(isDark) : Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark ? cText(isDark) : Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                S.of(context).get3434gvrevef,
                style: TextStyle(
                  color: isDark ? cText(isDark) : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Иконка и заголовок
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: WawatColors.primaryGradient,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: WawatColors.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.headset_mic_rounded,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              S.of(context).bgrf4tb4dgfb,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: isDark ? cText(isDark) : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              S.of(context).rtbrtb4t4t4tb4n,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? cText2(isDark) : Colors.black54,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Метка поля
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            color: isDark
                                ? cBrandText(isDark)
                                : WawatColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            S.of(context).nrtn33ss,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark ? cText(isDark) : Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Текстовое поле
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color:
                              isDark ? cFill(isDark) : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isFocused
                                ? (isDark
                                    ? WawatDark.focusRing
                                    : WawatColors.primary)
                                : (isDark
                                    ? cBorder(isDark)
                                    : const Color(0xFFE8E8E8)),
                            width: _isFocused ? 2 : 1,
                          ),
                          boxShadow: _isFocused
                              ? [
                                  BoxShadow(
                                    color: isDark
                                        ? WawatDark.focusGlow
                                        : WawatColors.primary.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: TextFormField(
                          controller: _descriptionController,
                          focusNode: _focusNode,
                          maxLines: 6,
                          keyboardAppearance:
                              isDark ? Brightness.dark : Brightness.light,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? cText(isDark) : Colors.black,
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText: S.of(context).bbddgbtgbbvb,
                            hintStyle: TextStyle(
                              color: isDark
                                  ? WawatDark.placeholder
                                  : const Color(0xFF9CA3AF),
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return S.of(context).nntteev5eg;
                            }
                            if (value.trim().length < 10) {
                              return S.of(context).bbddert42t54gdg;
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Подсказка
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: isDark ? cFaint(isDark) : Colors.black38,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            S.of(context).gbrg533gds24rtegv,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? cMuted(isDark) : Colors.black38,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Кнопка отправки
                      GestureDetector(
                        onTap: _isLoading ? null : _submitRequest,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient:
                                _isLoading ? null : WawatColors.buttonGradient,
                            color: _isLoading ? Colors.grey : null,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: WawatColors.primary
                                    .withOpacity(_isLoading ? 0 : 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        S.of(context).bed2245fvfsgd,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Дополнительная информация
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? cCard(isDark)
                              : WawatColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? cBorder(isDark)
                                : WawatColors.primary.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? cBrandSoft(isDark)
                                    : WawatColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.access_time_rounded,
                                color: isDark
                                    ? cBrandText(isDark)
                                    : WawatColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    S.of(context).dfg34fgdwrrew,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isDark ? cText(isDark) : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    S.of(context).gfdlek54jn3,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? cText2(isDark)
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  ProfileTabBloc provideBloc() {
    return ProfileTabBloc();
  }
}
