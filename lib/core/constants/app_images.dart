class AppImages {
  // Base path for images
  static const String _basePath = 'assets/images/';

  // Logo images
  static const String silverLogoDark = '${_basePath}silver_logo_dark.jpg';
  static const String silverLogoLight = '${_basePath}silver_logo_light.jpg';

  // Icon images
  static const String appIcon = '${_basePath}app_icon.png';

  // Background images
  static const String signInBackground = '${_basePath}SignIn_bg.png';
  static const String splashBackground = '${_basePath}splash_bg.png';

  // Placeholder images
  static const String userPlaceholder = '${_basePath}user_placeholder.png';
  static const String imagePlaceholder = '${_basePath}image_placeholder.png';

  // Illustration images
  static const String emptyState = '${_basePath}empty_state.png';
  static const String errorState = '${_basePath}error_state.png';
  static const String noInternet = '${_basePath}no_internet.png';

  // Feature specific images
  static const String dashboard = '${_basePath}dashboard.png';
  static const String analytics = '${_basePath}analytics.png';
  static const String settings = '${_basePath}settings.png';

  // Flags images
  static const String egflag = '${_basePath}egypt_flag.png';
  static const String ureflag = '${_basePath}ure_flag.png';

  // Notifications images
  static const String emptyNotification = '${_basePath}empty_notification.png';

  // Helper method to get image path
  static String getImagePath(String imageName) {
    return '$_basePath$imageName';
  }

  // Helper method to check if image exists (you can implement this with asset checking)
  static bool imageExists(String imagePath) {
    // This would need to be implemented with proper asset checking
    // For now, return true
    return true;
  }
}
