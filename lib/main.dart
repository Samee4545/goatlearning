import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/const/translation_service.dart';
import 'package:goatlearning/core/route/routes.dart';
import 'package:goatlearning/core/services_class/billing/billing_manager.dart';
import 'package:goatlearning/core/services_class/user_bootstrap_service.dart';
import 'package:goatlearning/main_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final savedLocale = await TranslationService.loadLocale();

  runApp(MyApp(savedLocale: savedLocale));
}

class MyApp extends StatefulWidget {
  final Locale savedLocale;
  const MyApp({super.key, required this.savedLocale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final UsageController usageController = Get.put(UsageController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize billing after the app is built so EasyLoading is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BillingManager.instance.init();
        // Ensure a local userId is generated and registered server-side on first run.
        UserBootstrapService.instance.ensureUserRegistered();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BillingManager.instance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      usageController.saveUsageTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context);
    return GetMaterialApp(
      title: 'GoatLearning',
      debugShowCheckedModeBanner: false,
      translations: TranslationService(),
      locale: widget.savedLocale,
      fallbackLocale: TranslationService.fallbackLocale,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      // Wrap entire app in SafeArea to ensure consistent insets globally.
      // Keep EasyLoading overlay working by nesting it inside builder.
      builder: (context, child) {
        // Important: EasyLoading should wrap the SafeArea so the overlay is initialized correctly.
        final safe = SafeArea(
          top: true,
          bottom: true,
          left: false,
          right: false,
          child: child ?? const SizedBox.shrink(),
        );
        return EasyLoading.init()(context, safe);
      },
    );
  }
}
