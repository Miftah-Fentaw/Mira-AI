import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatbot/models/message.dart';
import 'package:chatbot/models/chat_session.dart';

class ChatService {
  static const String _sessionsKey = 'chat_sessions';
  static const String _messagesPrefix = 'chat_messages_';

  Future<List<ChatSession>> loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString(_sessionsKey);

      if (sessionsJson == null || sessionsJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(sessionsJson);
      return decoded
          .map((json) => ChatSession.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading sessions: $e');
      return [];
    }
  }

  Future<void> saveSessions(List<ChatSession> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = jsonEncode(sessions.map((s) => s.toJson()).toList());
      await prefs.setString(_sessionsKey, sessionsJson);
    } catch (e) {
      debugPrint('Error saving sessions: $e');
    }
  }

  Future<List<Message>> loadMessages(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString('$_messagesPrefix$sessionId');

      if (messagesJson == null || messagesJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(messagesJson);
      return decoded
          .map((json) {
            try {
              return Message.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              return null;
            }
          })
          .whereType<Message>()
          .toList();
    } catch (e) {
      debugPrint('Error loading messages for session $sessionId: $e');
      return [];
    }
  }

  Future<void> saveMessages(String sessionId, List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = jsonEncode(messages.map((m) => m.toJson()).toList());
      await prefs.setString('$_messagesPrefix$sessionId', messagesJson);
    } catch (e) {
      debugPrint('Error saving messages for session $sessionId: $e');
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_messagesPrefix$sessionId');
      final sessions = await loadSessions();
      sessions.removeWhere((s) => s.id == sessionId);
      await saveSessions(sessions);
    } catch (e) {
      debugPrint('Error deleting session $sessionId: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessions = await loadSessions();
      for (final session in sessions) {
        await prefs.remove('$_messagesPrefix${session.id}');
      }
      await prefs.remove(_sessionsKey);
    } catch (e) {
      debugPrint('Error clearing all: $e');
    }
  }
}
