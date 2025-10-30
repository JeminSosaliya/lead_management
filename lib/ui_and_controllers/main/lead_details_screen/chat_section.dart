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
                if (snapshot.connectionState == ConnectionState.waiting) {
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
                final docs = (snapshot.data as QuerySnapshot).docs;
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
                    try {
                      if (ts is Timestamp) {
                        timeText = DateFormat('hh:mm a').format(ts.toDate());
                      }
                    } catch (_) {}

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: width * 0.75,
                        ),
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
