import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/routes/route_manager.dart';
import 'package:lead_management/ui_and_controllers/main/analytics/analytics_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_appbar.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_card.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_shimmer.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';
import 'package:shimmer/shimmer.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnalyticsController());

    return Scaffold(
      backgroundColor: colorWhite,
      appBar: CustomAppBar(
        title: 'Analytics',
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorWhite),
            onPressed: () {
              controller.loadEmployees();
              controller.loadTechnicians();
              controller.loadAnalytics();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Padding(
            padding: EdgeInsets.all(width * 0.041),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomShimmer(height: height * 0.28),
                SizedBox(height: height * 0.03),
                CustomShimmer(height: height * 0.12),
                SizedBox(height: height * 0.03),
                CustomShimmer(height: height * 0.35),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(width * 0.041),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorMainTheme.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: colorBoxShadow,
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: colorMainTheme,
                          size: width * 0.06,
                        ),
                        SizedBox(width: width * 0.03),
                        WantText(
                          text: 'Filter Analytics',
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.bold,
                          textColor: colorBlack,
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),

                    // Employee Filter Dropdown
                    _buildDropdown(
                      'Employee',
                      controller.selectedEmployeeId.value,
                      'Filter by Employee',
                      controller.employees,
                      (value) {
                        if (value == null) {
                          controller.selectEmployee(null, null);
                        } else {
                          final employee = controller.employees.firstWhere(
                            (e) => e['id'] == value,
                          );
                          controller.selectEmployee(value, employee['name']);
                        }
                      },
                    ),

                    SizedBox(height: height * 0.015),

                    // Technician Filter Dropdown
                    _buildDropdown(
                      'Technician',
                      controller.selectedTechnicianId.value,
                      'Filter by Technician',
                      controller.technicians,
                      (value) {
                        if (value == null) {
                          controller.selectTechnician(null, null);
                        } else {
                          final technician = controller.technicians.firstWhere(
                            (t) => t['id'] == value,
                          );
                          controller.selectTechnician(
                            value,
                            technician['name'],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.025),

              // Active Filters Info
              if (controller.selectedEmployeeId.value != null ||
                  controller.selectedTechnicianId.value != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(width * 0.03),
                  decoration: BoxDecoration(
                    color: colorMainTheme.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorMainTheme.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: colorMainTheme,
                        size: width * 0.06,
                      ),
                      SizedBox(width: width * 0.03),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WantText(
                              text: 'Active Filters',
                              fontSize: width * 0.041,
                              textColor: colorBlack,
                              fontWeight: FontWeight.w500,
                            ),
                            WantText(
                              text: controller.filterDescription,
                              fontSize: width * 0.035,
                              fontWeight: FontWeight.w500,
                              textColor: colorDarkGreyText,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.clear, color: colorRedCalendar),
                        onPressed: () => controller.clearFilters(),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),

              if (controller.selectedEmployeeId.value != null ||
                  controller.selectedTechnicianId.value != null)
                SizedBox(height: height * 0.025),

              // Total Leads Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(width * 0.05),
                decoration: BoxDecoration(
                  color: colorMainTheme,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorBoxShadow,
                      blurRadius: 7,
                      offset: Offset(4, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    WantText(
                      text:
                          (controller.selectedEmployeeId.value != null ||
                              controller.selectedTechnicianId.value != null)
                          ? 'Filtered Leads'
                          : 'Total Leads',
                      fontSize: width * 0.041,
                      fontWeight: FontWeight.w500,
                      textColor: colorWhite,
                    ),
                    SizedBox(height: height * 0.01),
                    WantText(
                      text: '${controller.totalLeads}',
                      fontSize: width * 0.06,
                      fontWeight: FontWeight.bold,
                      textColor: colorWhite,
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.03),
              if (controller.totalLeads == 0)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 64,
                        color: colorGreyText,
                      ),
                      SizedBox(height: 16),
                      WantText(
                        text:
                            (controller.selectedEmployeeId.value != null ||
                                controller.selectedTechnicianId.value != null)
                            ? 'No leads match the selected filters'
                            : 'No data available',
                        fontSize: width * 0.041,
                        fontWeight: FontWeight.w500,
                        textColor: colorGreyText,
                      ),
                      SizedBox(height: 8),
                      WantText(
                        text: 'Try adjusting your filters or add some leads',
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w400,
                        textColor: colorGreyText,
                      ),
                    ],
                  ),
                ),

              // Pie Chart Section
              if (controller.totalLeads != 0)
                Column(
                  children: [
                    CustomCard(
                      leftMargin: 0,
                      rightMargin: 0,
                      child: Column(
                        children: [
                          WantText(
                            text: 'Lead Status Distribution',
                            fontSize: width * 0.041,
                            fontWeight: FontWeight.bold,
                            textColor: colorBlack,
                          ),
                          SizedBox(height: height * 0.03),

                          // Pie Chart
                          SizedBox(
                            height: height * 0.35,
                            child: PieChart(
                              PieChartData(
                                sections: _getPieChartSections(controller),
                                sectionsSpace: 3,
                                centerSpaceRadius: 60,
                                borderData: FlBorderData(show: false),
                                pieTouchData: PieTouchData(
                                  touchCallback:
                                      (FlTouchEvent event, pieTouchResponse) {},
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: height * 0.03),

                          // Legend
                          _buildLegend(controller),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.03),

                    // Stats Cards
                    _buildStatsCard(
                      'New Leads',
                      controller.newCount.value,
                      controller.getPercentage(controller.newCount.value),
                      colorBlue,
                      () {
                        debugPrint('new leads :: ${controller.newCount.value}');
                        debugPrint(
                          'new leads ::>> ${controller.newList.value}',
                        );
                        Get.toNamed(
                          AppRoutes.analyticsListScreen,
                          arguments: ['new', controller.newList.value],
                        );
                      },
                    ),
                    SizedBox(height: height * 0.015),
                    _buildStatsCard(
                      'In Progress',
                      controller.inProgressCount.value,
                      controller.getPercentage(
                        controller.inProgressCount.value,
                      ),
                      colorOrange,
                      () {
                        Get.toNamed(
                          AppRoutes.analyticsListScreen,
                          arguments: [
                            'In Progress',
                            controller.inProgressList.value,
                          ],
                        );
                      },
                    ),
                    SizedBox(height: height * 0.015),
                    _buildStatsCard(
                      'Completed',
                      controller.completedCount.value,
                      controller.getPercentage(controller.completedCount.value),
                      colorGreenOne,
                      () {
                        Get.toNamed(
                          AppRoutes.analyticsListScreen,
                          arguments: [
                            'Completed',
                            controller.completedList.value,
                          ],
                        );
                      },
                    ),
                    SizedBox(height: height * 0.015),
                    _buildStatsCard(
                      'Cancelled',
                      controller.cancelledCount.value,
                      controller.getPercentage(controller.cancelledCount.value),
                      colorRedCalendar,
                      () {
                        Get.toNamed(
                          AppRoutes.analyticsListScreen,
                          arguments: [
                            'Cancelled',
                            controller.cancelledList.value,
                          ],
                        );
                      },
                    ),
                    SizedBox(height: height * 0.048),

                  ],
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDropdown(
    String title,
    String? selectedValue,
    String hintText,
    List<Map<String, dynamic>> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WantText(
          text: title,
          fontSize: width * 0.035,
          fontWeight: FontWeight.w600,
          textColor: colorBlack,
        ),
        SizedBox(height: height * 0.005),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.03,
            vertical: height * 0.008,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: colorGreyTextFieldBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedValue,
            hint: WantText(
              text: hintText,
              fontSize: width * 0.035,
              textColor: colorGreyText,
            ),
            underline: SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: colorMainTheme),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: WantText(
                  text: 'All $title' + (title == 'Employee' ? 's' : 's'),
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.w600,
                  textColor: colorMainTheme,
                ),
              ),
              ...items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['id'],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WantText(
                        text: item['name'],
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w500,
                        textColor: colorBlack,
                      ),
                      if (item['email'] != null && item['email'].isNotEmpty)
                        WantText(
                          text: item['email'],
                          fontSize: width * 0.031,
                          textColor: colorDarkGreyText,
                        ),
                    ],
                  ),
                );
              }).toList(),
            ],
            onChanged: onChanged,
          ),
        ),

      ],
    );
  }

  List<PieChartSectionData> _getPieChartSections(
    AnalyticsController controller,
  ) {
    List<PieChartSectionData> sections = [];

    if (controller.newCount.value > 0) {
      sections.add(
        PieChartSectionData(
          color: colorBlue,
          value: controller.newCount.value.toDouble(),
          title:
              '${controller.getPercentage(controller.newCount.value).toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: TextStyle(
            fontSize: width * 0.035,
            fontWeight: FontWeight.bold,
            color: colorWhite,
          ),
        ),
      );
    }

    if (controller.inProgressCount.value > 0) {
      sections.add(
        PieChartSectionData(
          color: colorOrange,
          value: controller.inProgressCount.value.toDouble(),
          title:
              '${controller.getPercentage(controller.inProgressCount.value).toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: TextStyle(
            fontSize: width * 0.035,
            fontWeight: FontWeight.bold,
            color: colorWhite,
          ),
        ),
      );
    }

    if (controller.completedCount.value > 0) {
      sections.add(
        PieChartSectionData(
          color: colorGreenOne,
          value: controller.completedCount.value.toDouble(),
          title:
              '${controller.getPercentage(controller.completedCount.value).toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: TextStyle(
            fontSize: width * 0.035,
            fontWeight: FontWeight.bold,
            color: colorWhite,
          ),
        ),
      );
    }

    if (controller.cancelledCount.value > 0) {
      sections.add(
        PieChartSectionData(
          color: colorRedCalendar,
          value: controller.cancelledCount.value.toDouble(),
          title:
              '${controller.getPercentage(controller.cancelledCount.value).toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: TextStyle(
            fontSize: width * 0.035,
            fontWeight: FontWeight.bold,
            color: colorWhite,
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildLegend(AnalyticsController controller) {
    return Column(
      children: [
        if (controller.newCount.value > 0) _buildLegendItem('New', colorBlue),
        if (controller.inProgressCount.value > 0)
          _buildLegendItem('In Progress', colorOrange),
        if (controller.completedCount.value > 0)
          _buildLegendItem('Completed', colorGreenOne),
        if (controller.cancelledCount.value > 0)
          _buildLegendItem('Cancelled', colorRedCalendar),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.005),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: width * 0.04,
            height: width * 0.04,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: width * 0.02),
          WantText(
            text: label,
            fontSize: width * 0.035,
            fontWeight: FontWeight.w500,
            textColor: colorBlack,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    String title,
    int count,
    double percentage,
    Color color,
    void Function()? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(width * 0.04),
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: colorBoxShadow,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(width * 0.02),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.pie_chart, color: color, size: width * 0.07),
            ),
            SizedBox(width: width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WantText(
                    text: title,
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w500,
                    textColor: colorBlack,
                  ),
                  SizedBox(height: height * 0.003),
                  WantText(
                    text: '$count leads (${percentage.toStringAsFixed(1)}%)',
                    fontSize: width * 0.031,
                    fontWeight: FontWeight.w400,
                    textColor: colorDarkGreyText,
                  ),
                ],
              ),
            ),
            WantText(
              text: '$count',
              fontSize: width * 0.05,
              fontWeight: FontWeight.bold,
              textColor: color,
            ),
          ],
        ),
      ),
    );
  }
}
