import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/screens/home/tabs/profile_tab/privacy_policy/privacy_policy_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:buking/presentation/resourses/theme_colors.dart';
import 'package:buking/presentation/resourses/wawat_colors.dart';
import 'package:buking/presentation/resourses/wawat_dark.dart';
import 'package:buking/services/localization_service.dart';
import 'package:buking/services/theme_manager.dart';

import '../../../../../data/network/response/privacy_policy_response.dart';

class PrivacyPolicyScreen extends BaseScreen {
  PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState
    extends BaseState<PrivacyPolicyScreen, PrivacyPolicyBloc> {
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
                tr('privacy.screen_title', 'Privacy Policy'),
                style: TextStyle(
                  color: isDark ? cText(isDark) : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              centerTitle: true,
            ),
            body: FutureBuilder<PrivacyPolicyResponse>(
              future: bloc.privacyPolicy,
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? cBrandText(isDark) : WawatColors.primary,
                      ),
                    ),
                  );
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? WawatDark.dangerSoftBg
                                  : WawatColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              color: isDark
                                  ? WawatDark.dangerText
                                  : WawatColors.error,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            tr('privacy.load_error',
                                'Error loading privacy policy'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: isDark ? cText(isDark) : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? cText2(isDark) : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () {
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: WawatColors.buttonGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tr('privacy.retry', 'Retry'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Data loaded
                if (snapshot.hasData) {
                  final htmlContent = snapshot.data!.html;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? cCard(isDark) : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? cBorder(isDark)
                              : const Color(0xFFE8E8E8),
                        ),
                      ),
                      child: HtmlWidget(
                        htmlContent,
                        textStyle: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: isDark ? cText(isDark) : Colors.black87,
                        ),
                        customStylesBuilder: (element) {
                          // Стилизация заголовков
                          if (element.localName == 'h1') {
                            return {
                              'color': isDark ? '#EAF0FA' : '#1A1A1A',
                              'font-size': '24px',
                              'font-weight': 'bold',
                              'margin-bottom': '16px',
                              'margin-top': '20px',
                            };
                          }
                          if (element.localName == 'h2') {
                            return {
                              'color': isDark ? '#EAF0FA' : '#1A1A1A',
                              'font-size': '20px',
                              'font-weight': '600',
                              'margin-bottom': '12px',
                              'margin-top': '16px',
                            };
                          }
                          if (element.localName == 'h3') {
                            return {
                              'color': isDark ? '#EAF0FA' : '#1A1A1A',
                              'font-size': '18px',
                              'font-weight': '600',
                              'margin-bottom': '10px',
                              'margin-top': '12px',
                            };
                          }

                          // Стилизация параграфов
                          if (element.localName == 'p') {
                            return {
                              'color': isDark ? '#9FB0C7' : '#333333',
                              'margin-bottom': '12px',
                              'line-height': '1.6',
                            };
                          }

                          // Стилизация списков
                          if (element.localName == 'ul' ||
                              element.localName == 'ol') {
                            return {
                              'color': isDark ? '#9FB0C7' : '#333333',
                              'margin-bottom': '12px',
                              'padding-left': '20px',
                            };
                          }

                          if (element.localName == 'li') {
                            return {
                              'color': isDark ? '#9FB0C7' : '#333333',
                              'margin-bottom': '6px',
                            };
                          }

                          // Стилизация ссылок
                          if (element.localName == 'a') {
                            return {
                              'color': '#5B4FFF',
                              'text-decoration': 'underline',
                            };
                          }

                          // Стилизация жирного текста
                          if (element.localName == 'strong' ||
                              element.localName == 'b') {
                            return {
                              'color': isDark ? '#EAF0FA' : '#1A1A1A',
                              'font-weight': 'bold',
                            };
                          }

                          return null;
                        },
                      ),
                    ),
                  );
                }

                // No data
                return Center(
                  child: Text(
                    tr('privacy.no_content', 'No content available'),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? cText2(isDark) : Colors.black54,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  PrivacyPolicyBloc provideBloc() {
    return PrivacyPolicyBloc();
  }
}
