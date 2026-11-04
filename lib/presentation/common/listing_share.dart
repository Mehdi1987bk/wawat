import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

import 'share_origin.dart';

import '../../data/network/response/listing_response.dart';

String listingShareUrl(Listing listing) =>
    'https://wawatair.com/l/${listing.id}';

String listingShareText(Listing listing) {
  final route = [listing.cityFrom, listing.cityTo]
      .where((c) => c != null && c.trim().isNotEmpty)
      .join(' → ');
  final url = listingShareUrl(listing);
  return route.isEmpty ? url : '$route\n$url';
}

Future<void> shareListing(Listing listing, [BuildContext? context]) async {
  await Share.share(
    listingShareText(listing),
    sharePositionOrigin: context == null ? null : shareOriginOf(context),
  );
}
