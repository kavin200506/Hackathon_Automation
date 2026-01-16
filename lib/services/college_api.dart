import 'api_client.dart';
import '../core/constants.dart';

class CollegeAPI {
  static const String base = AppConstants.apiBasePath;

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiClient.get('$base/colleges/profile');
    return response.data;
  }

  static Future<Map<String, dynamic>> createDepartment(Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/colleges/departments', data: data);
    return response.data;
  }

  static Future<List<dynamic>> getDepartments() async {
    final response = await ApiClient.get('$base/colleges/departments');
    return response.data is List ? response.data : [];
  }

  static Future<List<dynamic>> getTeams({Map<String, dynamic>? filters}) async {
    final response = await ApiClient.get('$base/colleges/teams', queryParameters: filters);
    return response.data is List ? response.data : [];
  }

  static Future<List<dynamic>> getCollegesList() async {
    final response = await ApiClient.get('$base/colleges/list');
    return response.data is List ? response.data : [];
  }
}




