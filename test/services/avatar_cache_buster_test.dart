import 'package:buking/services/avatar_cache_buster.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps an untouched avatar URL unchanged', () {
    const url = 'https://cdn.example.com/avatar.jpg?size=96';

    expect(AvatarCacheBuster.resolve(url), url);
  });

  test('adds a revision while preserving existing query parameters', () async {
    const url = 'https://cdn.example.com/avatar.jpg?size=96';

    await AvatarCacheBuster.invalidate([url], evictCachedFiles: false);
    final resolved = Uri.parse(AvatarCacheBuster.resolve(url));

    expect(resolved.queryParameters['size'], '96');
    expect(resolved.queryParameters['wawat_avatar_v'], isNotEmpty);
    expect(resolved.toString(), isNot(url));
  });
}
