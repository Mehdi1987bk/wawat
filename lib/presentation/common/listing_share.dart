import 'package:share_plus/share_plus.dart';

import '../../data/network/response/listing_response.dart';

/// Web deep link to a listing.
String listingShareUrl(Listing listing) =>
    'https://wawatair.com/l/${listing.id}';

/// Human-friendly share text: "London → Baku\n<url>" (just the url when the
/// route is unknown).
String listingShareText(Listing listing) {
  final route = [listing.cityFrom, listing.cityTo]
      .where((c) => c != null && c.trim().isNotEmpty)
      .join(' → ');
  final url = listingShareUrl(listing);
  return route.isEmpty ? url : '$route\n$url';
}

/// Open the OS share sheet (WhatsApp, Telegram, Messages, copy, …) for a
/// listing. Used by every listing "share" affordance so they behave the same.
Future<void> shareListing(Listing listing) async {
  await Share.share(listingShareText(listing));
}
