class Urls {
  static const String baseUrl = 'https://gotlearning-sigma.vercel.app/api/v1';
  //static const String baseUrl = 'http://10.0.20.20:5005/api/v1';

  static const String login = '$baseUrl/auth/login';
  static const String profile = '$baseUrl/auth/profile';
  static const String register = '$baseUrl/users/register';
  static const String changePassword = '$baseUrl/auth/change-password';
  static const String userUpdateProfile = '$baseUrl/users/profile';
  static const String getChapter = '$baseUrl/chapter';
  static const String addChapter = '$baseUrl/chapter';

  static String updatedChapterAndTheory(String id) => '$baseUrl/chapter/$id';

  static const String deleteChapter = '$baseUrl/chapter';
  static String removeChapterFromFolder(String id) =>
      '$baseUrl/chapter/out/$id';
  static const String getAdminList = '$baseUrl/users/get-admin-list';
  static const String addAdmin = '$baseUrl/users/make-admin';
  static const String deleteAdmin = '$baseUrl/users';
  static const String toggleFavourite = '$baseUrl/favorites/toggle';
  static const String addExercise = '$baseUrl/chapter';
  static const String adminParcentage = '$baseUrl/complete/admin';
  // Favorites: complete list (chapters + folders) for authenticated user
  static const String fetchFavourite = '$baseUrl/favorites/my-favorites/all';

  static const String resendOtp = '$baseUrl/auth/resend-otp';

  static const String helpSupport = '$baseUrl/users/send-support-mail';

  static const String userPercentage = '$baseUrl/complete';

  static const String editExercise = '$baseUrl/chapter/exercise';
  static const String uploadSingle = '$baseUrl/upload/single';
}
