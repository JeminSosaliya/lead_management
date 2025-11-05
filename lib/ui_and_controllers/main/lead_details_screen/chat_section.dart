import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/ui_and_controllers/main/lead_details_screen/lead_details_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_card.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_textformfield.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class ChatSection extends StatelessWidget {
  final LeadDetailsController controller;

  const ChatSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool canChat = controller.canChat;
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WantText(
            text: 'Chat',
            fontSize: width * 0.041,
            fontWeight: FontWeight.w600,
            textColor: colorBlack,
          ),
          SizedBox(height: height * 0.008),
          Container(
            height: height * 0.35,
            decoration: BoxDecoration(
              color: colorWhite,
              border: Border.all(color: colorGreyTextFieldBorder, width: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: StreamBuilder(
              stream: controller.messageStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: colorMainTheme),
                  );
                }
                if (!snapshot.hasData) {
                  return Center(
                    child: WantText(
                      text: 'No messages yet',
                      fontSize: width * 0.031,
                      fontWeight: FontWeight.w400,
                      textColor: colorDarkGreyText,
                    ),
                  );
                }
                final qs = snapshot.data as QuerySnapshot<Map<String, dynamic>>;
                final docs = qs.docs;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (controller.chatScrollController.hasClients) {
                    controller.chatScrollController.jumpTo(
                      controller.chatScrollController.position.maxScrollExtent,
                    );
                  }
                });
                bool _isSameDay(DateTime a, DateTime b) {
                  return a.year == b.year &&
                      a.month == b.month &&
                      a.day == b.day;
                }

                String _friendlyDateLabel(DateTime date) {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final thatDay = DateTime(date.year, date.month, date.day);

                  if (_isSameDay(thatDay, today)) {
                    return 'Today';
                  }
                  if (_isSameDay(
                    thatDay,
                    today.subtract(const Duration(days: 1)),
                  )) {
                    return 'Yesterday';
                  }
                  if (thatDay.isAfter(
                    today.subtract(const Duration(days: 7)),
                  )) {
                    return DateFormat('EEEE').format(thatDay);
                  }
                  return DateFormat('d MMM y').format(thatDay);
                }

                return ListView.builder(
                  controller: controller.chatScrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.02,
                    vertical: height * 0.008,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == controller.currentUserId;
                    final message = (data['text'] ?? '').toString();
                    final sender = (data['senderName'] ?? '').toString();
                    final ts = data['createdAt'];
                    String timeText = '';
                    DateTime? msgDate;
                    try {
                      if (ts is Timestamp) {
                        msgDate = ts.toDate();
                        timeText = DateFormat('hh:mm a').format(msgDate);
                      }
                    } catch (_) {}

                    bool showHeader = false;
                    if (msgDate != null) {
                      if (index == 0) {
                        showHeader = true;
                      } else {
                        final prevData =
                            docs[index - 1].data() as Map<String, dynamic>;
                        final prevTs = prevData['createdAt'];
                        DateTime? prevDate;
                        if (prevTs is Timestamp) {
                          prevDate = prevTs.toDate();
                        }
                        showHeader =
                            prevDate == null || !_isSameDay(msgDate, prevDate);
                      }
                    }

                    Widget bubble = Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: width * 0.75),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            vertical: height * 0.004,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.03,
                            vertical: height * 0.008,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? colorMainTheme.withValues(alpha: .12)
                                : colorGreyTextFieldBorder.withOpacity(.5),
                            borderRadius: BorderRadius.only(
                              topLeft: isMe
                                  ? Radius.circular(10)
                                  : Radius.circular(0),
                              topRight: isMe
                                  ? Radius.circular(0)
                                  : Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: IntrinsicWidth(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  WantText(
                                    text: sender,
                                    fontSize: width * 0.027,
                                    fontWeight: FontWeight.w600,
                                    textColor: colorDarkGreyText,
                                  ),
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: width * 0.15,
                                        bottom: height * 0.0045,
                                      ),
                                      child: WantText(
                                        text: message,
                                        maxLines: null,
                                        fontWeight: FontWeight.w400,
                                        textColor: colorBlack,
                                        fontSize: width * 0.035,
                                      ),
                                    ),
                                    if (timeText.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: height * 0.006,
                                        ),
                                        child: WantText(
                                          text: timeText,
                                          fontSize: width * 0.027,
                                          textColor: colorDarkGreyText,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );

                    if (!showHeader) {
                      return bubble;
                    }

                    final label = _friendlyDateLabel(msgDate!);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: height * 0.004,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.03,
                              vertical: height * 0.004,
                            ),
                            decoration: BoxDecoration(
                              color: colorGreyTextFieldBorder.withOpacity(.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: WantText(
                              text: label,
                              fontSize: width * 0.029,
                              fontWeight: FontWeight.w600,
                              textColor: colorBlack,
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.012),

                        bubble,
                      ],
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: height * 0.008),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  hintText: canChat
                      ? 'Type a message'
                      : 'Chat not available for this user',
                  controller: controller.chatController,
                  enabled: canChat,
                  extraSpace: false,
                ),
              ),
              SizedBox(width: width * 0.02),
              IconButton(
                onPressed: (!canChat || controller.isSendingMessage)
                    ? null
                    : controller.sendMessage,
                icon: Icon(Icons.send, color: colorMainTheme),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
