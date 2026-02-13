import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/custom_toast.dart';

class AppHelpers {
  // Show loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Show error toast
  static void showErrorToast(
    BuildContext context, {
    required String message,
    String? title,
  }) {
    ToastUtils.show(
      context: context,
      title: title ?? 'common.error'.tr(),
      message: message,
      type: ToastType.error,
    );
  }

  // Show success toast
  static void showSuccessToast(
    BuildContext context, {
    required String message,
    String? title,
  }) {
    ToastUtils.show(
      context: context,
      title: title ?? 'common.success'.tr(),
      message: message,
      type: ToastType.success,
    );
  }

  // Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    showErrorToast(context, message: message);
  }

  // Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSuccessToast(context, message: message);
  }

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  // Format date
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Format time
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Get device type
  static String getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 'mobile';
    } else if (width < 1200) {
      return 'tablet';
    } else {
      return 'desktop';
    }
  }
}
