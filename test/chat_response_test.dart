import 'package:buking/data/network/response/chat_response.dart';
import 'package:buking/services/pusher_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Chat API models', () {
    test('keeps a public user id for user-scoped chat actions', () {
      final user = ChatUser.fromJson({
        'id': '01JCHATUSERPUBLICID',
        'fullname': 'Aysel Məmmədova',
      });

      expect(user.id, 0);
      expect(user.publicId, '01JCHATUSERPUBLICID');
      expect(user.apiId, '01JCHATUSERPUBLICID');
    });

    test('keeps a numeric user id when the API returns one', () {
      final user = ChatUser.fromJson({
        'id': 42,
        'fullname': 'Tahir Quliyev',
      });

      expect(user.id, 42);
      expect(user.publicId, isNull);
      expect(user.apiId, 42);
    });

    test('parses image and system-card messages from the live envelope', () {
      final imageMessage = ChatMessage.fromJson({
        'id': '01JIMAGE',
        'type': 'image',
        'is_mine': true,
        'image': {
          'url': 'https://api.wawatair.com/signed/image.jpg',
          'mime_type': 'image/jpeg',
          'size': 234012,
        },
        'created_at': '2026-07-16T18:30:00+00:00',
      });
      final cardMessage = ChatMessage.fromJson({
        'id': '01JCARD',
        'type': 'system_card',
        'is_mine': false,
        'card': {
          'type': 'proposal',
          'label': 'Təklif',
          'is_interactive': true,
          'shipment_id': '01JSHIPMENT',
          'payload': {
            'weight_kg': 2,
            'price_total': 16,
            'package_type_code': 'documents',
          },
        },
        'created_at': '2026-07-16T18:31:00+00:00',
      });

      expect(imageMessage.image?.mimeType, 'image/jpeg');
      expect(imageMessage.deliveryStatus, ChatMessageDeliveryStatus.sent);
      expect(cardMessage.card?.type, 'proposal');
      expect(cardMessage.card?.shipmentId, '01JSHIPMENT');
      expect(cardMessage.card?.payload['price_total'], 16);
    });

    test('parses conversation pagination and blocking state', () {
      final response = ConversationsResponse.fromJson({
        'data': [
          {
            'id': '01JCONVERSATION',
            'other_user': {
              'id': 42,
              'fullname': 'Tahir Quliyev',
              'is_verified': true,
            },
            'unread_count': 2,
            'is_pinned': true,
            'is_archived': false,
            'is_blocked': false,
            'is_blocked_by_other': true,
          },
        ],
        'meta': {
          'current_page': 1,
          'per_page': 20,
          'total': 1,
          'last_page': 1,
        },
      });

      expect(response.data, hasLength(1));
      expect(response.data.single.unreadCount, 2);
      expect(response.data.single.isPinned, isTrue);
      expect(response.data.single.isBlockedByOther, isTrue);
      expect(response.meta.lastPage, 1);
    });
  });

  test('Reverb socket uses the secure WebSocket scheme', () {
    final uri = PusherService().socketUri;

    expect(uri.scheme, 'wss');
    expect(uri.host, 'api.wawatair.com');
    expect(uri.port, 443);
    expect(uri.path, '/app/cbfef40b803a09357669');
  });
}
