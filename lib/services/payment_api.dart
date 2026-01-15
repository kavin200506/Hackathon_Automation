import 'api_client.dart';
import '../core/constants.dart';

class PaymentAPI {
  static const String base = AppConstants.apiBasePath;

  static Future<Map<String, dynamic>> createPaymentOrder(Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/payments/create-order', data: data);
    return response.data;
  }

  static Future<Map<String, dynamic>> verifyPayment(Map<String, dynamic> data) async {
    final response = await ApiClient.post('$base/payments/verify', data: data);
    return response.data;
  }

  static Future<Map<String, dynamic>> applyCoupon(String couponCode, double amount) async {
    final response = await ApiClient.post(
      '$base/payments/apply-coupon',
      data: {
        'coupon_code': couponCode,
        'amount': amount,
      },
    );
    return response.data;
  }
}

