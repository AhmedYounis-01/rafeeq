// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// /// Session Manager for Supabase User Sessions
// ///
// /// Manages user session data including user ID, role, and profile information
// class SessionManager {
//   static final SessionManager _instance = SessionManager._internal();
//   factory SessionManager() => _instance;
//   SessionManager._internal();

//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   // Storage keys
//   static const String _userIdKey = 'user_id';
//   static const String _userEmailKey = 'user_email';
//   static const String _userRoleKey = 'user_role';
//   static const String _userFirstNameKey = 'user_first_name';
//   static const String _userLastNameKey = 'user_last_name';
//   static const String _userPhoneKey = 'user_phone';

//   // ==================== User Session Management ====================

//   /// Save complete user session data after login
//   Future<void> saveUserSession({
//     required String userId,
//     required String role,
//     String? email,
//     String? firstName,
//     String? lastName,
//     String? phone,
//   }) async {
//     await Future.wait([
//       _storage.write(key: _userIdKey, value: userId),
//       _storage.write(key: _userRoleKey, value: role),
//       if (email != null) _storage.write(key: _userEmailKey, value: email),
//       if (firstName != null)
//         _storage.write(key: _userFirstNameKey, value: firstName),
//       if (lastName != null)
//         _storage.write(key: _userLastNameKey, value: lastName),
//       if (phone != null) _storage.write(key: _userPhoneKey, value: phone),
//     ]);
//   }

//   /// Get user ID from storage
//   Future<String?> getUserId() async {
//     return await _storage.read(key: _userIdKey);
//   }

//   /// Get user role from storage
//   /// Returns: 'customer', 'admin', or 'super_admin'
//   Future<String?> getUserRole() async {
//     return await _storage.read(key: _userRoleKey);
//   }

//   /// Get user email from storage
//   Future<String?> getUserEmail() async {
//     return await _storage.read(key: _userEmailKey);
//   }

//   /// Get user first name from storage
//   Future<String?> getUserFirstName() async {
//     return await _storage.read(key: _userFirstNameKey);
//   }

//   /// Get user last name from storage
//   Future<String?> getUserLastName() async {
//     return await _storage.read(key: _userLastNameKey);
//   }

//   /// Get user phone from storage
//   Future<String?> getUserPhone() async {
//     return await _storage.read(key: _userPhoneKey);
//   }

//   /// Get full user name
//   Future<String?> getUserFullName() async {
//     final firstName = await getUserFirstName();
//     final lastName = await getUserLastName();

//     if (firstName != null || lastName != null) {
//       return '${firstName ?? ''} ${lastName ?? ''}'.trim();
//     }

//     return await getUserEmail();
//   }

//   /// Check if user is logged in
//   Future<bool> isLoggedIn() async {
//     final userId = await getUserId();
//     return userId != null && userId.isNotEmpty;
//   }

//   /// Check if user is admin or super admin
//   Future<bool> isAdmin() async {
//     final role = await getUserRole();
//     return role == 'admin' || role == 'super_admin';
//   }

//   /// Check if user is super admin
//   Future<bool> isSuperAdmin() async {
//     final role = await getUserRole();
//     return role == 'super_admin';
//   }

//   /// Check if user is customer
//   Future<bool> isCustomer() async {
//     final role = await getUserRole();
//     return role == 'customer';
//   }

//   // ==================== Session Cleanup ====================

//   /// Clear all user session data (logout)
//   Future<void> clearSession() async {
//     await Future.wait([
//       _storage.delete(key: _userIdKey),
//       _storage.delete(key: _userRoleKey),
//       _storage.delete(key: _userEmailKey),
//       _storage.delete(key: _userFirstNameKey),
//       _storage.delete(key: _userLastNameKey),
//       _storage.delete(key: _userPhoneKey),
//     ]);
//   }
// }
