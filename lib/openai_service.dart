import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kids_qa_bot/settings.dart';

import 'config.dart';

class OpenAIService {
  final List<Map<String, String>> messages = [];

  Future<String> chatGPTAPI(String prompt, Language language) async {
    String promptForKids;
    switch (language) {
      case Language.english:
        promptForKids =
            '$prompt , can you answer that in 20 words, in a scientific and easy to understand way for preschool children?';
        break;
      case Language.chinese:
        promptForKids = '$prompt , 你能用中文30个字以内, 用一种小朋友容易理解的方式回答吗?';
        break;
      default:
        promptForKids =
            '$prompt , can you answer that in 20 words, in a scientific and easy to understand way for preschool children?';
        break;
    }

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
        // print(utf8.decode(content.runes.toList()));
        content = content.trim();
        content = utf8.decode(content.runes.toList());

        String suffix = '(This is the simplified Chinese translation.)';
        if (content.endsWith(suffix)) {
          content = content.substring(0, content.length - suffix.length);
        }

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
