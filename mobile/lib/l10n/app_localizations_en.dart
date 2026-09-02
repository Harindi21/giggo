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

  @override
  String get navHome => 'Home';

  @override
  String get navShop => 'Shop';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navProfile => 'Profile';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsChooseLanguage => 'Choose language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSinhala => 'සිංහල';

  @override
  String get profileName => 'Name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profileNotSet => 'Not set';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get profileEditName => 'Edit name';

  @override
  String get profileFullName => 'Full name';

  @override
  String get profileNameUpdated => 'Name updated';

  @override
  String get profileMyProviderProfile => 'My provider profile';

  @override
  String get profileMyProviderProfileSub =>
      'Bio, rates, service area, skills & availability';

  @override
  String get profileEarnings => 'Earnings';

  @override
  String get profileEarningsSub => 'Balance, withdrawals & payment history';

  @override
  String get profileDemandInsights => 'Demand insights';

  @override
  String get profileDemandInsightsSub =>
      'Weekly demand & next-week forecast for your services';

  @override
  String get profileWorkingHours => 'Working hours';

  @override
  String get profileWorkingHoursSub =>
      'Set the days & times you accept bookings';

  @override
  String get profileVerification => 'Verification';

  @override
  String get profileVerified => 'Verified';

  @override
  String get profileUnderReview => 'Under review';

  @override
  String get profileActionNeeded => 'Action needed';

  @override
  String get profileNotVerified => 'Not verified';

  @override
  String get profileAdminConsole => 'Admin console';

  @override
  String get profileAdminConsoleSub => 'Review provider verifications';

  @override
  String get homeExploreTitle => 'Explore your tasks';

  @override
  String get homeExploreSubtitle =>
      'Track requested, ongoing and completed tasks in one place.';

  @override
  String get homeTipsTitle => 'Tips & Guides';

  @override
  String get homeTipsSubtitle =>
      'Everything you need for booking, payments and safety.';

  @override
  String get homePromoTitle => 'Book a trusted professional';

  @override
  String get homePromoSubtitle => 'For any of your needs, without hesitation.';

  @override
  String get commonRecommendedForYou => 'Recommended for you';

  @override
  String get priceFrom => 'from';

  @override
  String get pricePrefix => 'Rs.';

  @override
  String get commonRetry => 'Retry';

  @override
  String get homeSkillsLoadError => 'Couldn\'t load services. Tap to retry';

  @override
  String get homeSeeProviders => 'See providers in this category';

  @override
  String get discoveryProviders => 'Providers';

  @override
  String discoveryResultsFor(String query) {
    return 'Results for \"$query\"';
  }

  @override
  String get commonAll => 'All';

  @override
  String get discoveryNoProviders => 'No providers found here yet.';

  @override
  String get discoveryNoLocations =>
      'None of these providers have shared a location yet.';

  @override
  String get detailAbout => 'About';

  @override
  String get detailServicesOffered => 'Services offered';

  @override
  String get detailPricing => 'Pricing';

  @override
  String get detailJobsDone => 'Jobs done';

  @override
  String get detailExperience => 'Experience';

  @override
  String detailExperienceValue(int years) {
    return '$years yr';
  }

  @override
  String get detailAvailable => 'Available';

  @override
  String get detailBusy => 'Busy';

  @override
  String get detailStatus => 'Status';

  @override
  String get detailBaseFee => 'Base fee';

  @override
  String get detailWorkFee => 'Work fee';

  @override
  String get detailPerHourSuffix => '/ hour';

  @override
  String get detailTravel => 'Travel';

  @override
  String get detailPerKmSuffix => '/ km';

  @override
  String get detailPriceNote =>
      'Final price is confirmed with a full breakdown before you book.';

  @override
  String get detailStartingFrom => 'Starting from';

  @override
  String get commonGoBack => 'Go back';
}
