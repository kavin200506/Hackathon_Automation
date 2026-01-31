import 'api_client.dart';
import '../core/constants.dart';

class StudentAPI {
  static const String base = AppConstants.apiBasePath;

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiClient.get('$base/students/profile');
    return response.data;
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await ApiClient.put('$base/students/profile', data: data);
    return response.data;
  }

  static Future<Map<String, dynamic>> createTeam(Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/teams/', data: data);
    return response.data;
  }

  static Future<List<dynamic>> getMyTeams() async {
    final response = await ApiClient.get('$base/teams/');
    return response.data is List ? response.data : [];
  }

  static Future<Map<String, dynamic>> updateTeam(String teamId, Map<String, dynamic> data) async {
    final response = await ApiClient.patch('$base/teams/$teamId', data: data);
    return response.data;
  }

  static Future<Map<String, dynamic>> addTeamMember(String teamId, Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/teams/$teamId/members', data: data);
    return response.data;
  }

  static Future<Map<String, dynamic>> removeTeamMember(String teamId, String memberId) async {
    final response = await ApiClient.post('$base/teams/$teamId/members/$memberId/remove');
    return response.data;
  }

  static Future<Map<String, dynamic>> joinHackathon(String teamId, String hackathonId, String topicId) async {
    final response = await ApiClient.post(
      '$base/teams/$teamId/join-hackathon',
      data: {
        'hackathon_id': hackathonId,
        'topic_id': topicId,
      },
    );
    return response.data;
  }

  static Future<List<dynamic>> getAnnouncements() async {
    final response = await ApiClient.get('$base/students/announcements');
    return response.data is List ? response.data : [];
  }
}






