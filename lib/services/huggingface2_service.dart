import 'dart:convert';
import 'package:http/http.dart' as http;

class HuggingFaceService {
  final String apiKey =
      "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";
  final String modelUrl = "https://api.groq.com/openai/v1/chat/completions";

  Future<String> getCompatibilityPrediction(String input) async {
    try {
      final response = await http.post(
        Uri.parse(modelUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a friendly relationship compatibility expert who gives thoughtful, positive, and detailed exact predictions.",
            },
            {"role": "user", "content": input},
          ],
          "max_tokens": 800,
          "temperature": 0.7,
        }),
      );

      print("RAW RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["choices"] != null && data["choices"].isNotEmpty) {
          String content =
              data["choices"][0]["message"]["content"] ??
              "No response generated.";
          return content.trim();
        } else {
          return "Unexpected API response format.";
        }
      } else if (response.statusCode == 400) {
        return "Invalid request. Please check your input.";
      } else if (response.statusCode == 401) {
        return "Unauthorized: Please check your API key.";
      } else if (response.statusCode == 403) {
        return "Access denied. You might not have permission to use this feature.";
      } else if (response.statusCode == 404) {
        return "Endpoint or model not found. Please check your settings.";
      } else if (response.statusCode == 429) {
        return "You’ve reached today’s usage limit. Please try again tomorrow!";
      } else if (response.statusCode == 500) {
        return "Server error. Please try again later.";
      } else if (response.statusCode == 503) {
        return "Service temporarily unavailable. Please try again later.";
      } else {
        return "Unexpected error: ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "API Error: $e";
    }
  }
}
