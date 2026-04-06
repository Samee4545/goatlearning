// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';


// class CoustomDrower extends StatelessWidget {
//   const CoustomDrower({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var screenWidth = MediaQuery.of(context).size.width;
//     return Drawer(
//       backgroundColor: const Color(0xff5a5a5a),
//       width: screenWidth * .7,
//       child: Column(
//         children: [
//           Container(
//             height: 150,
//             padding: const EdgeInsets.all(10),
//             decoration: const BoxDecoration(
//               color: Color(0xff5a5a5a),
//               borderRadius: BorderRadius.only(
//                 bottomRight: Radius.circular(20),
//                 bottomLeft: Radius.circular(20),
//               ),
//             ),
//             child: DrawerHeader(
//               margin: EdgeInsets.zero,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   // ClipOval(
//                   //   child: CachedNetworkImage(
//                   //     imageUrl: controller.avatarUrl.value,
//                   //     height: 50,
//                   //     width: 50,
//                   //     placeholder: (context, url) =>
//                   //         const CircularProgressIndicator(),
//                   //     errorWidget: (context, url, error) =>
//                   //         const Icon(Icons.error),
//                   //   ),
//                   // ),
//                   const SizedBox(width: 5),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Obx(
//                           () => Text(
//                             controller.email.value,
//                             style: globalTextStyle(
//                               fontSize: 10,
//                               color: AppColors.whiteColor,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 1,
//                           ),
//                         ),
//                         Obx(
//                           () => Text(
//                             controller.userName.value,
//                             style: globalTextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: AppColors.whiteColor,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 1,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           ListTile(
//             leading: const Icon(
//               FontAwesomeIcons.calendarCheck,
//               color: AppColors.whiteColor,
//             ),
//             title: Text(
//               'Calendar',
//               style: globalTextStyle(color: AppColors.whiteColor),
//             ),
//             onTap: () {
//               Get.back();
//               Get.toNamed(AppRoute.calenderScreen);
//             },
//             trailing: const Icon(
//               Icons.arrow_forward_ios,
//               color: AppColors.whiteColor,
//               size: 15,
//             ),
//           ),
//           ListTile(
//             leading: const Icon(
//               FontAwesomeIcons.clock,
//               color: AppColors.whiteColor,
//             ),
//             title: Text(
//               'Schedules',
//               style: globalTextStyle(color: AppColors.whiteColor),
//             ),
//             onTap: () {
//               Get.back();
//               Get.toNamed(AppRoute.scheduleScreen);
//             },
//             trailing: const Icon(
//               Icons.arrow_forward_ios,
//               color: AppColors.whiteColor,
//               size: 15,
//             ),
//           ),
//           ListTile(
//             leading: const Icon(
//               FontAwesomeIcons.chartPie,
//               color: AppColors.whiteColor,
//             ),
//             title: Text(
//               'Statistics',
//               style: globalTextStyle(color: AppColors.whiteColor),
//             ),
//             onTap: () {
//               Get.back();
//               Get.toNamed("/statistics");
//             },
//             trailing: const Icon(
//               Icons.arrow_forward_ios,
//               color: AppColors.whiteColor,
//               size: 15,
//             ),
//           ),
//           const Spacer(),
//           ListTile(
//             leading: const Icon(
//               FontAwesomeIcons.user,
//               color: AppColors.whiteColor,
//             ),
//             title: Text(
//               'Profile',
//               style: globalTextStyle(color: AppColors.whiteColor),
//             ),
//             onTap: () {
//               Get.toNamed("/profile");
//             },
//             trailing: const Icon(
//               Icons.arrow_forward_ios,
//               color: AppColors.whiteColor,
//               size: 15,
//             ),
//           ),
//           ListTile(
//             leading: const Icon(
//               // ignore: deprecated_member_use
//               FontAwesomeIcons.signOut,
//               color: AppColors.whiteColor,
//             ),
//             title: Text(
//               'Logout',
//               style: globalTextStyle(color: AppColors.whiteColor),
//             ),
//             onTap: () async {
//               await SharedPreferencesHelper.clearAccessToken();
//               Get.offAllNamed(AppRoute.loginScreen);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
