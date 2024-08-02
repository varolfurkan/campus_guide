import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiApiService {
  final String apiKey = 'AIzaSyAAzd4w2bSqRcVEz-K0GUO99SqE8rsep6s';
  final String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';

  Future<String> getResponse(String userInput) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {"parts": [{"text": userInput}]}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['candidates'] != null && data['candidates'].isNotEmpty) {
          final candidate = data['candidates'][0];
          final content = candidate['content'];
          if (content != null && content['parts'] != null && content['parts'].isNotEmpty) {
            return content['parts'][0]['text'];
          } else {
            throw Exception('Unexpected content structure');
          }
        } else {
          throw Exception('Unexpected candidates structure');
        }
      } else {
        throw Exception('Failed to load response: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get response from Gemini API');
    }
  }
}
