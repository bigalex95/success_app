import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';
import '../slm_service.dart';

class GeminiProvider implements SLMService {
  final String apiKey = AppConfig.geminiApiKey;
  final String model = AppConfig.geminiModel;

  @override
  Future<String> generateResponse(
      String userMessage, Map<String, dynamic> context) async {
    final contextBuilder = SLMContextBuilder();
    final prompt = contextBuilder.buildPrompt(userMessage, context);

    try {
      // Gemini API endpoint
      final url =
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'] as String? ??
                'Sorry, I could not generate a response.';
          }
        }
        return 'Sorry, I could not generate a response.';
      } else {
        final errorData = jsonDecode(response.body);
        return 'Error connecting to Gemini API: ${errorData['error']?['message'] ?? response.statusCode}';
      }
    } catch (e) {
      return 'Error: Could not connect to Gemini API. ${e.toString()}';
    }
  }
}
