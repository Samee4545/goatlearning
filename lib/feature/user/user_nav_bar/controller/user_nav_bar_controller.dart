import 'package:get/get.dart';
import 'package:goatlearning/feature/user/home/controller/home_controller.dart';

class UserNavBarController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
    // If navigating to dashboard/theory tab (index 0), refresh HomeController state
    if (index == 0 && Get.isRegistered<HomeController>()) {
      try {
        final homeController = Get.find<HomeController>();
        if (homeController != null) {
          // Clear search and refresh content if available
          if (homeController.hasLoadedContent is RxBool) {
            homeController.clearSearch();
            homeController.refreshAllContent(showLoader: false);
          }
        }
      } catch (_) {}
    }
  }
}
