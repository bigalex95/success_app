import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/database/supabase_service.dart';
import '../../data/slm_service.dart';
import '../widgets/message_bubble.dart';
import '../../data/assistant_habit_parser.dart';
import '../../../habits/presentation/pages/habits_list_page.dart'
    show habitRepositoryProvider;
import '../../../../core/database/models/habit_model.dart';
import '../../data/assistant_conversation_service.dart';
import '../../data/assistant_message.dart';
import '../../../progress/presentation/pages/progress_dashboard.dart'
    show completionStatsProvider;
import '../../../habits/presentation/pages/habits_list_page.dart'
    show habitsProvider;

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier();
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier() : super([]);

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void setMessages(List<ChatMessage> messages) {
    state = messages;
  }

  void clearMessages() {
    state = [];
  }
}

final slmServiceProvider = Provider<SLMService>((ref) {
  return SLMService.createService(AppConfig.defaultSLMProvider);
});

class AssistantChatPage extends ConsumerStatefulWidget {
  const AssistantChatPage({super.key});

  @override
  ConsumerState<AssistantChatPage> createState() => _AssistantChatPageState();
}

class _AssistantChatPageState extends ConsumerState<AssistantChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<List<ChatMessage>> _fetchRecentChatHistory({int limit = 10}) async {
    final supabaseClient = Supabase.instance.client;
    final conversationService = AssistantConversationService(supabaseClient);
    const defaultUserId = 'default_user';
    final messages = await conversationService.fetchMessages(
        userId: defaultUserId, limit: limit);
    return messages
        .map((msg) => ChatMessage(
              text: msg.message,
              isUser: msg.role == 'user',
              timestamp: msg.timestamp,
            ))
        .toList();
  }

  String buildChatContext(List<ChatMessage> messages) {
    // Format as: User: ...\nAssistant: ...\n...
    return messages
        .map((msg) =>
            msg.isUser ? 'User: ${msg.text}' : 'Assistant: ${msg.text}')
        .join('\n');
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    ref.read(chatMessagesProvider.notifier).addMessage(userMessage);
    _messageController.clear();
    setState(() => _isLoading = true);

    // Save user message to Supabase
    final supabaseClient = Supabase.instance.client;
    final conversationService = AssistantConversationService(supabaseClient);
    const defaultUserId = 'default_user';
    await conversationService.saveMessage(
      AssistantMessage(
        userId: defaultUserId,
        role: 'user',
        message: text,
        timestamp: DateTime.now(),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      final slmService = ref.read(slmServiceProvider);

      // Build complete context with habits and stats
      final contextBuilder = SLMContextBuilder();
      final fullContext = await contextBuilder.buildContext();

      // Fetch recent chat history for context
      final recentMessages = await _fetchRecentChatHistory(limit: 10);
      final chatHistory = buildChatContext(recentMessages);

      // Merge contexts
      fullContext['history'] = chatHistory;

      final response = await slmService.generateResponse(text, fullContext);

      final assistantMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      ref.read(chatMessagesProvider.notifier).addMessage(assistantMessage);

      // Save assistant message to Supabase
      await conversationService.saveMessage(
        AssistantMessage(
          userId: defaultUserId,
          role: 'assistant',
          message: response,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        text: 'Sorry, I encountered an error: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );
      ref.read(chatMessagesProvider.notifier).addMessage(errorMessage);
      await conversationService.saveMessage(
        AssistantMessage(
          userId: defaultUserId,
          role: 'assistant',
          message: 'Sorry, I encountered an error: $e',
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  void initState() {
    super.initState();
    _loadChatHistory();

    // Set up real-time sync for assistant messages
    if (SupabaseService.isInitialized) {
      SupabaseService.assistantStream.listen((_) {
        if (mounted) {
          debugPrint('[Realtime] Assistant messages changed, refreshing chat');
          _loadChatHistory();
        }
      });
    } else {
      debugPrint(
          '[Realtime] ⚠️ Supabase not initialized, real-time sync disabled for chat');
    }
  }

  Future<void> _loadChatHistory() async {
    final supabaseClient = Supabase.instance.client;
    final conversationService = AssistantConversationService(supabaseClient);
    const defaultUserId = 'default_user';
    final messages = await conversationService.fetchMessages(
        userId: defaultUserId, limit: 100);
    final chatMessages = messages
        .map((msg) => ChatMessage(
              text: msg.message,
              isUser: msg.role == 'user',
              timestamp: msg.timestamp,
            ))
        .toList();
    ref.read(chatMessagesProvider.notifier).setMessages(chatMessages);
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () async {
              ref.read(chatMessagesProvider.notifier).clearMessages();
              // Clear chat history from Supabase
              final supabaseClient = Supabase.instance.client;
              final conversationService =
                  AssistantConversationService(supabaseClient);
              const defaultUserId = 'default_user';
              await conversationService.clearMessages(userId: defaultUserId);
            },
            tooltip: 'Clear chat',
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.psychology,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Ask me about your habits!',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'I can help you with tips, motivation, and tracking advice.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final message = messages[index];
                      final parsedSuggestions = !message.isUser
                          ? AssistantHabitParser.parseAllHabitSuggestions(
                              message.text)
                          : <ParsedHabitSuggestion>[];
                      if (parsedSuggestions.isNotEmpty) {
                        print(
                            '[AssistantChatPage] Parsed ${parsedSuggestions.length} habit suggestion(s)');
                      }
                      return Column(
                        crossAxisAlignment: message.isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          MessageBubble(
                            message: message.text,
                            isUser: message.isUser,
                          ),
                          if (parsedSuggestions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 48, top: 4, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: parsedSuggestions.map((suggestion) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.add_task),
                                      label: Text('Add "${suggestion.name}"'),
                                      onPressed: () async {
                                        final repository =
                                            ref.read(habitRepositoryProvider);
                                        final now = DateTime.now();
                                        await repository.createHabit(
                                          HabitModel(
                                            name: suggestion.name,
                                            description: suggestion.description,
                                            createdAt: now,
                                            updatedAt: now,
                                          ),
                                        );
                                        // Invalidate dashboard providers for live update
                                        ref.invalidate(completionStatsProvider);
                                        ref.invalidate(habitsProvider);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Habit "${suggestion.name}" added!')),
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Ask about your habits...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      icon: const Icon(Icons.send),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
