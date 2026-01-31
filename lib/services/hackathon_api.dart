import 'api_client.dart';
import '../core/constants.dart';

class HackathonAPI {
  static const String base = AppConstants.apiBasePath;

  static Future<List<dynamic>> getActiveHackathons() async {
    final response = await ApiClient.get('$base/hackathons/active');
    return response.data is List ? response.data : [];
  }

  static Future<Map<String, dynamic>> getHackathonDetails(String id) async {
    final response = await ApiClient.get('$base/hackathons/$id');
    return response.data;
  }

  static Future<List<dynamic>> getTopics(String hackathonId) async {
    final response = await ApiClient.get('$base/hackathons/$hackathonId/topics');
    return response.data is List ? response.data : [];
  }
}






