import 'dart:developer';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:http/http.dart' as http;
import 'package:lead_management/core/utils/extension.dart';
import '../../../core/constant/app_color.dart';
import '../../../routes/route_manager.dart';

class GoogleCalendarController extends GetxController {
  bool isLoading = false;
  String errorMessage = '';
  GoogleSignInAccount? currentUser;
  CalendarApi? calendarApi;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/userinfo.email',
    ],
  );

  Future<bool> autoLogin() async {
    try {
      isLoading = true;
      update();
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        currentUser = account;
        final authHeaders = await account.authHeaders;
        calendarApi = CalendarApi(_GoogleAuthClient(authHeaders));
        log('🔑 Admin silently logged in: ${account.email}');
        return true;
      } else {
        // Get.offAllNamed(AppRoutes.adminLogin);
        log('⚠️ No previous login, user must login manually');
        return false;
      }
    } catch (e) {
      // Get.offAllNamed(AppRoutes.adminLogin);

      log('💥 Auto-login failed: $e');
      return false;

    } finally {
      isLoading = false;

      update();
      return false;

    }
  }

  Future<void> loginAdmin() async {
    try {
      isLoading = true;
      errorMessage = '';
      update();

      final account = await _googleSignIn.signIn();
      if (account == null) {
        Get.context?.showAppSnackBar(
          message: "Login Cancelled",
          backgroundColor: colorRed,
          textColor: colorWhite,
        );
        return;
      }

      currentUser = account;
      final authHeaders = await account.authHeaders;
      calendarApi = CalendarApi(_GoogleAuthClient(authHeaders));

      Get.context?.showAppSnackBar(
        message: "✅ Login Successful: ${account.email}",
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
      log(errorMessage);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> logoutAdmin() async {
    try {
      await _googleSignIn.signOut();
      currentUser = null;
      calendarApi = null;
      errorMessage = '';
      Get.context?.showAppSnackBar(
        message: '👋 Logged Out Successfully',
        backgroundColor: colorGreen,
        textColor: colorWhite,
      );
      update();
    } catch (e) {
      errorMessage = '❌ Logout error: $e';
      Get.context?.showAppSnackBar(
        message: 'Logout Failed $errorMessage',
        backgroundColor: colorRed,
        textColor: colorWhite,
      );
      update();
    }
  }

  /// 🔑 Handle re-login if token expired
  Future<void> handleGoogleReLogin() async {
    Get.context?.showAppSnackBar(
      message: "⚠️ Google token expired. Please login again.",
      backgroundColor: colorRed,
      textColor: colorWhite,
    );
    await logoutAdmin();
    await loginAdmin();
  }

  Future<String?> addEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> employeeEmails,
  }) async {
    if (calendarApi == null) {
      Get.context?.showAppSnackBar(
        message: "⚠️ Not Logged In, Please login as Admin first",
        backgroundColor: colorRed,
        textColor: colorWhite,
      );
      return null;
    }

    try {
      isLoading = true;
      update();

      final attendees =
      employeeEmails.map((e) => EventAttendee(email: e)).toList();
      final event = Event(
        summary: title,
        description: description,
        start: EventDateTime(dateTime: startTime, timeZone: 'Asia/Kolkata'),
        end: EventDateTime(dateTime: endTime, timeZone: 'Asia/Kolkata'),
        attendees: attendees,
        reminders: EventReminders(
          useDefault: false,
          overrides: [EventReminder(method: 'popup', minutes: 5)],
        ),
      );

      final inserted = await _tryInsertEvent(event);
      if (inserted != null) return inserted.id;
      return null;
    } catch (e) {
      log('💥 Add event failed: $e');
      return null;
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<bool> deleteEvent(String eventId) async {
    if (calendarApi == null) {
      Get.context?.showAppSnackBar(
        message: "⚠️ Not logged in. Please login as Admin first",
        backgroundColor: colorRed,
        textColor: colorWhite,
      );
      return false;
    }

    try {
      isLoading = true;
      update();

      log('🗑️ Deleting event: $eventId');

      await calendarApi!.events.delete(
        'primary',    // your calendar ID
        eventId,      // ID of the event to delete
        sendUpdates: 'all', // notify all attendees via email
      );

      Get.context?.showAppSnackBar(
        message: '✅ Event deleted successfully',
        backgroundColor: colorGreen,
        textColor: colorWhite,
      );
      log('✅ Event deleted successfully: $eventId');
      return true;
    } catch (e) {
      log('💥 Delete event error: $e');

      if (e is DetailedApiRequestError && e.status == 401) {
        log('⚠️ Token expired or invalid. Need to re-login.');
        await handleGoogleReLogin(); // call your re-login flow
      } else if (e is DetailedApiRequestError && e.status == 404) {
        Get.context?.showAppSnackBar(
          message: '❌ Event not found (maybe already deleted)',
          backgroundColor: colorRed,
          textColor: colorWhite,
        );
      } else {
        Get.context?.showAppSnackBar(
          message: '❌ Failed to delete event: $e',
          backgroundColor: colorRed,
          textColor: colorWhite,
        );
      }

      return false;
    } finally {
      isLoading = false;
      update();
    }
  }


  Future<Event?> _tryInsertEvent(Event event) async {
    try {
      return await calendarApi!.events.insert(
        sendNotifications: true,
        event,
        'primary',
        sendUpdates: 'all',
      );
    } catch (e) {
      if (e.toString().contains('401')) {
        log("⚠️ Token expired, re-login needed");
        await handleGoogleReLogin();
        return await calendarApi!.events.insert(
          sendNotifications: true,
          event,
          'primary',
          sendUpdates: 'all',
        );
      }
      rethrow;
    }
  }

  Future<String?> updateOrCreateEvent({
    required String? eventId, // nullable, in case event does not exist
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> oldEmployeeEmails,
    required List<String> newEmployeeEmails,
  }) async {
    if (calendarApi == null) {
      log('⚠️ Not logged in to Google Calendar');
      Get.context?.showAppSnackBar(
        message: "⚠️ Not logged in. Please login as Admin.",
        backgroundColor: colorRed,
        textColor: colorWhite,
      );
      return null;
    }

    Event event = Event(
      summary: title,
      description: description,
      start: EventDateTime(dateTime: startTime, timeZone: 'Asia/Kolkata'),
      end: EventDateTime(dateTime: endTime, timeZone: 'Asia/Kolkata'),
      attendees: newEmployeeEmails.map((e) => EventAttendee(email: e)).toList(),
      reminders: EventReminders(
        useDefault: false,
        overrides: [EventReminder(method: 'popup', minutes: 5)],
      ),
    );

    try {
      Event updatedEvent;

      if (eventId != null && eventId.isNotEmpty) {
        try {
          // Try to fetch the existing event
          final existingEvent = await calendarApi!.events.get('primary', eventId);

          // Update event details
          existingEvent.summary = title;
          existingEvent.description = description;
          existingEvent.start = EventDateTime(dateTime: startTime, timeZone: 'Asia/Kolkata');
          existingEvent.end = EventDateTime(dateTime: endTime, timeZone: 'Asia/Kolkata');
          existingEvent.attendees = newEmployeeEmails.map((e) => EventAttendee(email: e)).toList();
          existingEvent.reminders = EventReminders(
            useDefault: false,
            overrides: [EventReminder(method: 'popup', minutes: 5)],
          );

          updatedEvent = await calendarApi!.events.update(
            existingEvent,
            'primary',
            eventId,
            sendUpdates: 'all',
          );

          log('✅ Event updated successfully: ${updatedEvent.id}');
          return updatedEvent.id;
        } catch (e) {
          if (e is DetailedApiRequestError && e.status == 404) {
            log('⚠️ Event not found, will create a new one');
            eventId = null; // Force creation below
          } else if (e.toString().contains('401')) {
            log("⚠️ Token expired, re-login needed");
            await handleGoogleReLogin();
            return await updateOrCreateEvent(
              eventId: eventId,
              title: title,
              description: description,
              startTime: startTime,
              endTime: endTime,
              oldEmployeeEmails: oldEmployeeEmails,
              newEmployeeEmails: newEmployeeEmails,
            );
          } else {
            rethrow;
          }
        }
      }

      updatedEvent = await calendarApi!.events.insert(event, 'primary', sendUpdates: 'all');
      log('🆕 Event created successfully: ${updatedEvent.id}');
      return updatedEvent.id;
    } catch (e) {
      log('💥 Failed to update/create event: $e');
      Get.context?.showAppSnackBar(
        message: '💥 Failed to update/create event',
        backgroundColor: colorRed,
        textColor: colorWhite,
      );
      return null;
    }
  }


  Future<Event> _tryUpdateEvent(Event event, String eventId) async {
    try {
      return await calendarApi!.events.update(
        event,
        'primary',
        eventId,
        sendUpdates: 'all',
      );
    } catch (e) {
      if (e.toString().contains('401')) {
        log("⚠️ Token expired, re-login needed");
        await handleGoogleReLogin();
        return await calendarApi!.events.update(
          event,
          'primary',
          eventId,
          sendUpdates: 'all',
        );
      }
      rethrow;
    }
  }

  bool get isLoggedIn => currentUser != null && calendarApi != null;
  String? get adminEmail => currentUser?.email;
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  @override
  void close() => _client.close();
}
