/// API Endpoints for MazidMart Supabase Backend
///
/// All endpoints are PostgreSQL RPC function calls
class Endpoints {
  // Base configuration
  // static String get baseUrl => SupabaseConfig.rpcUrl;
  // static String get supabaseAnonKey => SupabaseConfig.supabaseAnonKey;

  // ==================== Authentication Endpoints ====================

  /// Create a super admin account (requires secret key)
  static const String createSuperAdmin = 'create_super_admin';

  /// Customer signup
  static const String signupCustomer = 'signup_customer';

  /// Admin signup (requires whitelist)
  static const String signupAdmin = 'signup_admin';

  /// Admin creation by super admin
  static const String adminCreateAdmin = 'admin_create_admin';

  /// User login (all roles)
  static const String loginUser = 'login_user';

  /// Request password reset code
  static const String requestPasswordReset = 'request_password_reset';

  /// Reset password with verification code
  static const String resetPassword = 'reset_password';

  // ==================== User Management Endpoints ====================

  /// Get current user profile
  static const String getCurrentUser = 'get_current_user';

  /// Update user profile
  static const String updateProfile = 'update_profile';

  /// Change password
  static const String changePassword = 'change_password';

  /// Delete user account
  static const String deleteAccount = 'delete_account';

  // ==================== Admin Control Endpoints ====================

  /// Get admin whitelist
  static const String getWhitelist = 'get_whitelist';

  /// Add email to admin whitelist
  static const String addToWhitelist = 'add_to_whitelist';

  /// Remove email from whitelist
  static const String removeFromWhitelist = 'remove_from_whitelist';

  /// Get all customers (admin)
  static const String adminGetAllCustomers = 'admin_get_all_customers';

  /// Get customer details (admin)
  static const String adminGetCustomerDetails = 'admin_get_customer_details';

  /// Search customers (admin)
  static const String adminSearchCustomers = 'admin_search_customers';

  /// Toggle customer status (admin)
  static const String adminToggleCustomerStatus =
      'admin_toggle_customer_status';

  // ==================== Product Endpoints ====================

  /// Get home screen data (featured products, categories, etc.)
  static const String getHomeScreenData = 'get_home_screen_data';

  /// Get all products with pagination
  static const String getAllProducts = 'get_all_products';

  /// Get product details by ID
  static const String getProductDetails = 'get_product_details';

  /// Search and filter products
  static const String searchProducts = 'search_products';

  /// Get products by category
  static const String getProductsByCategory = 'get_products_by_category';

  // ==================== Admin Product Management ====================

  /// Add new product (admin)
  static const String adminAddProduct = 'admin_add_product';

  /// Update product (admin)
  static const String adminUpdateProduct = 'admin_update_product';

  /// Delete product (admin)
  static const String adminDeleteProduct = 'admin_delete_product';

  /// Get low stock products (admin)
  static const String adminGetLowStockProducts = 'admin_get_low_stock_products';

  // ==================== Category Endpoints ====================

  /// Get all categories
  static const String getAllCategories = 'get_categories';

  /// Add category (admin)
  static const String adminAddCategory = 'admin_add_category';

  /// Update category (admin)
  static const String adminUpdateCategory = 'admin_update_category';

  /// Delete category (admin)
  static const String adminDeleteCategory = 'admin_delete_category';

  // ==================== Cart Endpoints ====================

  /// Add item to cart
  static const String addToCart = 'add_to_cart';

  /// Get cart summary
  static const String getCartSummary = 'get_cart_summary';

  /// Update cart item quantity
  static const String updateCartItem = 'update_cart_item';

  /// Remove item from cart
  static const String removeFromCart = 'remove_from_cart';

  /// Clear entire cart
  static const String clearCart = 'clear_cart';

  /// Sync local cart to server
  static const String syncCart = 'sync_cart';

  // ==================== Wishlist Endpoints ====================

  /// Add item to wishlist
  static const String addToWishlist = 'add_to_wishlist';

  /// Get user's wishlist
  static const String getWishlist = 'get_wishlist';

  /// Remove item from wishlist
  static const String removeFromWishlist = 'remove_from_wishlist';

  /// Sync local wishlist to server
  static const String syncWishlist = 'sync_wishlist';

  // ==================== Order Endpoints ====================

  /// Create new order
  static const String createOrder = 'create_order';

  /// Get customer's orders
  static const String getMyOrders = 'get_my_orders';

  /// Get order details by ID (admin)
  static const String adminGetOrderDetails = 'admin_get_order_details';

  /// Get order details by ID (customer)
  static const String getOrderDetails = 'get_order_details';

  /// Cancel order
  static const String cancelOrder = 'cancel_order';

  /// Get all orders (admin)
  static const String adminGetAllOrders = 'admin_get_all_orders';

  /// Update order status (admin)
  static const String adminUpdateOrderStatus = 'admin_update_order_status';

  /// Get order statistics (admin)
  static const String adminGetOrderStats = 'admin_get_order_stats';

  /// Get detailed order statistics (admin)
  static const String adminGetOrdersStatistics = 'admin_get_orders_statistics';

  // ==================== Notification Endpoints ====================

  /// Get user notifications
  static const String getNotifications = 'get_my_notifications';

  /// Mark notification as read
  static const String markNotificationAsRead = 'mark_notification_read';

  /// Mark all notifications as read
  static const String markAllAsRead = 'mark_all_notifications_read';

  /// Delete Specific Notification
  static const String deleteNotification = 'delete_notification';

  /// Get unread notification count
  static const String getUnreadCount = 'get_unread_count';

  /// Send notification to specific user (admin)
  static const String adminSendNotificationSingle =
      'admin_send_notification_single';

  /// Send notification to multiple users (admin)
  static const String adminSendNotificationMultiple =
      'admin_send_notification_multiple';

  /// Send broadcast notification (admin)
  static const String adminSendBroadcast = 'admin_send_broadcast_notification';

  // ==================== Dashboard & Analytics Endpoints ====================

  /// Get dashboard overview (admin)
  static const String getDashboardOverview = 'get_dashboard_overview';

  /// Get sales analytics (admin)
  static const String getSalesAnalytics = 'get_sales_analytics';

  /// Get customer statistics (admin)
  static const String getCustomerStats = 'get_customer_stats';

  /// Get top products (admin)
  static const String getTopProducts = 'get_top_products';

  /// Get complete dashboard data (admin)
  static const String getCompleteDashboard = 'admin_get_complete_dashboard';
}
