import 'package:flutter/material.dart';

import '../../../../data/network/response/package_types_response.dart';
import '../../../../data/network/response/type_option.dart';

class PackageTypesSelector extends StatefulWidget {
  final List<PackageType> packageTypes;
  final Set<String> selectedPackageTypeCodes;
  final Function(Set<String>) onSelectionChanged;
  final bool isLoading;
  final double maxHeight;

  const PackageTypesSelector({
    Key? key,
    required this.packageTypes,
    required this.selectedPackageTypeCodes,
    required this.onSelectionChanged,
    this.isLoading = false,
    this.maxHeight = 250,
  }) : super(key: key);

  @override
  State<PackageTypesSelector> createState() => _PackageTypesSelectorState();
}

class _PackageTypesSelectorState extends State<PackageTypesSelector> {
  String _getSelectedPackageTypesDisplay() {
    if (widget.selectedPackageTypeCodes.isEmpty) {
      return 'Выбор';
    }

    final selectedNames = <String>[];
    for (var code in widget.selectedPackageTypeCodes) {
      final pkg = widget.packageTypes.firstWhere(
        (p) => p.code == code,
        orElse: () => PackageType(
          code: '',
          name: '',
          icon: '',
        ),
      );
      if (pkg.code.isNotEmpty) {
        selectedNames.add(pkg.name);
      }
    }

    final result = selectedNames.join(', ');
    return result.isNotEmpty ? result : 'Выбор';
  }

  void _showPackageTypesBottomSheet() {
    if (widget.packageTypes.isEmpty && widget.isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Типы упаковки загружаются. Попробуйте позже.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (widget.packageTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Типы упаковки не загружены. Попробуйте позже.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    _showPackageTypesBottomSheetContent();
  }

  void _showPackageTypesBottomSheetContent() {
    final localSelectedCodes =
        Set<String>.from(widget.selectedPackageTypeCodes);

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
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            color: Colors.white,
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
                    const Text(
                      'Выберите специализацию',
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
                child: widget.packageTypes.isEmpty
                    ? const Center(
                        child: Text('Типы упаковки не найдены'),
                      )
                    : ListView.builder(
                        itemCount: widget.packageTypes.length,
                        itemBuilder: (context, index) {
                          final packageType = widget.packageTypes[index];
                          final isSelected =
                              localSelectedCodes.contains(packageType.code);

                          return ListTile(
                            leading: Text(
                              packageType.icon,
                              style: const TextStyle(fontSize: 28),
                            ),
                            title: Text(
                              packageType.name,
                              style: const TextStyle(fontSize: 16),
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
                              setStateBottomSheet(() {
                                if (isSelected) {
                                  localSelectedCodes.remove(packageType.code);
                                } else {
                                  localSelectedCodes.add(packageType.code);
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = widget.selectedPackageTypeCodes.isEmpty && !widget.isLoading;

    return GestureDetector(
      onTap: widget.isLoading ? null : _showPackageTypesBottomSheet,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFE5E5EA),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  // Показываем иконку только когда отображается "Выбор"
                  if (isPlaceholder) ...[
                    Image.asset(
                      "asset/search.png",
                      color: const Color(0xFF5B51FF),
                      width: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      widget.isLoading
                          ? 'Загрузка...'
                          : _getSelectedPackageTypesDisplay(),
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.isLoading
                            ? const Color(0xFFC7C7CC)
                            : isPlaceholder
                            ? const Color(0xFF8E8E93) // Цвет для placeholder
                            : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
