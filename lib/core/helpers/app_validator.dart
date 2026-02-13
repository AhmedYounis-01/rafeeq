import 'package:easy_localization/easy_localization.dart';
import 'app_regex.dart';

class AppValidator {
  /// Simple required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? 'auth.${fieldName}Required'.tr()
          : 'auth.fieldRequired'.tr();
    }
    return null;
  }

  /// Email validation using AppRegex
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'auth.emailRequired'.tr();
    }
    if (!AppRegex.isEmailValid(value)) {
      return 'auth.invalidEmail'.tr();
    }
    return null;
  }

  /// Password validation with customizable minimum length
  static String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'auth.passwordRequired'.tr();
    }
    if (value.length < minLength) {
      return 'auth.passwordTooShort'.tr();
    }
    return null;
  }

  /// Confirm Password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'auth.confirmPasswordRequired'.tr();
    }
    if (value != password) {
      return 'auth.passwordsDoNotMatch'.tr();
    }
    return null;
  }

  /// Phone number validation using AppRegex
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'auth.phoneRequired'.tr();
    }
    // if (!AppRegex.isPhoneNumberValid(value)) {
    //   return 'auth.invalidPhone'.tr();
    // }
    return null;
  }

  /// Name validation (First or Last)
  static String? validateName(
    String? value, {
    required String fieldName,
    int minLength = 2,
  }) {
    if (value == null || value.isEmpty) {
      return 'auth.${fieldName}Required'.tr();
    }
    if (value.length < minLength) {
      return 'auth.${fieldName}TooShort'.tr();
    }
    return null;
  }

  /// Generic regex validation for customization
  static String? validateCustomRegex(
    String? value,
    String pattern,
    String errorKey,
  ) {
    if (value == null || value.isEmpty) {
      return 'auth.fieldRequired'.tr();
    }
    if (!RegExp(pattern).hasMatch(value)) {
      return errorKey.tr();
    }
    return null;
  }
}
