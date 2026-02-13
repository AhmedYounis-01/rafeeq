import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import 'echo_print.dart';

class LaunchHelper {
  /// Open email client to send email
  static Future<void> sendEmail(String email) async {
    try {
      EchoPrint.info('[LaunchHelper] Attempting to send email to: $email');

      final Uri emailLaunchUri = Uri(scheme: 'mailto', path: email);

      EchoPrint.debug('[LaunchHelper] Email URI: $emailLaunchUri');

      // Check if we can launch the email client first
      final canLaunch = await canLaunchUrl(emailLaunchUri);
      EchoPrint.debug('[LaunchHelper] Can launch email: $canLaunch');

      if (canLaunch) {
        await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
        EchoPrint.success('[LaunchHelper] Email client opened successfully');
      } else {
        EchoPrint.error('[LaunchHelper] No email client available');
        throw 'No email client found on this device.\n\n'
            'Please install an email app (Gmail, Outlook, etc.) to send emails.';
      }
    } catch (e) {
      EchoPrint.error('[LaunchHelper] Error opening email', error: e);

      // Provide user-friendly error message
      final errorStr = e.toString();
      if (errorStr.contains('ACTIVITY_NOT_FOUND') ||
          errorStr.contains('No email client')) {
        throw 'No email client found on this device.\n\n'
            'Please install an email app (Gmail, Outlook, etc.) to send emails.';
      }

      rethrow;
    }
  }

  /// Open WhatsApp to message the customer
  static Future<void> openWhatsApp(String phoneNumber) async {
    try {
      EchoPrint.info(
        '[LaunchHelper] Attempting to open WhatsApp for: $phoneNumber',
      );
      EchoPrint.debug('[LaunchHelper] Platform: ${Platform.operatingSystem}');

      // Remove all non-digit characters from phone number except +
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      EchoPrint.debug('[LaunchHelper] Clean phone: $cleanPhone');

      // Ensure phone number starts with + for international format
      final formattedPhone = cleanPhone.startsWith('+')
          ? cleanPhone
          : '+$cleanPhone';

      EchoPrint.debug('[LaunchHelper] Formatted phone: $formattedPhone');

      // Try opening WhatsApp app directly based on platform
      if (Platform.isAndroid) {
        EchoPrint.debug(
          '[LaunchHelper] Platform is Android, trying app scheme first',
        );

        // Android: Try to open WhatsApp app with phone scheme
        final whatsappAppUri = Uri.parse(
          'whatsapp://send?phone=$formattedPhone',
        );

        EchoPrint.debug('[LaunchHelper] WhatsApp Android URI: $whatsappAppUri');

        try {
          await launchUrl(whatsappAppUri, mode: LaunchMode.externalApplication);
          EchoPrint.success(
            '[LaunchHelper] WhatsApp app opened successfully on Android',
          );
          return;
        } catch (e) {
          EchoPrint.warn(
            '[LaunchHelper] WhatsApp app scheme failed: $e, trying web',
          );
        }
      } else if (Platform.isIOS) {
        EchoPrint.debug('[LaunchHelper] Platform is iOS, trying web link');

        final iosUri = Uri.parse('https://wa.me/$formattedPhone');
        EchoPrint.debug('[LaunchHelper] WhatsApp iOS URI: $iosUri');

        try {
          await launchUrl(iosUri, mode: LaunchMode.externalApplication);
          EchoPrint.success(
            '[LaunchHelper] WhatsApp opened successfully on iOS',
          );
          return;
        } catch (e) {
          EchoPrint.warn('[LaunchHelper] WhatsApp iOS URI failed: $e');
        }
      }

      // Fallback: Open in browser
      final webUri = Uri.parse('https://wa.me/$formattedPhone?text=Hello');
      EchoPrint.debug('[LaunchHelper] Trying web fallback: $webUri');

      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        EchoPrint.success('[LaunchHelper] WhatsApp web opened successfully');
      } catch (e) {
        EchoPrint.error('[LaunchHelper] Failed to launch web', error: e);

        // Check error type
        final errorStr = e.toString();
        if (errorStr.contains('ACTIVITY_NOT_FOUND')) {
          EchoPrint.info(
            '[LaunchHelper] No browser or WhatsApp found on this device',
          );
          throw 'Could not open WhatsApp.\n\n'
              'Please install WhatsApp app or ensure a web browser is available.';
        }

        EchoPrint.error('[LaunchHelper] Cannot launch any WhatsApp method');
        throw 'WhatsApp is not installed and web cannot be opened. Error: $e';
      }
    } catch (e) {
      EchoPrint.error('[LaunchHelper] Error opening WhatsApp', error: e);
      rethrow;
    }
  }

  /// Open phone dialer to call the customer
  static Future<void> callPhone(String phoneNumber) async {
    try {
      EchoPrint.info('[LaunchHelper] Attempting to call: $phoneNumber');
      EchoPrint.debug('[LaunchHelper] Platform: ${Platform.operatingSystem}');

      final Uri phoneLaunchUri = Uri(scheme: 'tel', path: phoneNumber);

      EchoPrint.debug('[LaunchHelper] Phone URI: $phoneLaunchUri');

      // Try to launch directly without checking
      try {
        await launchUrl(phoneLaunchUri);
        EchoPrint.success('[LaunchHelper] Phone dialer opened successfully');
      } catch (e) {
        EchoPrint.error('[LaunchHelper] Failed to launch phone', error: e);

        // Check error type and provide helpful message
        final errorStr = e.toString();
        if (errorStr.contains('ACTIVITY_NOT_FOUND')) {
          EchoPrint.info(
            '[LaunchHelper] Phone dialer not available on this device',
          );
          throw 'Phone calling is not available on this device.\n\n'
              'This device may not have telephony capability.';
        }

        // Fallback: Check if we can launch first
        final canLaunch = await canLaunchUrl(phoneLaunchUri);
        EchoPrint.debug(
          '[LaunchHelper] Can launch phone (fallback check): $canLaunch',
        );

        if (canLaunch) {
          await launchUrl(phoneLaunchUri);
          EchoPrint.success(
            '[LaunchHelper] Phone dialer opened successfully (fallback)',
          );
        } else {
          throw 'Could not launch phone dialer. Device may not have phone capability.';
        }
      }
    } catch (e) {
      EchoPrint.error('[LaunchHelper] Error opening phone', error: e);
      rethrow;
    }
  }
}
