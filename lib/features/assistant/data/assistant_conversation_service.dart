import 'package:supabase_flutter/supabase_flutter.dart';
import 'assistant_message.dart';

class AssistantConversationService {
  final SupabaseClient _client;

  AssistantConversationService(this._client);

  Future<void> saveMessage(AssistantMessage message) async {
    await _client.from('assistant_conversations').insert(message.toMap());
  }

  Future<List<AssistantMessage>> fetchMessages(
      {String? userId, int limit = 50}) async {
    final fromTable = _client.from('assistant_conversations');
    final safeUserId = userId ?? 'default_user';
    final response = await fromTable
        .select()
        .eq('user_id', safeUserId)
        .order('timestamp', ascending: true)
        .limit(limit);
    print('[AssistantConversationService] Supabase response:');
    print(response);
    List<dynamic> list;
    try {
      if (response is List) {
        list = response;
      } else {
        print(
            '[AssistantConversationService] Response is not a List, returning empty list');
        list = [];
      }
      return list
          .map(
              (map) => AssistantMessage.fromMap(Map<String, dynamic>.from(map)))
          .toList();
    } catch (e, stack) {
      print('[AssistantConversationService] Error mapping response: $e');
      print(stack);
      return [];
    }
  }

  Future<void> clearMessages({String? userId}) async {
    final query = _client.from('assistant_conversations');
    // Always require a WHERE clause for safety
    final safeUserId = userId ?? 'default_user';
    await query.delete().eq('user_id', safeUserId);
  }
}
