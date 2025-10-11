import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/routes/route_manager.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_card.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class AnalyticsListScreen extends StatefulWidget {
  AnalyticsListScreen({super.key});

  @override
  State<AnalyticsListScreen> createState() => _AnalyticsListScreenState();
}

class _AnalyticsListScreenState extends State<AnalyticsListScreen> {
  final leadTitle = Get.arguments[0];
  final newList = Get.arguments[1];
  
  @override
  void initState() {
    super.initState();
    debugPrint('newList: $newList');
    debugPrint('newList length:: ${newList.length}');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      appBar: AppBar(
        title: WantText(
          text: '$leadTitle List',
          fontSize: width * 0.061,
          fontWeight: FontWeight.w600,
          textColor: colorWhite,
        ),
        backgroundColor: colorMainTheme,
        iconTheme: IconThemeData(color: colorWhite),
      ),
      body: ListView.builder(
        itemCount: newList.length,
        itemBuilder: (context, index) {
          final lead = newList[index];
          return GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.leadDetailsScreen,arguments: [
                lead.leadId,
                lead]
              );
            },
            child: CustomCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: colorMainTheme,
                    radius: 22,
                    child: WantText(
                      text: lead.clientName[0].toUpperCase(),
                      fontSize: width * 0.046,
                      fontWeight: FontWeight.w600,
                      textColor: colorWhite,
                    ),
                  ),
                  SizedBox(width: width * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WantText(
                          text: lead.clientName,
                          fontSize: width * 0.041,
                          fontWeight: FontWeight.w600,
                          textColor: colorBlack,
                        ),
                        SizedBox(height: height * 0.005),
                        WantText(
                          text: 'Assigned To: ${lead.assignedToName}',
                          fontSize: width * 0.038,
                          fontWeight: FontWeight.w600,
                          textColor: colorDarkGreyText,
                        ),
                        SizedBox(height: height * 0.005),
                        WantText(
                          text: 'Added By: ${lead.addedByName}',
                          fontSize: width * 0.038,
                          fontWeight: FontWeight.w600,
                          textColor: colorDarkGreyText,
                        ),
                        SizedBox(height: height * 0.005),
                        WantText(
                          text: '📞 ${lead.clientPhone}',
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.w400,
                          textColor: colorDarkGreyText,
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


}



