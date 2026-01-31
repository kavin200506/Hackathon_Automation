import 'api_client.dart';
import '../core/constants.dart';

class AuthAPI {
  static const String base = AppConstants.apiBasePath;

  static Future<Map<String, dynamic>> studentRegister(Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/students/register', data: data);
    return response.data;
  }

  static Future<Map<String, dynamic>> studentVerifyOTP(Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/students/verify-otp', data: data);
    return response.data;
  }

  static Future<Map<String, dynamic>> studentSetPassword(Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/students/set-password', data: data);
    return response.data;
  }

  static Future<Map<String, dynamic>> studentLogin(Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/students/login', data: data);
    return response.data;
  }

  static Future<Map<String, dynamic>> collegeRegister(Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/colleges/register', data: data);
    return response.data;
  }

  static Future<Map<String, dynamic>> collegeVerifyOTP(Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/colleges/verify-otp', data: data);
    return response.data;
  }

  static Future<Map<String, dynamic>> collegeSetPassword(Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/colleges/set-password', data: data);
    return response.data;
  }

  static Future<Map<String, dynamic>> collegeLogin(Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/colleges/login', data: data);
    return response.data;
  }

  static Future<Map<String, dynamic>> departmentLogin(Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/departments/login', data: data);
    return response.data;
  }

  static Future<Map<String, dynamic>> adminLogin(Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/admin/login', data: data);
    return response.data;
  }
}






