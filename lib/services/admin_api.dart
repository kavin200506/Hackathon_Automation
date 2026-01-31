import 'api_client.dart';
import '../core/constants.dart';

class AdminAPI {
  static const String base = AppConstants.apiBasePath;

  static Future<Map<String, dynamic>> createHackathon(Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/admin/hackathons', data: data);
    return response.data;
  }

  static Future<List<dynamic>> getHackathons() async {
    final response = await ApiClient.get('$base/admin/hackathons');
    return response.data is List ? response.data : [];
  }

  static Future<Map<String, dynamic>> updateHackathon(String id, Map<String, dynamic> data) async {
    final response = await ApiClient.put('$base/admin/hackathons/$id', data: data);
    return response.data;
  }

  static Future<Map<String, dynamic>> createTopic(Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/admin/topics', data: data);
    return response.data;
  }

  static Future<List<dynamic>> getTopics() async {
    final response = await ApiClient.get('$base/admin/topics');
    return response.data is List ? response.data : [];
  }

  static Future<Map<String, dynamic>> createAnnouncement(Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/admin/announcements', data: data);
    return response.data;
  }

  static Future<List<dynamic>> getAnnouncements() async {
    final response = await ApiClient.get('$base/admin/announcements');
    return response.data is List ? response.data : [];
  }

  static Future<List<dynamic>> getColleges() async {
    final response = await ApiClient.get('$base/admin/colleges');
    return response.data is List ? response.data : [];
  }

  static Future<List<dynamic>> getTeams({Map<String, dynamic>? filters}) async {
    final response = await ApiClient.get('$base/admin/teams', queryParameters: filters);
    return response.data is List ? response.data : [];
  }

  static Future<Map<String, dynamic>> getStats() async {
    final response = await ApiClient.get('$base/admin/stats');
    return response.data;
  }
}






