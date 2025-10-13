import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/ui_and_controllers/main/add_users/add_technician/add_technician_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_appbar.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_button.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_card.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_shimmer.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_textformfield.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';
import 'package:shimmer/shimmer.dart';

class AddTechnicianScreen extends StatelessWidget {
  const AddTechnicianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddTechnicianController());

    return Scaffold(
      backgroundColor: colorWhite,
      appBar: CustomAppBar(
        title: "Technician Types",
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorWhite),
            onPressed: () {
              controller.fetchTechnicianTypes();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: colorGrey.withValues(alpha: .3),
                highlightColor: colorGrey.withValues(alpha: .1),
                child: Container(
                  height: height * 0.15,
                  decoration: BoxDecoration(
                    color: colorWhite,
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),

              Expanded(
                child: ListView.builder(
                  itemCount: 5, // placeholder shimmer count
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: height * 0.015, right: width * 0.04, left: width * 0.04),
                      child: CustomShimmer(height: height * 0.08,)
                    );
                  },
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(width * 0.041),
              decoration: BoxDecoration(
                color: colorWhite,
                boxShadow: [
                  BoxShadow(
                    color: colorBoxShadow,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WantText(
                    text: 'Add New Technician Type',
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.w600,
                    textColor: colorBlack,
                  ),
                  SizedBox(height: height * 0.015),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          hintText: 'Enter technician type',
                          controller: controller.technicianController,
                          prefixIcon: Icon(Icons.engineering, color: colorGrey),
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      Obx(() => CustomButton(
                        Width: width * 0.25,
                        onTap: controller.isAdding ? null : controller.addTechnicianType,
                        label: controller.isAdding ? 'Adding...' : 'Add',
                        backgroundColor: colorMainTheme,
                        textColor: colorWhite,
                        fontSize: width * 0.035,
                        boarderRadius: 8,
                      )),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.02),
            // List Section
            Expanded(
              child: controller.technicianTypes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.engineering, size: 64, color: colorGrey),
                          SizedBox(height: 16),
                          WantText(
                            text: 'No technician types available',
                            fontSize: width * 0.041,
                            fontWeight: FontWeight.w500,
                            textColor: colorGrey,
                          ),
                          SizedBox(height: 8),
                          WantText(
                            text: 'Add a new technician type above',
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w400,
                            textColor: colorGrey,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: controller.technicianTypes.length,
                      itemBuilder: (context, index) {
                        final technicianType = controller.technicianTypes[index];
                        return CustomCard(
                          verticalPadding: height * 0.004,
                          child: ListTile(
                            minVerticalPadding: 0,
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: width * 0.05,
                              backgroundColor: colorMainTheme,
                              child: WantText(
                                text: '${index + 1}',
                                fontSize: width * 0.035,
                                fontWeight: FontWeight.w600,
                                textColor: colorWhite,
                              ),
                            ),
                            title: WantText(
                              text: technicianType,
                              fontSize: width * 0.035,
                              fontWeight: FontWeight.w500,
                              textColor: colorBlack,
                            ),
                            trailing: GestureDetector(
                              onTap: () => controller.showDeleteDialog(technicianType),
                              child: Icon(
                                Icons.delete,
                                color: colorRedCalendar,
                                size: width * 0.05,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}
