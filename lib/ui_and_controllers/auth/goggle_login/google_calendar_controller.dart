import 'dart:developer';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:http/http.dart' as http;
import 'package:lead_management/core/utils/extension.dart';
import '../../../core/constant/app_color.dart';
import '../../../routes/route_manager.dart';

/// 🌟 Google Calendar Controller (Admin Only)
class GoogleCalendarController extends GetxController {
  bool isLoading = false;
  String errorMessage = '';
  GoogleSignInAccount? currentUser;
  CalendarApi? calendarApi;

  /// 🔐 Google Sign-In setup
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/userinfo.email',
    ],
  );

  /// 🔄 Silent login attempt
  Future<void> autoLogin() async {
    try {
      isLoading = true;
      update();

      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        currentUser = account;
        final authHeaders = await account.authHeaders;
        calendarApi = CalendarApi(_GoogleAuthClient(authHeaders));
        print('🔑 Admin silently logged in: ${account.email}');
      } else {
        print('⚠️ No previous login, user must login manually');
      }
    } catch (e) {
      print('💥 Auto-login failed: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  /// 👤 Admin Login
  Future<void> loginAdmin() async {
    try {
      isLoading = true;
      errorMessage = '';
      update();

      print('🔑 Attempting to sign in as admin...');
      final account = await _googleSignIn.signIn();
      if (account == null) {
        print('🚫 Login cancelled by user.');
        Get.context?.showAppSnackBar(
          message: "Login Cancelled', 'You cancelled the sign-in process",
          backgroundColor: colorRed,
          textColor: colorWhite,
        );
        return;
      }

      currentUser = account;
      final authHeaders = await account.authHeaders;
      calendarApi = CalendarApi(_GoogleAuthClient(authHeaders));

      print('✅ Admin signed in: ${account.email}');
      Get.context?.showAppSnackBar(
        message: "✅ Login Successful', 'Welcome, ${account.email}",
        backgroundColor: colorGreen,
        textColor: colorWhite,
      );
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      errorMessage = '❌ Login error: $e';
      Get.context?.showAppSnackBar(
        message: "Login Failed $errorMessage",
        backgroundColor: colorRed,
        textColor: colorWhite,
      );
      print(errorMessage);
    } finally {
      isLoading = false;
      update();
    }
  }

  /// 🚪 Admin Logout
  Future<void> logoutAdmin() async {
    try {
      print('🚪 Logging out admin...');
      await _googleSignIn.signOut();
      currentUser = null;
      calendarApi = null;
      errorMessage = '';
      Get.context?.showAppSnackBar(
        message: '👋 Logged Out, Admin successfully logged out',
        backgroundColor: colorGreen,
        textColor: colorWhite,
      );
      print('✅ Admin logged out successfully.');
      update();
    } catch (e) {
      errorMessage = '❌ Logout error: $e';
      Get.context?.showAppSnackBar(
        message: 'Logout Failed $errorMessage',
        backgroundColor: colorGreen,
        textColor: colorWhite,
      );
      print(errorMessage);
      update();
    }
  }

  Future<bool> addEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> employeeEmails,
  }) async {
    if (calendarApi == null) {
      Get.context?.showAppSnackBar(
        message: "⚠️ Not Logged In', 'Please login as Admin first",
        backgroundColor: colorGreen,
        textColor: colorWhite,
      );
      log('🚫 Attempted to add event without logging in.');
      update();
      return false;
    }

    try {
      isLoading = true;
      update();

      log('🧩 Preparing event...');
      log('📌 Title: $title');
      log('📝 Description: $description');
      log('⏰ Start Time: $startTime');
      log('⏰ End Time: $endTime');
      log('👥 Attendees: ${employeeEmails.join(', ')}');

      final attendees = employeeEmails.map((e) => EventAttendee(email: e)).toList();

      final event = Event(
        summary: title,
        description: description,
        start: EventDateTime(dateTime: startTime, timeZone: 'Asia/Kolkata'),
        end: EventDateTime(dateTime: endTime, timeZone: 'Asia/Kolkata'),
        attendees: attendees,
        reminders: EventReminders(
          useDefault: false,
          overrides: [
            EventReminder(method: 'popup', minutes: 1),
          ],
        ),
      );

      final inserted = await calendarApi!.events.insert(
        sendNotifications: true,
        event,
        'primary',
        sendUpdates: 'all',
      );

      if (inserted.id != null) {
        Get.context?.showAppSnackBar(
          message: "🎉 Event Added, Event $title added successfully",
          backgroundColor: colorRed,
          textColor: colorWhite,
        );
        log('✅ Event added successfully with ID: ${inserted.id}');

        for (var emp in employeeEmails) {
          log('📧 Invite sent to: $emp');
        }

        return true;
      } else {

        Get.context?.showAppSnackBar(
          message: "❌ Add Failed', 'Event could not be added",
          backgroundColor: colorRed,
          textColor: colorWhite,
        );
        log('⚠️ Failed to insert event.');
        return false;
      }
    } catch (e) {
      errorMessage = '💥 Add event error: $e';
      Get.context?.showAppSnackBar(
        message: "Error'$errorMessage",
        backgroundColor: colorRed,
        textColor: colorWhite,
      );
      log('💥 Error details: $errorMessage');
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  bool get isLoggedIn => currentUser != null && calendarApi != null;
  String? get adminEmail => currentUser?.email;
}

/// 🌐 Google Auth Client (for authorized HTTP requests)
class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    print('🌐 Sending request: ${request.url}');
    return _client.send(request);
  }

  @override
  void close() {
    print('🧹 Closing HTTP client...');
    _client.close();
  }
}
