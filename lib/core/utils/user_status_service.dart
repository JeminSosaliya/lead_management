import 'dart:async';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/routes/route_manager.dart';

class UserStatusService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<DocumentSnapshot>? _statusSubscription;
  final _isListening = false.obs;

  bool get isListening => _isListening.value;

  Future<void> startListening() async {
    final user = _auth.currentUser;

    if (user == null) {
      developer.log('❌ No user logged in. Cannot start status listener.');
      return;
    }

    if (_isListening.value) {
      developer.log('⚠️ User status listener already active.');
      return;
    }

    developer.log('👂 Starting user status listener for UID: ${user.uid}');

    _statusSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen(
          (DocumentSnapshot snapshot) async {
            if (!snapshot.exists) {
              developer.log('⚠️ User document does not exist');
              await _handleLogout(
                message: 'Your account has been removed. Please contact admin.',
              );
              return;
            }

            final data = snapshot.data() as Map<String, dynamic>?;

            if (data == null) {
              developer.log('⚠️ User data is null');
              return;
            }

            final isActive = data['isActive'] as bool? ?? true;

            developer.log('👤 User status check - isActive: $isActive');

            if (!isActive) {
              developer.log('🚫 User deactivated. Logging out...');
              await _handleLogout(
                message:
                    'Your account has been deactivated by admin. Please contact support.',
              );
            }
          },
          onError: (error) {
            developer.log('❌ Error listening to user status: $error');
          },
          cancelOnError: false,
        );

    _isListening.value = true;
    developer.log('✅ User status listener started successfully');
  }

  Future<void> _handleLogout({required String message}) async {
    try {
      await stopListening();
      await _auth.signOut();

      developer.log('✅ User logged out successfully');

      Get.context?.showAppSnackBar(
        message: message,
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );

      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      developer.log('❌ Error during logout: $e');
    }
  }

  Future<void> stopListening() async {
    if (_statusSubscription != null) {
      await _statusSubscription!.cancel();
      _statusSubscription = null;
      _isListening.value = false;
      developer.log('🛑 User status listener stopped');
    }
  }

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }
}
