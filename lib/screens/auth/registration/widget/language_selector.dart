import 'package:flutter/material.dart';

import '../../../../data/network/response/language.dart';

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
    print('_getSelectedLanguagesDisplay called: selectedCodes=${widget.selectedLanguageCodes}, allLanguages=${widget.languages.length}');

    if (widget.selectedLanguageCodes.isEmpty) {
      print('  -> Нет выбранных языков, возвращаю "Выбор"');
      return 'Выбор';
    }

    final selectedNames = <String>[];
    for (var code in widget.selectedLanguageCodes) {
      final lang = widget.languages.firstWhere(
            (l) => l.code == code,
        orElse: () => Language(  code: '', name: 'Unknown'),
      );
      if (lang.code.isNotEmpty) {
        selectedNames.add(lang.name ?? '');
        print('  -> Добавлен язык: ${lang.name} (code: ${lang.code})');
      }
    }

    final result = selectedNames.join(', ');
    print('  -> Результат: $result');
    return result.isNotEmpty ? result : 'Выбор';
  }

  void _showLanguagesBottomSheet() {
    print('========== _showLanguagesBottomSheet ==========');
    print('languages.length: ${widget.languages.length}');
    print('isLoading: ${widget.isLoading}');
    print('selectedLanguageCodes: ${widget.selectedLanguageCodes}');

    // ✅ Если данные загружаются, показываем сообщение
    if (widget.languages.isEmpty && widget.isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Языки загружаются. Попробуйте позже.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // ✅ Если данные не загружены и не загружаются - показываем ошибку
    if (widget.languages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Языки не загружены. Попробуйте позже.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    _showLanguagesBottomSheetContent();
  }

  void _showLanguagesBottomSheetContent() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBottomSheet) => Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
            color: Colors.white
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Выберите языки',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: widget.languages.isEmpty
                      ? const Center(
                    child: Text('Языки не найдены'),
                  )
                      : ListView.builder(
                    itemCount: widget.languages.length,
                    itemBuilder: (context, index) {
                      final language = widget.languages[index];
                      final isSelected =
                      widget.selectedLanguageCodes.contains(language.code);

                      print('ListTile $index: ${language.name} (code=${language.code}, selected=$isSelected)');

                      return ListTile(
                        title: Text(
                          language.name ?? 'Неизвестный язык',
                          style: const TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          'Код: ${language.code}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                          Icons.check_circle,
                          color: Color(0xFF5B51FF),
                          size: 28,
                        )
                            : const Icon(
                          Icons.circle_outlined,
                          color: Colors.grey,
                          size: 28,
                        ),
                        onTap: () {
                          final newSelection = Set<String>.from(widget.selectedLanguageCodes);
                          if (isSelected) {
                            newSelection.remove(language.code);
                            print('Удален язык: ${language.name} (code: ${language.code})');
                          } else {
                            newSelection.add(language.code);
                            print('Добавлен язык: ${language.name} (code: ${language.code})');
                          }
                          widget.onSelectionChanged(newSelection);
                          // ✅ Обновляем и BottomSheet
                          setStateBottomSheet(() {});
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                      print('Bottom sheet закрыта, выбранные языки: ${widget.selectedLanguageCodes}');
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
                    child: const Text(
                      'Применить',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : _showLanguagesBottomSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFE5E5EA),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.isLoading ? 'Загрузка...' : _getSelectedLanguagesDisplay(),
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isLoading ? const Color(0xFFC7C7CC) : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.expand_more,
              color: Color(0xFF8E8E93),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}