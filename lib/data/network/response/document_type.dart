class DocumentType {
  final String code;
  final String name;

  const DocumentType({required this.code, required this.name});

  factory DocumentType.fromJson(Map<String, dynamic> json) => DocumentType(
        code: json['code']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? json['label']?.toString() ?? '',
      );

  bool get isSelfie => code == 'selfie';

  bool get isDriverLicense => code == 'driver_license';

  bool get isPassport => code == 'passport';
}
