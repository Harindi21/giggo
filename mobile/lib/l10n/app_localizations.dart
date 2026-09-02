import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'GIGGO'**
  String get appTitle;

  /// Subtitle shown on the home screen
  ///
  /// In en, this message translates to:
  /// **'Find trusted professionals near you'**
  String get homeGreeting;

  /// Placeholder in the search box
  ///
  /// In en, this message translates to:
  /// **'Search services'**
  String get searchHint;

  /// Section heading on home
  ///
  /// In en, this message translates to:
  /// **'Service Categories'**
  String get serviceCategories;

  /// Primary call-to-action button
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// Button to open the task list
  ///
  /// In en, this message translates to:
  /// **'View Tasks'**
  String get viewTasks;

  /// Bottom navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation label
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get navShop;

  /// Bottom navigation label
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// Bottom navigation label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Language setting row title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Language chooser sheet title
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get settingsChooseLanguage;

  /// English language option label
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Sinhala language option label (shown in Sinhala in both locales)
  ///
  /// In en, this message translates to:
  /// **'සිංහල'**
  String get languageSinhala;

  /// Profile field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// Profile field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// Profile field label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhone;

  /// Shown when a profile field is empty
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get profileNotSet;

  /// Dialog cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Dialog save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Edit-name dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get profileEditName;

  /// Full-name text field label
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileFullName;

  /// Snackbar after saving a new name
  ///
  /// In en, this message translates to:
  /// **'Name updated'**
  String get profileNameUpdated;

  /// Provider profile tile title
  ///
  /// In en, this message translates to:
  /// **'My provider profile'**
  String get profileMyProviderProfile;

  /// Provider profile tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Bio, rates, service area, skills & availability'**
  String get profileMyProviderProfileSub;

  /// Earnings tile title
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get profileEarnings;

  /// Earnings tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Balance, withdrawals & payment history'**
  String get profileEarningsSub;

  /// Demand insights tile title
  ///
  /// In en, this message translates to:
  /// **'Demand insights'**
  String get profileDemandInsights;

  /// Demand insights tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Weekly demand & next-week forecast for your services'**
  String get profileDemandInsightsSub;

  /// Working hours tile title
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get profileWorkingHours;

  /// Working hours tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Set the days & times you accept bookings'**
  String get profileWorkingHoursSub;

  /// Verification tile title
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get profileVerification;

  /// KYC status
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get profileVerified;

  /// KYC status
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get profileUnderReview;

  /// KYC status
  ///
  /// In en, this message translates to:
  /// **'Action needed'**
  String get profileActionNeeded;

  /// KYC status
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get profileNotVerified;

  /// Admin tile title
  ///
  /// In en, this message translates to:
  /// **'Admin console'**
  String get profileAdminConsole;

  /// Admin tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Review provider verifications'**
  String get profileAdminConsoleSub;

  /// Home explore-tasks card title
  ///
  /// In en, this message translates to:
  /// **'Explore your tasks'**
  String get homeExploreTitle;

  /// Home explore-tasks card subtitle
  ///
  /// In en, this message translates to:
  /// **'Track requested, ongoing and completed tasks in one place.'**
  String get homeExploreSubtitle;

  /// Home knowledge card title
  ///
  /// In en, this message translates to:
  /// **'Tips & Guides'**
  String get homeTipsTitle;

  /// Home knowledge card subtitle
  ///
  /// In en, this message translates to:
  /// **'Everything you need for booking, payments and safety.'**
  String get homeTipsSubtitle;

  /// Home promo card title
  ///
  /// In en, this message translates to:
  /// **'Book a trusted professional'**
  String get homePromoTitle;

  /// Home promo card subtitle
  ///
  /// In en, this message translates to:
  /// **'For any of your needs, without hesitation.'**
  String get homePromoSubtitle;

  /// Recommendation section heading
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get commonRecommendedForYou;

  /// Label under a starting price
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get priceFrom;

  /// Currency prefix for Sri Lankan Rupees
  ///
  /// In en, this message translates to:
  /// **'Rs.'**
  String get pricePrefix;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Shown when a category's skills fail to load
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load services. Tap to retry'**
  String get homeSkillsLoadError;

  /// Shown when a category has no listed skills
  ///
  /// In en, this message translates to:
  /// **'See providers in this category'**
  String get homeSeeProviders;

  /// Fallback header for the provider list
  ///
  /// In en, this message translates to:
  /// **'Providers'**
  String get discoveryProviders;

  /// Search results breadcrumb
  ///
  /// In en, this message translates to:
  /// **'Results for \"{query}\"'**
  String discoveryResultsFor(String query);

  /// Filter chip that clears the current filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// Empty state for the provider list
  ///
  /// In en, this message translates to:
  /// **'No providers found here yet.'**
  String get discoveryNoProviders;

  /// Empty state for the providers map
  ///
  /// In en, this message translates to:
  /// **'None of these providers have shared a location yet.'**
  String get discoveryNoLocations;

  /// Provider detail section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get detailAbout;

  /// Provider detail section title
  ///
  /// In en, this message translates to:
  /// **'Services offered'**
  String get detailServicesOffered;

  /// Provider detail section title
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get detailPricing;

  /// Provider stat label
  ///
  /// In en, this message translates to:
  /// **'Jobs done'**
  String get detailJobsDone;

  /// Provider stat label
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get detailExperience;

  /// Years of experience value
  ///
  /// In en, this message translates to:
  /// **'{years} yr'**
  String detailExperienceValue(int years);

  /// Provider availability status
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get detailAvailable;

  /// Provider availability status
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get detailBusy;

  /// Provider stat label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get detailStatus;

  /// Pricing row label
  ///
  /// In en, this message translates to:
  /// **'Base fee'**
  String get detailBaseFee;

  /// Pricing row label
  ///
  /// In en, this message translates to:
  /// **'Work fee'**
  String get detailWorkFee;

  /// Suffix for an hourly rate
  ///
  /// In en, this message translates to:
  /// **'/ hour'**
  String get detailPerHourSuffix;

  /// Pricing row label
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get detailTravel;

  /// Suffix for a per-kilometre travel fee
  ///
  /// In en, this message translates to:
  /// **'/ km'**
  String get detailPerKmSuffix;

  /// Note under the pricing card
  ///
  /// In en, this message translates to:
  /// **'Final price is confirmed with a full breakdown before you book.'**
  String get detailPriceNote;

  /// Label above the starting price in the book bar
  ///
  /// In en, this message translates to:
  /// **'Starting from'**
  String get detailStartingFrom;

  /// Button to return to the previous screen
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get commonGoBack;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
