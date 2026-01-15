
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ahp_data.dart';

class ApiService {
  // TODO: Replace with your actual Gist Raw URL
  static const String _gistUrl = 'https://gist.githubusercontent.com/YOUR_USERNAME/YOUR_GIST_ID/raw/config.json';

  Future<String> _getBaseUrl() async {
    try {
      final response = await http.get(Uri.parse(_gistUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> config = json.decode(response.body);
        return config['base_url'];
      } else {
        throw Exception('Failed to load config from Gist');
      }
    } catch (e) {
      // Fallback for development/testing if Gist fails or not set
      print('Error fetching Gist: $e');
      throw Exception('Could not fetch Server URL. Check Gist config.');
    }
  }

  Future<AhpResult> submitAhpCalculation(AhpSubmitData data) async {
    final baseUrl = await _getBaseUrl();
    final url = Uri.parse('$baseUrl/calculate');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data.toJson()),
      );

      if (response.statusCode == 200) {
        return AhpResult.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      throw Exception('Failed to connect to AHP Engine: $e');
    }
  }
}
