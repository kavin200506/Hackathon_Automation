import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class ApiClient {
  static Dio? _dio;
  static String? _baseUrl;

  static Future<String> _fetchBaseURL() async {
    try {
      final dio = Dio();
      final response = await dio.get(AppConstants.dynamicUrlEndpoint);
      final baseUrl = response.data?['base_url'] ?? AppConstants.defaultBaseUrl;
      print('✅ Fetched dynamic URL: $baseUrl');
      return baseUrl;
    } catch (error) {
      print('❌ Failed to fetch dynamic URL: $error');
      return AppConstants.defaultBaseUrl;
    }
  }

  static Future<Dio> getClient() async {
    if (_dio != null && _baseUrl != null) {
      return _dio!;
    }

    _baseUrl = await _fetchBaseURL();
    
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl!,
        connectTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Request Interceptor
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print('🚀 API Request: ${options.method} ${options.path}');
          
          // Add auth token
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.accessTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Check for bypass auth
            final prefs = await SharedPreferences.getInstance();
            final bypass = prefs.getBool(AppConstants.bypassAuthKey) ?? false;
            
            if (!bypass) {
              await prefs.clear();
              // Navigate to home - handled by router
              print('⚠️ 401 Unauthorized - Clearing storage');
            } else {
              print('⚠️ Bypass auth enabled: skipping 401 redirect/clear');
            }
          }
          
          if (error.response != null) {
            print('❌ API Response Error: ${error.response?.statusCode} ${error.requestOptions.path}');
            print('Error data: ${error.response?.data}');
          } else if (error.type == DioExceptionType.connectionTimeout ||
                     error.type == DioExceptionType.receiveTimeout) {
            print('❌ API Timeout: ${error.requestOptions.path}');
          } else {
            print('❌ API No Response: ${error.requestOptions.path}');
          }
          
          return handler.next(error);
        },
        onResponse: (response, handler) {
          print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
      ),
    );

    return _dio!;
  }

  static Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    final client = await getClient();
    return client.get(endpoint, queryParameters: queryParameters);
  }

  static Future<Response> post(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    final client = await getClient();
    return client.post(endpoint, data: data, queryParameters: queryParameters);
  }

  static Future<Response> put(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    final client = await getClient();
    return client.put(endpoint, data: data, queryParameters: queryParameters);
  }

  static Future<Response> patch(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    final client = await getClient();
    return client.patch(endpoint, data: data, queryParameters: queryParameters);
  }

  static Future<Response> delete(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    final client = await getClient();
    return client.delete(endpoint, queryParameters: queryParameters);
  }

  static void reset() {
    _dio = null;
    _baseUrl = null;
  }
}

