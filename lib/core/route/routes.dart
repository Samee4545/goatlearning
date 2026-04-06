import 'package:get/get.dart';
import 'package:goatlearning/feature/admin/dashboard/components/admin_exercise_details.dart';

import 'package:goatlearning/feature/admin/edit/admin_complete_profile/view/admin_complete_profile_screen.dart';
import 'package:goatlearning/feature/admin/edit/admin_edit_chapter/chapter_info_upload/view/admin_chapter_info_upload_screen.dart';
import 'package:goatlearning/feature/admin/edit/view/admin_edit_screen.dart';
import 'package:goatlearning/feature/admin/profile/view/edit_profile.dart';
import 'package:goatlearning/feature/admin/setting/manage_admin/view/add_admin_screen.dart';
import 'package:goatlearning/feature/admin/setting/manage_admin/view/admin_list_screen.dart';
import 'package:goatlearning/feature/admin/setting/security/view/admin_security_screen.dart';
import 'package:goatlearning/feature/admin/setting/view/admin_setting_screen.dart';

import 'package:goatlearning/feature/admin/add_new/widget/add_theory.dart';

import 'package:goatlearning/feature/admin/admin_nav_bar/view/admin_nav_bar_screen.dart';

import 'package:goatlearning/feature/auth/forget_password/view/forget_password_screen.dart';
import 'package:goatlearning/feature/auth/forget_password/view/sent_email_screen.dart';

import 'package:goatlearning/feature/auth/login/view/login_screen.dart';
import 'package:goatlearning/feature/auth/register/view/register_screen.dart';
import 'package:goatlearning/feature/admin/add_new/widget/add_exercise.dart';
import 'package:goatlearning/feature/splash/splash_screen.dart';
import 'package:goatlearning/feature/user/onboarding/view/onboarding_screen.dart';
import 'package:goatlearning/feature/user/profile/complete_profile/view/complete_profile_screen.dart';
import 'package:goatlearning/feature/user/profile/view/profile_screen.dart';
import 'package:goatlearning/feature/user/setting/help/view/help_screen.dart';
import 'package:goatlearning/feature/user/setting/offline_mode/view/offline_mode_screen.dart';
import 'package:goatlearning/feature/user/setting/security/view/security_screen.dart';
import 'package:goatlearning/feature/user/setting/time_goatlearning/view/time_screen.dart';
import 'package:goatlearning/feature/user/setting/view/setting_screen.dart';
import 'package:goatlearning/feature/user/user_nav_bar/view/user_nav_bar_screen.dart';

class AppRoutes {
  static const String splash = '/splash';

  //admin
  static const String adminNavBar = '/adminNavBar';
  static const String addExercise = '/addExercise';
  static const String addTheory = '/addTheory';
  static const String sentEmail = '/sentEmail';
  //end of admin
  // auth start..
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgetPassword = '/forgetPassword';
  // auth end..

  // admin start..
  static const String adminEdit = '/adminEdit';
  static const String adminCompleteProfile = '/adminCompleteProfile';
  static const String adminEditChapter = '/adminEditChapter';
  static const String adminChapterInfoUpload = '/adminChapterInfoUpload';
  static const String adminSetting = '/adminSetting';
  static const String addAdmin = '/addAdmin';
  static const String adminSecurity = '/adminSecurity';
  static const String adminList = '/adminList';
  static const String adminEditProfile = '/adminEditProfile';
  static const String adminExercieDetails = '/adminExercieDetails';

  // admin end..

  // User start..
  static const String userNavBar = '/userNavBar';
  static const String userProfile = '/userProfile';
  static const String completeProfile = '/completeProfile';
  static const String setting = '/setting';
  static const String help = '/help';
  static const String security = '/security';
  static const String timeGoatlearning = '/timeGoatlearning';
  static const String offlineMode = '/offlineMode';
  // User end..
  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => SplashScreen(),
      transition: Transition.leftToRight,
    ),

    //admin
    GetPage(name: adminNavBar, page: () => AdminNavBarScreen()),
    GetPage(name: addExercise, page: () => AddExerciseScreen()),
    GetPage(name: addTheory, page: () => AddTheory()),
    GetPage(name: sentEmail, page: () => SentEmail()),
    //end of admin
    // auth start..
    GetPage(name: onboarding, page: () => OnboardingScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: register, page: () => RegisterScreen()),
    GetPage(name: forgetPassword, page: () => ForgetPasswordScreen()),
    // auth end..

    // admin start..
    GetPage(name: adminEdit, page: () => AdminEditScreen()),
    GetPage(
      name: adminCompleteProfile,
      page: () => AdminCompleteProfileScreen(),
    ),
    GetPage(
      name: adminChapterInfoUpload,
      page: () => AdminChapterInfoUploadScreen(),
    ),
    GetPage(name: adminSetting, page: () => AdminSettingScreen()),
    GetPage(name: addAdmin, page: () => AddAdminScreen()),
    GetPage(name: adminSecurity, page: () => AdminSecurityScreen()),
    GetPage(name: adminList, page: () => AdminListScreen()),
    GetPage(name: adminEditProfile, page: () => EditProfileScreen()),
    GetPage(name: adminExercieDetails, page: () => AdminExerciseDetails()),
    // admin end..

    // User start..
    GetPage(name: userNavBar, page: () => UserNavBarScreen()),
    GetPage(name: userProfile, page: () => ProfileScreen()),
    GetPage(name: completeProfile, page: () => CompleteProfileScreen()),
    GetPage(name: setting, page: () => SettingScreen()),
    GetPage(name: help, page: () => HelpScreen()),
    GetPage(name: security, page: () => SecurityScreen()),
    GetPage(name: timeGoatlearning, page: () => TimeScreen()),
    GetPage(name: offlineMode, page: () => OfflineModeScreen()),
    // User end..
  ];
}
