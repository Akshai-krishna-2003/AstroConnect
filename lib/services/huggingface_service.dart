import 'dart:convert';
import 'package:http/http.dart' as http;

class FalconService {
  final String _apiKey =
      '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';
  final String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> getAstrologyResponse(
    String name,
    String dob,
    String time,
    String pob,
  ) async {
    try {
      String prompt =
          "Astrology reading for Name: $name, Date of Birth: $dob, Time of Birth: $time, Place of Birth: $pob. Analyze the birth chart and provide insights on Career, Finance, Love, Health, Personality Traits, and Major Upcoming Events based on Vedic astrology.";

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a knowledgeable Vedic astrologer who provides deep and empathetic insights and exact insights.",
            },
            {"role": "user", "content": prompt},
          ],
          "max_tokens": 800,
          "temperature": 0.7,
        }),
      );

      print("RAW RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["choices"] != null && data["choices"].isNotEmpty) {
          String generatedText =
              data["choices"][0]["message"]["content"] ??
              'No astrology insights available.';
          return generatedText.trim();
        } else {
          return "Unexpected API response format.";
        }
      } else if (response.statusCode == 400) {
        return "Something went wrong with your request. Please contact support or try again later.";
      } else if (response.statusCode == 401) {
        return "Authentication failed. Please check your API key.";
      } else if (response.statusCode == 403) {
        return "Access denied. You might not have permission to use this feature.";
      } else if (response.statusCode == 404) {
        return "The requested resource was not found. Please check your model settings.";
      } else if (response.statusCode == 429) {
        return "You’ve reached today’s usage limit. Please try again tomorrow!";
      } else if (response.statusCode == 500) {
        return "The server encountered an error. Please try again later.";
      } else if (response.statusCode == 503) {
        return "Service is temporarily unavailable. Please try again in a few minutes.";
      } else {
        return "Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "API Error: $e";
    }
  }
}
