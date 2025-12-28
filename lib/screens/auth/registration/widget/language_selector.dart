import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/network/response/language.dart';
import '../../../../generated/l10n.dart';
import '../../../../services/theme_manager.dart';

class LanguageSelector extends StatefulWidget {
  final List<Language> languages;
  final Set<String> selectedLanguageCodes;
  final Function(Set<String>) onSelectionChanged;
  final bool isLoading;
  final double maxHeight;

  const LanguageSelector({
    Key? key,
    required this.languages,
    required this.selectedLanguageCodes,
    required this.onSelectionChanged,
    this.isLoading = false,
    this.maxHeight = 250,
  }) : super(key: key);

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String _getSelectedLanguagesDisplay() {
    print(
        '_getSelectedLanguagesDisplay called: selectedCodes=${widget.selectedLanguageCodes}, allLanguages=${widget.languages.length}');

    if (widget.selectedLanguageCodes.isEmpty) {
       return S.of(context).nhgngn5;
    }

    final selectedNames = <String>[];
    for (var code in widget.selectedLanguageCodes) {
      final lang = widget.languages.firstWhere(
            (l) => l.code == code,
        orElse: () => Language(code: '', name: 'Unknown'),
      );
      if (lang.code.isNotEmpty) {
        selectedNames.add(lang.name ?? '');
       }
    }

    final result = selectedNames.join(', ');
     return result.isNotEmpty ? result : S.of(context).nhgngn5;
  }

  void _showLanguagesBottomSheet() {
    print('========== _showLanguagesBottomSheet ==========');
    print('languages.length: ${widget.languages.length}');
    print('isLoading: ${widget.isLoading}');
    print('selectedLanguageCodes: ${widget.selectedLanguageCodes}');

    if (widget.languages.isEmpty && widget.isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          content: Text(S.of(context).vfd34),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (widget.languages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          content: Text(S.of(context).bgdfbgfd3),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    _showLanguagesBottomSheetContent();
  }

  void _showLanguagesBottomSheetContent() {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final isDark = themeManager.isDarkMode;
    final localSelectedCodes = Set<String>.from(widget.selectedLanguageCodes);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBottomSheet) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      child:   Text(S.of(context).bgvfd3),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: widget.languages.isEmpty
                    ? Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : Colors.grey,
                    ),
                    child:   Text(S.of(context).bdg3),
                  ),
                )
                    : ListView.builder(
                  itemCount: widget.languages.length,
                  itemBuilder: (context, index) {
                    final language = widget.languages[index];
                    final isSelected =
                    localSelectedCodes.contains(language.code);

                    print(
                        'ListTile $index: ${language.name} (code=${language.code}, selected=$isSelected)');

                    return ListTile(
                      title: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        child: Text(language.name ?? S.of(context).nhtg5),
                      ),
                      subtitle: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF6B7280)
                              : Colors.grey,
                        ),
                        child: Text(S.of(context).bmy5+' ${language.code}'),
                      ),
                      trailing: isSelected
                          ? const Icon(
                        Icons.check_circle,
                        color: Color(0xFF5B51FF),
                        size: 28,
                      )
                          : Icon(
                        Icons.circle_outlined,
                        color: isDark
                            ? const Color(0xFF6B7280)
                            : Colors.grey,
                        size: 28,
                      ),
                      onTap: () {
                        setStateBottomSheet(() {
                          if (isSelected) {
                            localSelectedCodes.remove(language.code);
                         
                          } else {
                            localSelectedCodes.add(language.code);
                            
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSelectionChanged(localSelectedCodes); 
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B51FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                    elevation: 0,
                  ),
                  child:   Text(
                    S.of(context).bnht,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        final isPlaceholder =
            widget.selectedLanguageCodes.isEmpty && !widget.isLoading;

        return GestureDetector(
          onTap: widget.isLoading ? null : _showLanguagesBottomSheet,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 60,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              border: Border.all(
                color: isDark
                    ? const Color(0xFF4A4A4A)
                    : const Color(0xFFE5E5EA),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (isPlaceholder) ...[
                        Image.asset(
                          "asset/globus.png",
                          color: const Color(0xFF5B51FF),
                          width: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.isLoading
                                ? (isDark
                                ? const Color(0xFF6B7280)
                                : const Color(0xFFC7C7CC))
                                : isPlaceholder
                                ? (isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF8E8E93))
                                : (isDark ? Colors.white : Colors.black),
                            fontWeight: FontWeight.w500,
                          ),
                          child: Text(
                            widget.isLoading
                                ? S.of(context).bgfbgfb4
                                : _getSelectedLanguagesDisplay(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.expand_more,
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF8E8E93),
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
