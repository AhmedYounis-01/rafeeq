// import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // App Information
  static const String appName = 'MazidMart Dashboard';
  static const String appVersion = '1.0.0';
  // static String get supaBaseAnonKey => dotenv.get('SUPABASE_ANON_KEY');
  // API Configuration
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // Animation Durations
  static const int splashAnimationDuration = 2000; // 2 seconds
  static const int fadeAnimationDuration = 500; // 0.5 seconds
  static const int slideAnimationDuration = 300; // 0.3 seconds

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusExtraLarge = 16.0;

  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeExtraLarge = 48.0;

  // Button Heights
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  // Screen Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Local Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;

  // Regex Patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';

  // Error Messages
  static const String networkError = 'Network error occurred';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'Unknown error occurred';
  static const String timeoutError = 'Request timeout';

  // Success Messages
  static const String signInSuccess = 'SignIn successful';
  static const String logoutSuccess = 'Logout successful';
  static const String updateSuccess = 'Update successful';
}
