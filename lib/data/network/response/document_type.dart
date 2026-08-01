/// A KYC document type from `GET /document-types` — code + localized name.
/// Valid codes: id_card, passport, driver_license, selfie. Never hardcode the
/// list; render the picker from this (names arrive localized per user language).
class DocumentType {
  final String code;
  final String name;

  const DocumentType({required this.code, required this.name});

  factory DocumentType.fromJson(Map<String, dynamic> json) => DocumentType(
        code: json['code']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? json['label']?.toString() ?? '',
      );

  /// The self-photo type is a dedicated slot, not an ID-document choice.
  bool get isSelfie => code == 'selfie';
}
