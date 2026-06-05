import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'chat_model.dart';

class ChatApiService {
  static const String _baseUrl = 'https://symptom-checker-swsc.onrender.com';

  Future<DiagnosisResponse?> sendDiagnosisRequest(DiagnosisRequest request) async {
    final url = Uri.parse('$_baseUrl/diagnosis');
    
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return DiagnosisResponse.fromJson(jsonDecode(response.body));
      } else {
        debugPrint("API Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Exception: $e");
      return null;
    }
  }
}