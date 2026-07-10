class SavedSearchRequest {
  final String? name;
  final bool notify;
  final Map<String, dynamic> filters;

  SavedSearchRequest({
    this.name,
    required this.notify,
    required this.filters,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null && name!.trim().isNotEmpty) 'name': name!.trim(),
      'notify': notify,
      'filters': filters,
    };
  }
}
