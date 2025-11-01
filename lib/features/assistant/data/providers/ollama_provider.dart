import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';
import '../slm_service.dart';

class OllamaProvider implements SLMService {
  final String baseUrl = AppConfig.ollamaBaseUrl;
  final String model = AppConfig.ollamaModel;

  @override
  Future<String> generateResponse(String userMessage, Map<String, dynamic> context) async {
    final contextBuilder = SLMContextBuilder();
    final prompt = contextBuilder.buildPrompt(userMessage, context);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': model,
          'prompt': prompt,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] as String? ?? 'Sorry, I could not generate a response.';
      } else {
        return 'Error connecting to Ollama. Please make sure Ollama is running and the model "$model" is available.';
      }
    } catch (e) {
      return 'Error: Could not connect to Ollama at $baseUrl. ${e.toString()}';
    }
  }
}

