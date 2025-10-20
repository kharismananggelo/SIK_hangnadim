// work_permit_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'work_permit_letter.dart';

class WorkPermitService {
  static const String baseUrl = 'https://sik.luckyabdillah.com/api/v1';

  static Future<WorkPermitResponse> fetchWorkPermits() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/work-permit-letters'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WorkPermitResponse.fromJson(data);
      } else {
        throw Exception('Failed to load work permits: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}