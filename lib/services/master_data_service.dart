import 'package:http/http.dart' as http;
import 'dart:convert';

class MasterDataService {
  static const String baseUrl = 'https://sik.luckyabdillah.com/api/v1';

  // GET All Data - ROBUST VERSION
  static Future<List<dynamic>> fetchData(String endpoint) async {
    try {
      print('🔄 Fetching data from: $endpoint');
      
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Raw response for $endpoint: ${data.runtimeType}');
        
        // Debug: print keys untuk melihat struktur
        if (data is Map) {
          print('🔑 Top level keys: ${data.keys}');
          if (data.containsKey('data') && data['data'] is Map) {
            print('🔑 Data keys: ${data['data'].keys}');
          }
        }

        // Extract data berdasarkan endpoint
        List<dynamic> result = [];
        
        if (endpoint == 'work-permit-letters') {
          // Handle SIK khusus
          if (data is Map && data.containsKey('data')) {
            if (data['data'] is Map && data['data'].containsKey('data')) {
              result = data['data']['data'] is List ? data['data']['data'] : [];
            } else if (data['data'] is List) {
              result = data['data'];
            }
          }
        } else {
          // Handle API lainnya (vendors, work-types, dll)
          if (data is Map && data.containsKey('data')) {
            if (data['data'] is List) {
              result = data['data'];
            } else if (data['data'] is Map && data['data'].containsKey('data')) {
              // Fallback untuk kasus nested data
              result = data['data']['data'] is List ? data['data']['data'] : [];
            }
          } else if (data is List) {
            result = data;
          }
        }

        // Fallback: jika masih kosong, coba ekstrak langsung
        if (result.isEmpty && data is Map) {
          // Cari key yang berisi List
          for (var key in data.keys) {
            if (data[key] is List) {
              result = data[key];
              break;
            }
          }
        }

        print('✅ Extracted ${result.length} items from $endpoint');
        return result;

      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Service Error for $endpoint: $e');
      throw Exception('Error: $e');
    }
  }

  // GET Single Data by ID
  static Future<dynamic> fetchDataById(String endpoint, dynamic id) async {
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
        
        // Return data langsung atau nested data
        if (data is Map && data.containsKey('data')) {
          return data['data'];
        }
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
  static Future<dynamic> updateData(String endpoint, dynamic id, Map<String, dynamic> data) async {
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
  static Future<bool> deleteData(String endpoint, dynamic id) async {
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