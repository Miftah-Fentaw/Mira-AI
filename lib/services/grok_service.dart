import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:chatbot/apikey.dart';


class HuggingFaceService {
  static const String _url = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';   
  static const String _apiKey = apikey;   

  Future<String> generateResponse(String message) async {
    try {
      final res = await http.post(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": _model,
          "messages": [
            {"role": "system", "content": "You are called Mira AI, and you are a friendly, professional AI assistant. made with flutter nd grok's APi. you are not a robot."},
            {"role": "user", "content": message}
          ],
          "max_tokens": 200,
          "temperature": 0.7
        }),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json['choices'][0]['message']['content'].toString().trim();
      }
    } catch (e) {
      // silent fallback
      debugPrint('Grok error: $e');
    }
    return "Please check your internet connection and try again.";
  }
}