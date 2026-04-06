import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService extends Translations {
  static const fallbackLocale = Locale('en', 'US');
  static final langs = ['English', 'Deutsch'];
  static final locales = [const Locale('en', 'US'), const Locale('de', 'DE')];

  // Translations
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'settings': 'Settings',
      'security': 'Security',
      'your_time_on_goatlearning': 'Your Time on Goatlearning',
      'help': 'Help',
      'language': 'Language',
      'logout': 'Logout',
      'choose_language': 'Choose Language',
      'app_will_restart_to_apply_changes': 'App will restart to apply changes',

      // TimeScreen translations
      'see_your_time': 'See Your Time',
      'see_time_description':
          'See how much time you\'re spending on Goatlearning and what you\'re doing your time.',
      'time_per_day': 'Time per day',
      'average_time_description':
          'Average time you spent per day using Goatlearning in the past 7 days.',
      'avg_this_week': 'Avg this week',
      'avg_last_week': 'Avg last week',
      'mins': 'mins',

      // Week days abbreviations
      'sunday_abbr': 'S',
      'monday_abbr': 'M',
      'tuesday_abbr': 'T',
      'wednesday_abbr': 'W',
      'thursday_abbr': 'T',
      'friday_abbr': 'F',
      'saturday_abbr': 'S',

      // SecurityScreen translations
      'change_password': 'Change Password',
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'confirm_password': 'Confirm Password',
      'save': 'Save',

      'help_support': 'Help & Support',
      'facing_issues_title': 'Facing any issues? Let us know!',
      'describe_problem_description':
          'Describe your problem below and send it to us. We are always ready to assist you.',
      'type_issue_hint': 'Type your issue here...',
      'type_issue_error': 'Type your issue',
      'send_button': 'Send Button',
      'loading': 'Loading...',
      'no_internet_error': 'No Internet connection. Please check your network.',
      'timeout_error':
          'Server is taking too long to respond. Please try again later.',
      'generic_error': 'Something went wrong. Please try again.',
      'format_error': 'Server response was not in the expected format.',
      'enter_current_password': 'Please enter your current password',
      'enter_new_password': 'Please enter a new password',
      'password_min_length': 'Password must be at least 8 characters long',
      'confirm_new_password': 'Please confirm your new password',
      'password_mismatch': 'New password and confirm password do not match',
      'password_different': 'New password must be different from the old one',
      'password_change_success': 'Password changed successfully',
      'password_change_failed': 'Failed to change password',
      'no_favorites_found': 'No Favorites Found',
      'profile': 'Profile',
      'welcome_message': 'Login if you\'re an Admin',
      'user': 'User',
      'not_available': 'N/A',
      'profession_label': 'Profession-@profession',
      'class_label': 'Class-@class',
      'continue_learning': 'Continue learning',
      'no_data_found': 'No data found',
      'completed_percentage': '@percent% completed',

      'profile_update_success': 'Profile updated successfully',
      'profile_update_failed': 'Failed to update profile',
      'logout_success': 'Logged out successfully',
      'unknown': 'Unknown',
      'default_email': 'examplexyz@gmail.com',
      'get_started': 'Get Started',
      'onboarding_description':
          'Create your free account and unlock access to engaging lessons, exercises, and progress tracking',
      'login_existing_account': 'Login to existing account',
      'register_new_account': 'Register new account',
      'create_folder': 'Create New Folder',
      'folder_name': 'Folder Name',
      'enter_folder_name': 'Enter folder name',
      'cancel': 'Cancel',
      'create': 'Create',
      'search_chapters': 'Search chapters...',
      'theory': 'Theory',
      'exercise': 'Exercise',
      'search': 'Search...',
      'no_exercise_found': 'No exercise found',
      'no_theory_found': 'No theory found',
      'exercise_count': '@count Exercise@plural',
      'go_to_exercises': 'Go to Exercises',
      'full_access_message':
          'Get full access of the app. You can buy the app for lifetime in one time.',
      'error': 'Error',
      'login_to_purchase': 'Please login to purchase.',
      'purchase_now': 'Purchase Now',
      'move_to_folder': 'Move to Folder',
      'no_folders_available': 'No folders available',
      'home': 'Home',
      'favorites': 'Favorites',
      'register': 'Register',
      'username': 'Username',
      'email_address': 'Email address',
      'password': 'Password',
      'already_have_account': 'Already have an account? ',
      'login_here': 'Login here',
      'enter_username': 'Please enter your username',
      'enter_email': 'Please enter your email address',
      'enter_valid_email': 'Please enter a valid email address',
      'enter_password': 'Please enter your password',

      'passwords_not_match': 'Passwords do not match',
      'registration_success': 'Successfully registered',
      'registration_failed': 'Failed to register',

      'username_email': 'Username/Email',

      'forgot_password': 'Forgot password?',
      'login': 'Login',
      'continue_as_guest': 'Continue as Guest',
      'no_account_yet': 'Don\'t have an account yet? ',
      'register_here': 'Register here',
      'enter_username_email': 'Please enter your username/email',

      'password_min_length_login': 'Password can\'t be less than 8 characters',
      'try_again_later': 'Try again later',

      // Shared messages (you might already have some of these)

      // Language names
      'english': 'English',
      'deutsch': 'Deutsch',

      // Admin translations
      'manage_admin': 'Manage Admin',
      'add_admin': 'Add Admin',
      'admin_name': 'Admin Name',
      'name': 'Name',
      'email': 'Email',
      'phone_number': 'Phone Number',
      'complete_your_profile': 'Complete Your Profile',
      'add_profile_photo': 'Add Profile Photo',
      'add_chapter': 'Add Chapter',
      'add_chapter_image': 'Add Chapter Image',
      'add_chapter_name': 'Add Chapter Name',
      'add_theory_pdf': 'Add Theory PDF',
      'add_exercise_pdfs': 'Add Exercise PDFs',
      'save_new_book': 'Save New Book',
      'image_required': 'Image is required',
      'chapter_name_required': 'Chapter name is required',
      'theory_pdf_required': 'Theory PDF is required',
      'exercise_pdfs_required': 'Exercise PDFs are required',
      'no_chapters_found': 'No chapters found',
      'edit': 'Edit',
      'no_chapter_found': 'No chapter found',
      'percent_students_read': '@percent% of students have read this',
      'question': 'Question',
      'answer': 'Answer',
      'save_change': 'Save & Change',
      'add_documents': 'Add Documents',
      'attach_documents': 'Attach Documents',
      'no_image': 'No Image',
      'edit_chapter_name': 'Edit Chapter Name',
      'upload_theory': 'Upload Theory',
      'upload': 'Upload',
      'edit_exercise': 'Edit Exercise',
      'update': 'Update',
      'discard': 'Discard',
      'file': 'File',
      'theory_file': 'Theory File:',
      'exercise_problem_solution_pdfs': '🔹 Exercise Problem & Solution PDFs',
      'exercise_number': 'Exercise @number',
      'problem_pdf': 'Problem PDF:',
      'solution_pdf': 'Solution PDF:',
      'tap_upload_problem_pdf': 'Tap to upload Problem PDF',
      'tap_upload_solution_pdf': 'Tap to upload Solution PDF',
      'add_plus': 'Add +',
      'multiple_choice_mcq': '🔹 Multiple Choice (MCQ)',
      'question_number': 'Question: @number',
      'options': '✅ Options:',
      'correct_answer': 'Correct Answer:',
      'solution': 'Solution:',

      // Admin Navigation Bar
      'dashboard': 'Dashboard',
      'add_new': 'Add New',

      // Offline Mode
      'offline_mode': 'Offline Mode',
      'download_all_pdfs': 'Download All PDFs',
      'download_for_offline': 'Download for Offline Access',
      'downloading_pdfs': 'Downloading PDFs...',
      'download_in_progress': 'Download already in progress',
      'no_chapters_to_download': 'No chapters available to download',
      'no_pdfs_to_download': 'No PDFs found to download',
      'download_complete': '@count PDFs downloaded successfully',
      'download_cancelled': 'Download cancelled',
      'download_failed': 'Download failed. Please try again',
      'clearing_cache': 'Clearing cache...',
      'cache_cleared': 'Cache cleared successfully',
      'failed_to_clear_cache': 'Failed to clear cache',
      'clear_cache': 'Clear Cache',
      'cached_files': 'Cached Files',
      'cache_size': 'Cache Size',
      'download_progress': 'Download Progress',
      'cancel_download': 'Cancel Download',
      'offline_description':
          'Download all PDFs to access them without an internet connection',

      // Purchase Screen translations
      'unlock_all_chapters': 'Unlock All Chapters',
      'get_lifetime_access':
          'Get lifetime access to all learning chapters with a one-time purchase',
      'current_access': 'Current Access',
      'first_4_chapters_only': 'First 4 chapters only',
      'full_access': 'Full Access',
      'all_chapters_future_updates': 'All chapters + future updates',
      'unlock_all_remaining_chapters': 'Unlock all remaining chapters',
      'lifetime_access_pay_once': 'Lifetime access - pay once, own forever',
      'access_to_future_updates': 'Access to future chapter updates',
      'complete_learning_journey': 'Complete your learning journey',
      'processing': 'Processing...',
      'one_time_purchase_info':
          'One-time purchase • No subscription • Lifetime access',

      // Purchase status messages
      'iap_not_available':
          'In-app purchases not available. Please check your device or store configuration.',
      'error_fetching_products': 'Error fetching products: @error',
      'product_not_found':
          'Product "@productId" not found. Verify product ID in store.',
      'initialization_error': 'Initialization error: @error',
      'purchase_pending': 'Purchase pending...',
      'purchase_error': 'Purchase error: @error',
      'unknown_error': 'Unknown error',
      'purchase_successful': 'Purchase successful! All chapters unlocked.',
      'failed_to_unlock_chapters':
          'Failed to unlock chapters. Please contact support.',
      'purchase_verification_failed':
          'Purchase verification failed. Please contact support.',
      'no_products_available':
          'No products available to purchase. Please try again later.',
      'starting_purchase': 'Starting purchase...',
      'purchase_initiation_failed': 'Purchase initiation failed: @error',
      'server_error': 'Server error: @code. Please try again.',
      'network_error': 'Network error: @error. Please check your connection.',
      'restore_purchases': 'Restore Purchases',
      'check_billing_status': 'Check Billing Status',
      'admin_login': 'Admin Login',
    },
    'de_DE': {
      'settings': 'Einstellungen',
      'security': 'Sicherheit',
      'your_time_on_goatlearning': 'Ihre Zeit bei Goatlearning',
      'help': 'Hilfe',
      'language': 'Sprache',
      'logout': 'Abmelden',
      'choose_language': 'Sprache wählen',
      'app_will_restart_to_apply_changes':
          'Die App wird neu gestartet, um Änderungen anzuwenden',

      // TimeScreen translations
      'see_your_time': 'Sehen Sie Ihre Zeit',
      'see_time_description':
          'Sehen Sie, wie viel Zeit Sie auf Goatlearning verbringen und womit Sie Ihre Zeit verbringen.',
      'time_per_day': 'Zeit pro Tag',
      'average_time_description':
          'Durchschnittliche Zeit, die Sie in den letzten 7 Tagen pro Tag mit Goatlearning verbracht haben.',
      'avg_this_week': 'Durchs. diese Woche',
      'avg_last_week': 'Durchs. letzte Woche',
      'mins': 'Min',

      // Week days abbreviations (German)
      'sunday_abbr': 'S', // Sonntag
      'monday_abbr': 'M', // Montag
      'tuesday_abbr': 'D', // Dienstag
      'wednesday_abbr': 'M', // Mittwoch
      'thursday_abbr': 'D', // Donnerstag
      'friday_abbr': 'F', // Freitag
      'saturday_abbr': 'S', // Samstag
      // SecurityScreen translations
      'change_password': 'Passwort ändern',
      'current_password': 'Aktuelles Passwort',
      'new_password': 'Neues Passwort',
      'confirm_password': 'Passwort bestätigen',
      'save': 'Speichern',
      'help_support': 'Hilfe & Support',
      'facing_issues_title': 'Haben Sie Probleme? Lassen Sie es uns wissen!',
      'describe_problem_description':
          'Beschreiben Sie Ihr Problem unten und senden Sie es uns. Wir sind immer bereit, Ihnen zu helfen.',
      'type_issue_hint': 'Geben Sie hier Ihr Problem ein...',
      'type_issue_error': 'Geben Sie Ihr Problem ein',
      'send_button': 'Senden',
      'loading': 'Lädt...',
      'no_internet_error':
          'Keine Internetverbindung. Bitte überprüfen Sie Ihr Netzwerk.',
      'timeout_error':
          'Der Server braucht zu lange zum Antworten. Bitte versuchen Sie es später noch einmal.',
      'generic_error':
          'Etwas ist schief gelaufen. Bitte versuchen Sie es erneut.',
      'format_error': 'Die Serverantwort hatte nicht das erwartete Format.',
      'enter_current_password': 'Bitte geben Sie Ihr aktuelles Passwort ein',
      'enter_new_password': 'Bitte geben Sie ein neues Passwort ein',
      'password_min_length': 'Das Passwort muss mindestens 8 Zeichen lang sein',
      'confirm_new_password': 'Bitte bestätigen Sie Ihr neues Passwort',
      'password_mismatch':
          'Neues Passwort und Bestätigungspasswort stimmen nicht überein',
      'password_different':
          'Das neue Passwort muss sich vom alten unterscheiden',
      'password_change_success': 'Passwort erfolgreich geändert',
      'password_change_failed': 'Passwortänderung fehlgeschlagen',
      'no_favorites_found': 'Keine Favoriten gefunden',
      'profile': 'Profil',
      'welcome_message': 'Melden Sie sich an, wenn Sie Administrator sind',
      'user': 'Benutzer',
      'not_available': 'N/V',
      'profession_label': 'Beruf-@profession',
      'class_label': 'Klasse-@class',
      'continue_learning': 'Weiter lernen',
      'no_data_found': 'Keine Daten gefunden',
      'completed_percentage': '@percent% abgeschlossen',

      'profile_update_success': 'Profil erfolgreich aktualisiert',
      'profile_update_failed': 'Profilaktualisierung fehlgeschlagen',
      'logout_success': 'Erfolgreich abgemeldet',
      'unknown': 'Unbekannt',
      'default_email': 'beispielxyz@gmail.com',
      'get_started': 'Loslegen',
      'onboarding_description':
          'Erstellen Sie Ihr kostenloses Konto und erhalten Sie Zugang zu spannenden Lektionen, Übungen und Fortschrittsverfolgung',
      'login_existing_account': 'Anmelden mit bestehendem Konto',
      'register_new_account': 'Neues Konto registrieren',
      'create_folder': 'Neuen Ordner erstellen',
      'folder_name': 'Ordnername',
      'enter_folder_name': 'Ordnernamen eingeben',
      'cancel': 'Abbrechen',
      'create': 'Erstellen',
      'search_chapters': 'Kapitel durchsuchen...',
      'theory': 'Theorie',
      'exercise': 'Übung',
      'search': 'Suchen...',
      'no_exercise_found': 'Keine Übungen gefunden',
      'no_theory_found': 'Keine Theorie gefunden',
      'exercise_count': '@count Übung@plural',
      'go_to_exercises': 'Zu den Übungen',
      'full_access_message':
          'Erhalten Sie vollen Zugriff auf die App. Sie können die App lebenslang mit einer einmaligen Zahlung kaufen.',
      'error': 'Fehler',
      'login_to_purchase': 'Bitte melden Sie sich an, um zu kaufen.',
      'purchase_now': 'Jetzt kaufen',
      'move_to_folder': 'In Ordner verschieben',
      'no_folders_available': 'Keine Ordner verfügbar',
      'home': 'Startseite',
      'favorites': 'Favoriten',
      'register': 'Registrieren',
      'username': 'Benutzername',
      'email_address': 'E-Mail-Adresse',
      'password': 'Passwort',
      'already_have_account': 'Haben Sie bereits ein Konto? ',
      'login_here': 'Hier anmelden',
      'enter_username': 'Bitte geben Sie Ihren Benutzernamen ein',
      'enter_email': 'Bitte geben Sie Ihre E-Mail-Adresse ein',
      'enter_valid_email': 'Bitte geben Sie eine gültige E-Mail-Adresse ein',
      'enter_password': 'Bitte geben Sie Ihr Passwort ein',
      ""
              'passwords_not_match':
          'Passwörter stimmen nicht überein',
      'registration_success': 'Erfolgreich registriert',
      'registration_failed': 'Registrierung fehlgeschlagen',

      'username_email': 'Benutzername/E-Mail',

      'forgot_password': 'Passwort vergessen?',
      'login': 'Anmelden',
      'continue_as_guest': 'Als Gast fortfahren',
      'no_account_yet': 'Noch kein Konto? ',
      'register_here': 'Hier registrieren',
      'enter_username_email': 'Bitte geben Sie Ihren Benutzernamen/E-Mail ein',

      'password_min_length_login':
          'Passwort darf nicht weniger als 8 Zeichen sein',
      'try_again_later': 'Versuchen Sie es später erneut',

      // Language names
      'english': 'Englisch',
      'deutsch': 'Deutsch',

      // Admin translations (German)
      'manage_admin': 'Admin verwalten',
      'add_admin': 'Admin hinzufügen',
      'admin_name': 'Admin-Name',
      'name': 'Name',
      'email': 'E-Mail',
      'phone_number': 'Telefonnummer',
      'complete_your_profile': 'Vervollständigen Sie Ihr Profil',
      'add_profile_photo': 'Profilbild hinzufügen',
      'add_chapter': 'Kapitel hinzufügen',
      'add_chapter_image': 'Kapitelbild hinzufügen',
      'add_chapter_name': 'Kapitelnamen hinzufügen',
      'add_theory_pdf': 'Theorie-PDF hinzufügen',
      'add_exercise_pdfs': 'Übungs-PDFs hinzufügen',
      'save_new_book': 'Neues Buch speichern',
      'image_required': 'Bild ist erforderlich',
      'chapter_name_required': 'Kapitelname ist erforderlich',
      'theory_pdf_required': 'Theorie-PDF ist erforderlich',
      'exercise_pdfs_required': 'Übungs-PDFs sind erforderlich',
      'no_chapters_found': 'Keine Kapitel gefunden',
      'edit': 'Bearbeiten',
      'no_chapter_found': 'Kein Kapitel gefunden',
      'percent_students_read': '@percent% der Schüler haben dies gelesen',
      'question': 'Frage',
      'answer': 'Antwort',
      'save_change': 'Speichern & Ändern',
      'add_documents': 'Dokumente hinzufügen',
      'attach_documents': 'Dokumente anhängen',
      'no_image': 'Kein Bild',
      'edit_chapter_name': 'Kapitelnamen bearbeiten',
      'upload_theory': 'Theorie hochladen',
      'upload': 'Hochladen',
      'edit_exercise': 'Übung bearbeiten',
      'update': 'Aktualisieren',
      'discard': 'Verwerfen',
      'file': 'Datei',
      'theory_file': 'Theorie-Datei:',
      'exercise_problem_solution_pdfs': '🔹 Übungsaufgaben & Lösungs-PDFs',
      'exercise_number': 'Übung @number',
      'problem_pdf': 'Aufgaben-PDF:',
      'solution_pdf': 'Lösungs-PDF:',
      'tap_upload_problem_pdf': 'Tippen Sie, um Aufgaben-PDF hochzuladen',
      'tap_upload_solution_pdf': 'Tippen Sie, um Lösungs-PDF hochzuladen',
      'add_plus': 'Hinzufügen +',
      'multiple_choice_mcq': '🔹 Multiple Choice (MCQ)',
      'question_number': 'Frage: @number',
      'options': '✅ Optionen:',
      'correct_answer': 'Richtige Antwort:',
      'solution': 'Lösung:',

      // Admin Navigation Bar (German)
      'dashboard': 'Übersicht',
      'add_new': 'Neu hinzufügen',

      // Offline Mode (German)
      'offline_mode': 'Offline-Modus',
      'download_all_pdfs': 'Alle PDFs herunterladen',
      'download_for_offline': 'Für Offline-Zugriff herunterladen',
      'downloading_pdfs': 'PDFs werden heruntergeladen...',
      'download_in_progress': 'Download läuft bereits',
      'no_chapters_to_download': 'Keine Kapitel zum Herunterladen verfügbar',
      'no_pdfs_to_download': 'Keine PDFs zum Herunterladen gefunden',
      'download_complete': '@count PDFs erfolgreich heruntergeladen',
      'download_cancelled': 'Download abgebrochen',
      'download_failed':
          'Download fehlgeschlagen. Bitte versuchen Sie es erneut',
      'clearing_cache': 'Cache wird geleert...',
      'cache_cleared': 'Cache erfolgreich geleert',
      'failed_to_clear_cache': 'Fehler beim Leeren des Caches',
      'clear_cache': 'Cache leeren',
      'cached_files': 'Zwischengespeicherte Dateien',
      'cache_size': 'Cache-Größe',
      'download_progress': 'Download-Fortschritt',
      'cancel_download': 'Download abbrechen',
      'offline_description':
          'Laden Sie alle PDFs herunter, um ohne Internetverbindung darauf zuzugreifen',

      // Purchase Screen translations (German)
      'unlock_all_chapters': 'Alle Kapitel freischalten',
      'get_lifetime_access':
          'Erhalten Sie lebenslangen Zugriff auf alle Lernkapitel mit einem einmaligen Kauf',
      'current_access': 'Aktueller Zugriff',
      'first_4_chapters_only': 'Nur die ersten 4 Kapitel',
      'full_access': 'Vollzugriff',
      'all_chapters_future_updates': 'Alle Kapitel + zukünftige Updates',
      'unlock_all_remaining_chapters':
          'Alle verbleibenden Kapitel freischalten',
      'lifetime_access_pay_once':
          'Lebenslanger Zugriff - einmal zahlen, für immer besitzen',
      'access_to_future_updates': 'Zugriff auf zukünftige Kapitel-Updates',
      'complete_learning_journey': 'Vervollständigen Sie Ihre Lernreise',
      'processing': 'Wird verarbeitet...',
      'one_time_purchase_info':
          'Einmaliger Kauf • Kein Abonnement • Lebenslanger Zugriff',

      // Purchase status messages (German)
      'iap_not_available':
          'In-App-Käufe nicht verfügbar. Bitte überprüfen Sie Ihr Gerät oder die Store-Konfiguration.',
      'error_fetching_products': 'Fehler beim Abrufen der Produkte: @error',
      'product_not_found':
          'Produkt "@productId" nicht gefunden. Überprüfen Sie die Produkt-ID im Store.',
      'initialization_error': 'Initialisierungsfehler: @error',
      'purchase_pending': 'Kauf ausstehend...',
      'purchase_error': 'Kauffehler: @error',
      'unknown_error': 'Unbekannter Fehler',
      'purchase_successful': 'Kauf erfolgreich! Alle Kapitel freigeschaltet.',
      'failed_to_unlock_chapters':
          'Kapitel konnten nicht freigeschaltet werden. Bitte kontaktieren Sie den Support.',
      'purchase_verification_failed':
          'Kaufverifizierung fehlgeschlagen. Bitte kontaktieren Sie den Support.',
      'no_products_available':
          'Keine Produkte zum Kauf verfügbar. Bitte versuchen Sie es später erneut.',
      'starting_purchase': 'Kauf wird gestartet...',
      'purchase_initiation_failed': 'Kaufinitiierung fehlgeschlagen: @error',
      'server_error': 'Serverfehler: @code. Bitte versuchen Sie es erneut.',
      'network_error':
          'Netzwerkfehler: @error. Bitte überprüfen Sie Ihre Verbindung.',
      'restore_purchases': 'Käufe wiederherstellen',
      'check_billing_status': 'Abrechnungsstatus prüfen',
      'admin_login': 'Admin-Anmeldung',
    },
  };

  /// Save selected language
  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? '');
  }

  /// Load saved language
  static Future<Locale> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('lang_code');
    final countryCode = prefs.getString('country_code');
    if (langCode != null && langCode.isNotEmpty) {
      return Locale(langCode, countryCode);
    }
    return fallbackLocale;
  }

  /// Change language + save
  static Future<void> changeLocale(String lang) async {
    for (int i = 0; i < langs.length; i++) {
      if (lang == langs[i]) {
        final locale = locales[i];
        await saveLocale(locale);
        Get.updateLocale(locale);
        return;
      }
    }
  }
}
