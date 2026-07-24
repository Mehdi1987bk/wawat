import 'package:dio/dio.dart';

import '../../../../../main.dart';
import '../new_profile/profile_models.dart';

class BlockedUsersApi {
  BlockedUsersApi({Dio? dio}) : _dio = dio ?? sl.get<Dio>();

  final Dio _dio;

  Future<BlockedUsersPage> getBlockedUsers({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$baseUrl/blocks',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
    return BlockedUsersPage.fromJson(response.data ?? const {});
  }

  Future<String> unblock(String publicId) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      '$baseUrl/users/$publicId/block',
    );
    return response.data?['message']?.toString() ?? 'Blok götürüldü.';
  }
}

class BlockedUsersPage {
  final List<WawatProfileUser> users;
  final int currentPage;
  final int lastPage;
  final int total;

  const BlockedUsersPage({
    required this.users,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory BlockedUsersPage.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final users = rawData is List
        ? rawData
            .whereType<Map>()
            .map(
              (item) => WawatProfileUser.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .where((user) => user.id.isNotEmpty)
            .toList()
        : <WawatProfileUser>[];
    final meta = json['meta'] is Map
        ? Map<String, dynamic>.from(json['meta'] as Map)
        : const <String, dynamic>{};
    return BlockedUsersPage(
      users: users,
      currentPage: _int(meta['current_page'] ?? meta['page']) ?? 1,
      lastPage: _int(meta['last_page']) ?? 1,
      total: _int(meta['total']) ?? users.length,
    );
  }
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
