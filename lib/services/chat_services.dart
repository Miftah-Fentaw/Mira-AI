import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatbot/models/message.dart';

class ChatService {
  static const String _messagesKey = 'chat_messages';

  Future<List<Message>> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey);
      
      if (messagesJson == null || messagesJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(messagesJson);
      return decoded.map((json) {
        try {
          return Message.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          return null;
        }
      }).whereType<Message>().toList();
    } catch (e) {
      debugPrint('Error loading messages: $e');
      return [];
    }
  }

  Future<void> saveMessages(List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = jsonEncode(messages.map((m) => m.toJson()).toList());
      await prefs.setString(_messagesKey, messagesJson);
    } catch (e) {
      debugPrint('Error saving messages: $e');
    }
  }

  Future<void> addMessage(Message message) async {
    final messages = await loadMessages();
    messages.add(message);
    await saveMessages(messages);
  }

  Future<void> clearMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_messagesKey);
    } catch (e) {
      debugPrint('Error clearing messages: $e');
    }
  }
}
