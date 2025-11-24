import 'package:flutter/material.dart';
import '../../../../data/network/response/language.dart';
import '../../../../data/network/response/language_response.dart';
import '../../../../data/network/response/user.dart';
import '../../../../presentation/resourses/wawat_colors.dart';
import '../../../../presentation/resourses/wawat_dimensions.dart';
import '../../../../presentation/resourses/wawat_text_styles.dart';

class LanguageMultiSelectDropdown extends StatefulWidget {
  final List<Language> languages;
  final List<int> selectedLanguageIds;
  final Function(List<int>) onSelectionChanged;
  final bool isModal;

  const LanguageMultiSelectDropdown({
    Key? key,
    required this.languages,
    required this.selectedLanguageIds,
    required this.onSelectionChanged,
    this.isModal = false,
  }) : super(key: key);

  @override
  State<LanguageMultiSelectDropdown> createState() =>
      _LanguageMultiSelectDropdownState();
}

class _LanguageMultiSelectDropdownState
    extends State<LanguageMultiSelectDropdown> {
  bool _isOpen = false;

  String _getSelectedLanguagesDisplay() {
    if (widget.selectedLanguageIds.isEmpty) {
      return 'Выбор';
    }
    final selectedNames = widget.languages
        .where((lang) => widget.selectedLanguageIds.contains(lang.id))
        .map((lang) => lang.name)
        .toList();
    if (selectedNames.length > 2) {
      return '${selectedNames.take(2).join(", ")}...';
    }
    return selectedNames.join(', ');
  }

  void _toggleLanguage(int languageId) {
    final newList = List<int>.from(widget.selectedLanguageIds);
    if (newList.contains(languageId)) {
      newList.remove(languageId);
    } else {
      newList.add(languageId);
    }
    widget.onSelectionChanged(newList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: EdgeInsets.only(bottom: WawatDimensions.spacingSm),
          child: Text(
            'ЯЗЫКИ ОБЩЕНИЯ',
            style: WawatTextStyles.label,
          ),
        ),

        // Dropdown field
        GestureDetector(
          onTap: () {
            setState(() {
              _isOpen = !_isOpen;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: WawatDimensions.spacingMd,
              vertical: WawatDimensions.spacingSm,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: _isOpen
                    ? WawatColors.primary
                    : WawatColors.inputBorder,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(WawatDimensions.inputBorderRadius),
              color: WawatColors.inputBackground,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.language,
                  size: WawatDimensions.iconMedium,
                  color: WawatColors.textSecondary,
                ),
                SizedBox(width: WawatDimensions.spacingSm),
                Expanded(
                  child: Text(
                    _getSelectedLanguagesDisplay(),
                    style: widget.selectedLanguageIds.isEmpty
                        ? WawatTextStyles.body.copyWith(
                      color: WawatColors.backgroundLight,
                    )
                        : WawatTextStyles.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isOpen ? Icons.expand_less : Icons.expand_more,
                  color: WawatColors.textSecondary,
                ),
              ],
            ),
          ),
        ),

        // Dropdown menu
        if (_isOpen)
          Padding(
            padding: EdgeInsets.only(top: WawatDimensions.spacingSm),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: WawatColors.inputBorder,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(WawatDimensions.inputBorderRadius),
                color: WawatColors.backgroundWhite,
              ),
              constraints: BoxConstraints(
                maxHeight: 250,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.languages.length,
                itemBuilder: (context, index) {
                  final language = widget.languages[index];
                  final isSelected =
                  widget.selectedLanguageIds.contains(language.id);

                  return GestureDetector(
                    onTap: () => _toggleLanguage(language.id),
                    child: Container(
                      color: isSelected
                          ? WawatColors.primary.withOpacity(0.05)
                          : Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.all(WawatDimensions.spacingMd),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? WawatColors.primary
                                      : WawatColors.inputBorder,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(3),
                                color: isSelected
                                    ? WawatColors.primary
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                                  : null,
                            ),
                            SizedBox(width: WawatDimensions.spacingMd),
                            Expanded(
                              child: Text(
                                language.name ?? "",
                                style: WawatTextStyles.body,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}