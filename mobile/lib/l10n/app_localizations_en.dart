// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GIGGO';

  @override
  String get homeGreeting => 'Find trusted professionals near you';

  @override
  String get searchHint => 'Search services';

  @override
  String get serviceCategories => 'Service Categories';

  @override
  String get bookNow => 'Book Now';

  @override
  String get viewTasks => 'View Tasks';
}
