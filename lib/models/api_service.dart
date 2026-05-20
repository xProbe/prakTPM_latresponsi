import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://kitsu.io/api/edge';

  static Future<List<dynamic>> fetchAllAnime() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/anime?page[limit]=20&page[offset]=0'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['data'] ?? [];
      } else {
        throw Exception('Failed to load anime: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to Kitsu API: $e');
    }
  }


}
