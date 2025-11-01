import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../data/slm_service.dart';
import '../widgets/message_bubble.dart';

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

final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier();
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier() : super([]);

  void addMessage(ChatMessage message) {
    state = [...state, message];
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

    // Scroll to show user message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      final slmService = ref.read(slmServiceProvider);
      final contextBuilder = SLMContextBuilder();
      final context = await contextBuilder.buildContext();
      final response = await slmService.generateResponse(text, context);

      final assistantMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      ref.read(chatMessagesProvider.notifier).addMessage(assistantMessage);
    } catch (e) {
      final errorMessage = ChatMessage(
        text: 'Sorry, I encountered an error: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );
      ref.read(chatMessagesProvider.notifier).addMessage(errorMessage);
    } finally {
      setState(() => _isLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
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
            onPressed: () {
              ref.read(chatMessagesProvider.notifier).clearMessages();
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
                        Icon(Icons.psychology, size: 64, color: Colors.grey[400]),
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
                      return MessageBubble(
                        message: message.text,
                        isUser: message.isUser,
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

