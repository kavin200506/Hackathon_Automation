class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return "Passwords don't match";
    }
    return null;
  }

  static String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    final mobileRegex = RegExp(r'^[0-9]{10}$');
    if (!mobileRegex.hasMatch(value)) {
      return 'Mobile number must be 10 digits';
    }
    return null;
  }

  static String? validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Year is required';
    }
    final yearRegex = RegExp(r'^[0-9]{4}$');
    if (!yearRegex.hasMatch(value)) {
      return 'Invalid year';
    }
    final year = int.tryParse(value);
    if (year == null || year < 1900 || year > 2100) {
      return 'Invalid year';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  static String? validateNumber(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (min != null && number < min) {
      return 'Value must be at least $min';
    }
    if (max != null && number > max) {
      return 'Value cannot exceed $max';
    }
    return null;
  }
}




