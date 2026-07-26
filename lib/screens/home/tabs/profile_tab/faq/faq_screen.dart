import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

import '../../../../../data/network/response/faq_response.dart';
import '../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../presentation/resourses/wawat_colors.dart';
import '../../../../../services/theme_manager.dart';
import '../support/support_screen.dart';
import 'faq_bloc.dart';

class FaqScreen extends BaseScreen {
  FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends BaseState<FaqScreen, FaqBloc> {
  // Для отслеживания раскрытых элементов
  final Set<int> _expandedItems = {};
  String _query = '';

  @override
  PreferredSizeWidget? appBar() {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final isDark = themeManager.isDarkMode;

    return AppBar(
      backgroundColor: isDark ? cBar(isDark) : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? cText(isDark) : Colors.black,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Kömək & FAQ',
        style: TextStyle(
          color: isDark ? cText(isDark) : Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: false,
    );
  }

  @override
  Widget body() {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        final isDark = themeManager.isDarkMode;

        return Container(
          color: isDark ? cScreen(isDark) : const Color(0xFFF5F5F7),
          child: CustomScrollView(
            slivers: [
              // Красивый header
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? cCard(isDark) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5B4FFF), Color(0xFFD946EF)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.help_outline_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kömək & FAQ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark ? cText(isDark) : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Suallarına cavab tap',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? cText2(isDark)
                                    : const Color(0xFF8E8E93),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Поиск (клиентская фильтрация)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    style: TextStyle(
                        color: isDark ? cText(isDark) : Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Sualını axtar…',
                      hintStyle: TextStyle(
                          color: isDark
                              ? const Color(0xFF6B7B93)
                              : const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500),
                      prefixIcon: Icon(Icons.search,
                          color: isDark
                              ? const Color(0xFF6B7B93)
                              : const Color(0xFF94A3B8),
                          size: 20),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1C2740)
                          : const Color(0x0D0F172A),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: isDark
                                ? const Color(0x14FFFFFF)
                                : const Color(0x120F172A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: WawatColors.primary, width: 1.4),
                      ),
                    ),
                  ),
                ),
              ),

              // FAQ список
              FutureBuilder<FaqResponse>(
                future: bloc.faqs,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? cBrandText(isDark) : WawatColors.primary,
                          ),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: isDark
                                  ? cFaint(isDark)
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'FAQ yüklənmədi',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? cText2(isDark)
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 64,
                              color: isDark
                                  ? cFaint(isDark)
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Hələ sual yoxdur',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? cText2(isDark)
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final q = _query.trim().toLowerCase();
                  final faqs = q.isEmpty
                      ? snapshot.data!.data
                      : snapshot.data!.data
                          .where((f) =>
                              f.question.toLowerCase().contains(q) ||
                              f.answer.toLowerCase().contains(q))
                          .toList();

                  if (faqs.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 12),
                        child: Column(
                          children: [
                            Icon(Icons.search_off,
                                size: 54,
                                color: isDark
                                    ? cFaint(isDark)
                                    : const Color(0xFFCBD5E1)),
                            const SizedBox(height: 12),
                            Text('«${_query.trim()}» üzrə nəticə yoxdur',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isDark ? cText(isDark) : Colors.black)),
                            const SizedBox(height: 4),
                            Text('Başqa açar sözlə yoxla və ya dəstəyə yaz.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: isDark
                                        ? cText2(isDark)
                                        : const Color(0xFF64748B))),
                            const SizedBox(height: 16),
                            _supportButton(isDark),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final faq = faqs[index];
                          final isExpanded = _expandedItems.contains(faq.id);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildFaqItem(
                              isDark: isDark,
                              question: faq.question,
                              answer: faq.answer,
                              isExpanded: isExpanded,
                              onTap: () {
                                setState(() {
                                  if (isExpanded) {
                                    _expandedItems.remove(faq.id);
                                  } else {
                                    _expandedItems.add(faq.id);
                                  }
                                });
                              },
                            ),
                          );
                        },
                        childCount: faqs.length,
                      ),
                    ),
                  );
                },
              ),

              // «Cavab tapmadın? → Dəstəyə yaz»
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0x24017BFE)
                          : const Color(0xFFEAF3FE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text('Cavab tapmadın?',
                            style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? cText(isDark) : Colors.black)),
                        const SizedBox(height: 2),
                        Text('Komandamız kömək etməyə hazırdır.',
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? cText2(isDark)
                                    : const Color(0xFF64748B))),
                        const SizedBox(height: 12),
                        _supportButton(isDark),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _supportButton(bool isDark) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => SupportScreen())),
      child: Container(
        width: double.infinity,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: WawatColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.headset_mic, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Dəstəyə yaz',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({
    required bool isDark,
    required String question,
    required String answer,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isDark ? cCard(isDark) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? (isDark ? cBrandText(isDark) : WawatColors.primary)
              : (isDark ? cBorder(isDark) : Colors.grey.shade200),
          width: isExpanded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
                isExpanded ? (isDark ? 0.3 : 0.1) : (isDark ? 0.25 : 0.05)),
            blurRadius: isExpanded ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Вопрос
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          question,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? cText(isDark) : Colors.black,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isExpanded
                                ? (isDark
                                    ? cBrandBadge(isDark)
                                    : WawatColors.primary)
                                : (isDark
                                    ? cFill(isDark)
                                    : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: isExpanded
                                ? (isDark ? cBrandText(isDark) : Colors.white)
                                : (isDark
                                    ? cMuted(isDark)
                                    : Colors.grey.shade600),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Ответ (анимированный)
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: isDark ? cLine(isDark) : Colors.grey.shade200,
                        ),
                        const SizedBox(height: 12),
                        HtmlWidget(
                          answer,
                          textStyle: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: isDark
                                ? cText2(isDark)
                                : const Color(0xFF4B5563),
                          ),
                          customStylesBuilder: (element) {
                            // Стили для разных HTML элементов
                            if (element.localName == 'a') {
                              return {
                                'color': isDark
                                    ? '#7FB6FF'
                                    : '#${WawatColors.primary.value.toRadixString(16).substring(2)}',
                                'text-decoration': 'underline',
                              };
                            }
                            if (element.localName == 'strong' ||
                                element.localName == 'b') {
                              return {
                                'color': isDark ? '#EAF0FA' : '#000000',
                                'font-weight': '600',
                              };
                            }
                            if (element.localName == 'h1') {
                              return {
                                'font-size': '20px',
                                'font-weight': 'bold',
                                'color': isDark ? '#EAF0FA' : '#000000',
                                'margin': '8px 0 12px 0',
                              };
                            }
                            if (element.localName == 'h2') {
                              return {
                                'font-size': '18px',
                                'font-weight': 'bold',
                                'color': isDark ? '#EAF0FA' : '#000000',
                                'margin': '8px 0 10px 0',
                              };
                            }
                            if (element.localName == 'h3') {
                              return {
                                'font-size': '16px',
                                'font-weight': '600',
                                'color': isDark ? '#EAF0FA' : '#000000',
                                'margin': '6px 0 8px 0',
                              };
                            }
                            if (element.localName == 'p') {
                              return {
                                'margin': '0 0 8px 0',
                              };
                            }
                            if (element.localName == 'ul' ||
                                element.localName == 'ol') {
                              return {
                                'margin': '0 0 8px 8px',
                              };
                            }
                            if (element.localName == 'li') {
                              return {
                                'margin': '0 0 4px 0',
                              };
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  FaqBloc provideBloc() {
    return FaqBloc();
  }
}
