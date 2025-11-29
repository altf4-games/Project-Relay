import 'dart:convert';

class SduiParser {
  static List<Map<String, dynamic>> parsePluginOutput(String jsonString) {
    try {
      final decoded = json.decode(jsonString);

      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      } else if (decoded is Map) {
        return [decoded as Map<String, dynamic>];
      }

      return [];
    } catch (e) {
      throw Exception('Failed to parse plugin output: ${e.toString()}');
    }
  }

  static Map<String, dynamic>? parseWidget(Map<String, dynamic> data) {
    try {
      return {'type': data['type'], 'data': data['data']};
    } catch (e) {
      return null;
    }
  }
}
