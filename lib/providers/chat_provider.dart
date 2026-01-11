import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatbot/models/message.dart';
import 'package:chatbot/models/chat_session.dart';
import 'package:chatbot/services/grok_service.dart';
import 'package:chatbot/services/chat_services.dart';

final chatServiceProvider = Provider((ref) => ChatService());
final huggingFaceServiceProvider = Provider((ref) => HuggingFaceService());

final chatProvider =
    NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

class ChatState {
  final List<Message> messages;
  final List<ChatSession> sessions;
  final String? currentSessionId;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.sessions = const [],
    this.currentSessionId,
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<Message>? messages,
    List<ChatSession>? sessions,
    String? currentSessionId,
    bool? isLoading,
    String? error,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        sessions: sessions ?? this.sessions,
        currentSessionId: currentSessionId ?? this.currentSessionId,
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
      final sessions = await _chatService.loadSessions();

      String? sessionId;
      List<Message> messages = [];

      if (sessions.isNotEmpty) {
        // Sort by most recent
        sessions.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
        sessionId = sessions.first.id;
        messages = await _chatService.loadMessages(sessionId);
      }

      state = state.copyWith(
        sessions: sessions,
        currentSessionId: sessionId,
        messages: messages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> newChat() async {
    state = state.copyWith(
      currentSessionId: null,
      messages: [],
      error: null,
    );
  }

  Future<void> switchSession(String sessionId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final messages = await _chatService.loadMessages(sessionId);
      state = state.copyWith(
        currentSessionId: sessionId,
        messages: messages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    String? sessionId = state.currentSessionId;
    List<ChatSession> sessions = List.from(state.sessions);

    // Create new session if none is active
    if (sessionId == null) {
      sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      final newSession = ChatSession(
        id: sessionId,
        title: content.length > 30 ? '${content.substring(0, 27)}...' : content,
        lastMessageAt: DateTime.now(),
      );
      sessions.insert(0, newSession);
      await _chatService.saveSessions(sessions);
      state = state.copyWith(currentSessionId: sessionId, sessions: sessions);
    } else {
      // Update session's lastMessageAt
      final index = sessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        sessions[index] =
            sessions[index].copyWith(lastMessageAt: DateTime.now());
        // Move to top
        final updatedSession = sessions.removeAt(index);
        sessions.insert(0, updatedSession);
        await _chatService.saveSessions(sessions);
        state = state.copyWith(sessions: sessions);
      }
    }

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
      final currentMessages = [...state.messages];
      await _chatService.saveMessages(sessionId, currentMessages);

      final response = await _huggingFaceService.generateResponse(content);

      final aiMessage = Message(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: response,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedMessages = [...state.messages, aiMessage];
      state = state.copyWith(
        messages: updatedMessages,
        isLoading: false,
      );

      await _chatService.saveMessages(sessionId, updatedMessages);
    } catch (e) {
      debugPrint('Error in sendMessage: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get AI response. ${e.toString()}',
      );
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      state = state.copyWith(isLoading: true);
      await _chatService.deleteSession(sessionId);

      final sessions = state.sessions.where((s) => s.id != sessionId).toList();
      String? nextSessionId = state.currentSessionId;
      List<Message> nextMessages = state.messages;

      if (sessionId == state.currentSessionId) {
        if (sessions.isNotEmpty) {
          nextSessionId = sessions.first.id;
          nextMessages = await _chatService.loadMessages(nextSessionId);
        } else {
          nextSessionId = null;
          nextMessages = [];
        }
      }

      state = state.copyWith(
        sessions: sessions,
        currentSessionId: nextSessionId,
        messages: nextMessages,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Error deleting session: $e');
      state =
          state.copyWith(isLoading: false, error: 'Failed to delete session.');
    }
  }

  Future<void> clearChat() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _chatService.clearAll();
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
