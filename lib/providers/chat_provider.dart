import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatbot/models/message.dart';
import 'package:chatbot/services/grok_service.dart';
import 'package:chatbot/services/chat_services.dart';

final chatServiceProvider = Provider((ref) => ChatService());
final huggingFaceServiceProvider = Provider((ref) => HuggingFaceService());

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? error,
  }) => ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ChatNotifier extends Notifier<ChatState> {
  late final ChatService _chatService;
  late final HuggingFaceService _huggingFaceService;

  @override
  ChatState build() {
    _chatService = ref.read(chatServiceProvider);
    _huggingFaceService = ref.read(huggingFaceServiceProvider);

    return ChatState();
  }

  Future<void> init() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final messages = await _chatService.loadMessages();
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      await _chatService.addMessage(userMessage);

      final response = await _huggingFaceService.generateResponse(content);
      
      final aiMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );

      await _chatService.addMessage(aiMessage);
    } catch (e) {
      debugPrint('Error in sendMessage: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get AI response. ${e.toString()}',
      );
    }
  }

  Future<void> clearChat() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _chatService.clearMessages();
      state = ChatState(isLoading: false);
    } catch (e) {
      debugPrint('Error clearing chat: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to clear chat. Please try again.',
      );
    }
  }
}