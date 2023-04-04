import 'dart:convert';
import 'package:http/http.dart' as http;

import 'config.dart';

class OpenAIService {
  final List<Map<String, String>> messages = [];

  Future<String> chatGPTAPI(String prompt) async {
    String promptForKids =
        '$prompt , can you answer that in 20 words, in a scientific and easy to understand way for preschool children?';
    messages.add({
      'role': 'user',
      'content': promptForKids,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $OPEN_AI_API_KEY',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }
}
