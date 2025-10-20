import 'package:http/http.dart' as http;
import 'dart:convert';

class MasterDataService {
  static const String baseUrl = 'https://sik.luckyabdillah.com/api/v1';

  // GET All Data
  static Future<List<dynamic>> fetchData(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is Map && data.containsKey('data')) {
          if (data['data'] is List) {
            return data['data'];
          } else if (data['data'] is Map) {
            return [data['data']];
          }
        } else if (data is List) {
          return data;
        }
        return [];
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // GET Single Data by ID
  static Future<dynamic> fetchDataById(String endpoint, dynamic id) async { // Ubah ke dynamic
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // POST - Create Data
  static Future<dynamic> createData(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to create data: ${response.statusCode} - ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // PUT - Update Data
  static Future<dynamic> updateData(String endpoint, dynamic id, Map<String, dynamic> data) async { // Ubah ke dynamic
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to update data: ${response.statusCode} - ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // DELETE Data
  static Future<bool> deleteData(String endpoint, dynamic id) async { // Ubah ke dynamic
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}