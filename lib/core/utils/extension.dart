import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:intl/intl.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';


extension StringExtension on String {
  String get translateText {
    return this.tr();
  }

  String translateTextWithArgument(String args1) {
    return this.tr(
      args: [args1],
    );
  }

  bool get isEmailValid => RegExp(
      r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(this);

  String format({required String outputFormat, required String inputFormat}) {
    DateTime dateTime = DateTime.now();
    dateTime = DateFormat(inputFormat).parse(this);
    return DateFormat(outputFormat).format(dateTime);
  }
}

extension ContextExtension on BuildContext {
  void hideKeyboard() {
    return FocusScope.of(this).requestFocus(FocusNode());
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showAppSnackBar({
    required String message,
    Color? backgroundColor,
    Color? textColor,
  }) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        backgroundColor: backgroundColor ?? colorMainTheme,
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content:WantText(
        text: message,
        fontSize: 16,
        textColor: textColor ?? colorBlack,
        textAlign: TextAlign.start,
        fontWeight: FontWeight.w400,
      ),
      ),
    );
  }


  Future showAppDialog({
    Widget? titleWidget,
    required Widget contentWidget,
    List<Widget>? actionWidget,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          titlePadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          title: titleWidget ?? Container(),
          content: contentWidget,
          actions: actionWidget ?? [],
        );
      },
    );
  }

  Future showAppBottomSheet({required Widget contentWidget}) {
    return showModalBottomSheet(
      context: this,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return contentWidget;
      },
    );
  }
}

String formatNotificationDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final dateWithoutTime = DateTime(date.year, date.month, date.day);

  if (dateWithoutTime == today) {
    return "Today, ${DateFormat('hh:mm a').format(date)}";
  } else if (dateWithoutTime == yesterday) {
    return "Yesterday, ${DateFormat('hh:mm a').format(date)}";
  } else {
    return DateFormat('E, hh:mm a').format(date);
  }
}

String convertToISOWithOffset(String inputDate) {
  // Step 1: Parse from dd/MM/yyyy to DateTime
  DateTime date = DateFormat('dd/MM/yyyy').parse(inputDate);

  // Step 2: Add time manually (e.g., 14:30)
  date = DateTime(date.year, date.month, date.day, 14, 30); // 2:30 PM

  // Step 3: Get timezone offset
  final offset = date.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  final offsetStr = '$sign$hours:$minutes';

  // Step 4: Format as ISO 8601 manually (excluding milliseconds)
  final formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(date);

  return '$formattedDate$offsetStr';
}

String formatDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String formatWithFixedOffset(DateTime utcTime, Duration offset) {
  // Convert to local time of the offset
  final adjustedTime = utcTime.add(offset);

  final formattedDate = adjustedTime.toIso8601String().split('.').first;

  // Format offset
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');

  return '$formattedDate$sign$hours:$minutes';
}
// DateTime parsedDate = DateTime.parse(dateString);

class _CustomToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onDismiss;

  const _CustomToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.onDismiss,
  });

  @override
  State<_CustomToastWidget> createState() => _CustomToastWidgetState();
}

class _CustomToastWidgetState extends State<_CustomToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start from right side
      end: Offset.zero, // End at final position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 50,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Icon(
                      Icons.close,
                      color: widget.textColor,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
