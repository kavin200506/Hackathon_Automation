import 'api_client.dart';
import '../core/constants.dart';

class DepartmentAPI {
  static const String base = AppConstants.apiBasePath;

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiClient.get('$base/departments/profile');
    return response.data;
  }

  static Future<List<dynamic>> getTeams({Map<String, dynamic>? filters}) async {
    final response = await ApiClient.get('$base/departments/teams', queryParameters: filters);
    return response.data is List ? response.data : [];
  }
}




