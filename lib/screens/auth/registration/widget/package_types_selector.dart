import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/network/response/package_types_response.dart';
import '../../../../data/network/response/type_option.dart';
import '../../../../generated/l10n.dart';
import '../../../../services/theme_manager.dart';

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
      return S.of(context).gbfbgfbfg4;
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
    return result.isNotEmpty ? result : S.of(context).gbfbgfbfg4;
  }

  void _showPackageTypesBottomSheet(bool isDark) {
    if (widget.packageTypes.isEmpty && widget.isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          content: Text(S.of(context).t53grvfe5),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (widget.packageTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          content: Text(S.of(context).bgfbgfbgf4),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    _showPackageTypesBottomSheetContent(isDark);
  }

  void _showPackageTypesBottomSheetContent(bool isDark) {
    final localSelectedCodes =
    Set<String>.from(widget.selectedPackageTypeCodes);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                    Text(
                      S.of(context).bfgbgfb3,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
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
                child: widget.packageTypes.isEmpty
                    ? Center(
                  child: Text(
                    S.of(context).bgbffgb3,
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : Colors.black87,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: widget.packageTypes.length,
                  itemBuilder: (context, index) {
                    final packageType = widget.packageTypes[index];
                    final isSelected =
                    localSelectedCodes.contains(packageType.code);

                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF0EDFF))
                            : Colors.transparent,
                      ),
                      child: ListTile(
                        leading: Text(
                          packageType.icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(
                          packageType.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
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
                              localSelectedCodes.remove(packageType.code);
                            } else {
                              localSelectedCodes.add(packageType.code);
                            }
                          });
                        },
                      ),
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
                    S.of(context).bgfbggfbfg3,
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
            widget.selectedPackageTypeCodes.isEmpty && !widget.isLoading;

        return GestureDetector(
          onTap: widget.isLoading ? null : () => _showPackageTypesBottomSheet(isDark),
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
                    ? const Color(0xFF3A3A3A)
                    : const Color(0xFFE5E5EA),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (isPlaceholder) ...[
                        Image.asset(
                          "asset/search.png",
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
                                : _getSelectedPackageTypesDisplay(),
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
