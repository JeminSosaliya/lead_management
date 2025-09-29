// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:leaddemo/constant/app_color.dart';
// import 'package:leaddemo/constant/app_const.dart';
// import 'package:leaddemo/custom/custom_text.dart';
// import 'package:leaddemo/controllers/member_controller.dart';
// import 'package:leaddemo/member/member_detail_screen.dart';
//
// class MemberListScreen extends StatelessWidget {
//   const MemberListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(MemberController());
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const WantText(text: "Members"),
//         backgroundColor: colorMainTheme,
//         foregroundColor: colorWhite,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Get.back(),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: controller.loadMembers,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Dropdown for selecting type
//           Container(
//             width: double.infinity,
//             margin: EdgeInsets.all(width * 0.05),
//             padding: EdgeInsets.symmetric(horizontal: width * 0.04),
//             decoration: BoxDecoration(
//               border: Border.all(color: colorGreyTextFieldBorder),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: DropdownButtonHideUnderline(
//               child: Obx(() => DropdownButton<String>(
//                 value: controller.selectedType,
//                 isExpanded: true,
//                 items: [
//                   DropdownMenuItem(
//                     value: 'employee',
//                     child: WantText(
//                       text: "Employees",
//                       fontSize: width * 0.04,
//                       textColor: colorBlack,
//                     ),
//                   ),
//                   DropdownMenuItem(
//                     value: 'admin',
//                     child: WantText(
//                       text: "Admins",
//                       fontSize: width * 0.04,
//                       textColor: colorBlack,
//                     ),
//                   ),
//                 ],
//                 onChanged: (String? newValue) {
//                   if (newValue != null) {
//                     controller.setSelectedType(newValue);
//                     controller.loadMembers();
//                   }
//                 },
//               )),
//             ),
//           ),
//
//           // Member list
//           Expanded(
//             child: Obx(() {
//               if (controller.isLoading) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(colorMainTheme),
//                       ),
//                       SizedBox(height: height * 0.02),
//                       WantText(
//                         text: "Loading ${controller.selectedType}s...",
//                         fontSize: width * 0.04,
//                         textColor: colorGreyText,
//                       ),
//                     ],
//                   ),
//                 );
//               }
//
//               if (controller.currentList.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.people_outline,
//                         size: width * 0.2,
//                         color: colorGreyText,
//                       ),
//                       SizedBox(height: height * 0.02),
//                       WantText(
//                         text: "No ${controller.selectedType}s found",
//                         fontSize: width * 0.04,
//                         textColor: colorGreyText,
//                       ),
//                     ],
//                   ),
//                 );
//               }
//
//               return ListView.builder(
//                 padding: EdgeInsets.symmetric(horizontal: width * 0.05),
//                 itemCount: controller.currentList.length,
//                 itemBuilder: (context, index) {
//                   final member = controller.currentList[index];
//                   return _buildMemberCard(member, controller);
//                 },
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMemberCard(Map<String, dynamic> member, MemberController controller) {
//     return Container(
//       margin: EdgeInsets.only(bottom: height * 0.015),
//       padding: EdgeInsets.all(width * 0.04),
//       decoration: BoxDecoration(
//         color: colorWhite,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: EdgeInsets.zero,
//         leading: CircleAvatar(
//           radius: width * 0.06,
//           backgroundColor: member['isActive'] == true ? colorGreen : colorRedCalendar,
//           child: Icon(
//             Icons.person,
//             color: colorWhite,
//             size: width * 0.05,
//           ),
//         ),
//         title: WantText(
//           text: member['name'] ?? 'Unknown',
//           fontSize: width * 0.045,
//           fontWeight: FontWeight.bold,
//           textColor: colorBlack,
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: height * 0.005),
//             WantText(
//               text: member['email'] ?? 'No email',
//               fontSize: width * 0.035,
//               textColor: colorGreyText,
//             ),
//             SizedBox(height: height * 0.002),
//             WantText(
//               text: member['phone'] ?? 'No phone',
//               fontSize: width * 0.035,
//               textColor: colorGreyText,
//             ),
//             SizedBox(height: height * 0.005),
//             Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: width * 0.02,
//                     vertical: height * 0.005,
//                   ),
//                   decoration: BoxDecoration(
//                     color: member['isActive'] == true ? colorGreen : colorRedCalendar,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: WantText(
//                     text: member['isActive'] == true ? 'Active' : 'Inactive',
//                     fontSize: width * 0.03,
//                     fontWeight: FontWeight.bold,
//                     textColor: colorWhite,
//                   ),
//                 ),
//                 SizedBox(width: width * 0.02),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: width * 0.02,
//                     vertical: height * 0.005,
//                   ),
//                   decoration: BoxDecoration(
//                     color: member['type'] == 'admin' ? colorMainTheme : colorGreen,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: WantText(
//                     text: (member['type'] ?? 'unknown').toUpperCase(),
//                     fontSize: width * 0.03,
//                     fontWeight: FontWeight.bold,
//                     textColor: colorWhite,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         trailing: Icon(
//           Icons.arrow_forward_ios,
//           size: width * 0.04,
//           color: colorGreyText,
//         ),
//         onTap: () {
//           Get.to(() => MemberDetailScreen(member: member));
//         },
//       ),
//     );
//   }
// }