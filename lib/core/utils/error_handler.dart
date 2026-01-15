import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import '../theme.dart';

class ErrorHandler {
  static void handleAPIError(dynamic error) {
    String message = 'An unexpected error occurred.';

    if (error is DioException) {
      if (error.response != null) {
        // Server responded with error
        final data = error.response?.data;
        message = data?['error'] ?? 
                  data?['message'] ?? 
                  'An error occurred';
      } else if (error.type == DioExceptionType.connectionTimeout ||
                 error.type == DioExceptionType.receiveTimeout ||
                 error.type == DioExceptionType.sendTimeout) {
        message = 'Connection timeout. Please try again.';
      } else if (error.type == DioExceptionType.connectionError) {
        message = 'Network error. Please check your connection.';
      } else {
        message = 'Network error. Please check your connection.';
      }
    }

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: const Color(0xFF363636),
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: AppTheme.success600,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: AppTheme.error500,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}

