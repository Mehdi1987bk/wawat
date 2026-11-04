import 'package:cached_network_image/cached_network_image.dart';

class AvatarCacheBuster {
  AvatarCacheBuster._();

  static const _revisionParameter = 'wawat_avatar_v';
  static final Map<String, String> _revisions = {};

  static String resolve(String url) {
    final revision = _revisions[url];
    if (revision == null) return url;

    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        _revisionParameter: revision,
      },
    ).toString();
  }

  static Future<void> invalidate(
    Iterable<String?> urls, {
    bool evictCachedFiles = true,
  }) async {
    final uniqueUrls = urls
        .whereType<String>()
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toSet();
    if (uniqueUrls.isEmpty) return;

    if (evictCachedFiles) {
      for (final url in uniqueUrls) {
        final previousResolvedUrl = resolve(url);
        await _evict(url);
        if (previousResolvedUrl != url) {
          await _evict(previousResolvedUrl);
        }
      }
    }

    final revision = DateTime.now().microsecondsSinceEpoch.toString();
    for (final url in uniqueUrls) {
      _revisions[url] = revision;
    }
  }

  static Future<void> _evict(String url) async {
    try {
      await CachedNetworkImage.evictFromCache(url);
    } catch (_) {}
    try {
      await CachedNetworkImageProvider(url).evict();
    } catch (_) {}
  }
}
