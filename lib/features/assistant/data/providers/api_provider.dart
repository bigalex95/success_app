import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';
import '../slm_service.dart';

class APIModelProvider implements SLMService {
  final String baseUrl = AppConfig.apiBaseUrl;
  final String apiKey = AppConfig.apiKey;

  @override
  Future<String> generateResponse(String userMessage, Map<String, dynamic> context) async {
    // This is a placeholder for future API integration
    // Could be adapted for OpenAI, Anthropic, etc.
    
    final contextBuilder = SLMContextBuilder();
    final prompt = contextBuilder.buildPrompt(userMessage, context);

    try {
      // Example for OpenAI-style API (adjust as needed)
      final response = await http.post(
        Uri.parse('$baseUrl/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful habit tracking assistant.'},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String? ?? 
               'Sorry, I could not generate a response.';
      } else {
        return 'Error connecting to API. Status: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: Could not connect to API. ${e.toString()}';
    }
  }
}

