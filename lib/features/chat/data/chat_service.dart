import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api.dart';
import '../models/message_model.dart';

class ChatService {
  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? conversationId,
    String provider = ApiConstants.defaultProvider,
    String model = ApiConstants.defaultModel,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chatEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        if (conversationId != null) 'conversationId': conversationId,
        'provider': provider,
        'model': model,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }
}
