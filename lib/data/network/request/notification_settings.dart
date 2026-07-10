class NotificationSettings {
  final bool? notifyPush;
  final bool? notifyEmail;
  final bool? notifyNewMessages;
  final bool? notifyShipments;
  final bool? notifyListings;
  final bool? notifyReviews;
  final bool? notifyFollows;
  final bool? notifySavedSearch;
  final bool? notifyMarketing;
  final String? quietHoursStart;
  final String? quietHoursEnd;
  final bool clearQuietHours;

  const NotificationSettings({
    this.notifyPush,
    this.notifyEmail,
    this.notifyNewMessages,
    this.notifyShipments,
    this.notifyListings,
    this.notifyReviews,
    this.notifyFollows,
    this.notifySavedSearch,
    this.notifyMarketing,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.clearQuietHours = false,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      notifyPush: _boolValue(json['notify_push']),
      notifyEmail: _boolValue(json['notify_email']),
      notifyNewMessages: _boolValue(json['notify_new_messages']),
      notifyShipments: _boolValue(json['notify_shipments']),
      notifyListings: _boolValue(json['notify_listings']),
      notifyReviews:
          _boolValue(json['notify_reviews'] ?? json['notify_new_reviews']),
      notifyFollows: _boolValue(json['notify_follows']),
      notifySavedSearch: _boolValue(json['notify_saved_search']),
      notifyMarketing: _boolValue(json['notify_marketing']),
      quietHoursStart: json['quiet_hours_start']?.toString(),
      quietHoursEnd: json['quiet_hours_end']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (notifyPush != null) 'notify_push': notifyPush,
        if (notifyEmail != null) 'notify_email': notifyEmail,
        if (notifyNewMessages != null) 'notify_new_messages': notifyNewMessages,
        if (notifyShipments != null) 'notify_shipments': notifyShipments,
        if (notifyListings != null) 'notify_listings': notifyListings,
        if (notifyReviews != null) 'notify_reviews': notifyReviews,
        if (notifyFollows != null) 'notify_follows': notifyFollows,
        if (notifySavedSearch != null) 'notify_saved_search': notifySavedSearch,
        if (notifyMarketing != null) 'notify_marketing': notifyMarketing,
        if (clearQuietHours || quietHoursStart != null)
          'quiet_hours_start': quietHoursStart,
        if (clearQuietHours || quietHoursEnd != null)
          'quiet_hours_end': quietHoursEnd,
      };
}

bool? _boolValue(Object? value) {
  if (value is bool) return value;
  if (value == null) return null;
  return value.toString() == 'true' || value.toString() == '1';
}
