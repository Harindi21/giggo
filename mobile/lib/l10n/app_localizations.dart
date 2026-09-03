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

  /// Booking form header
  ///
  /// In en, this message translates to:
  /// **'Request a booking'**
  String get bookingRequestTitle;

  /// Link to the provider profile
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get bookingViewProfile;

  /// Booking form section title
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get bookingSectionService;

  /// Booking form section title
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get bookingSectionWhen;

  /// Booking form section title
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get bookingSectionWhere;

  /// Booking form section title
  ///
  /// In en, this message translates to:
  /// **'Task details'**
  String get bookingSectionTaskDetails;

  /// Booking form section title
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get bookingSectionContact;

  /// Booking form section title
  ///
  /// In en, this message translates to:
  /// **'Price estimate'**
  String get bookingSectionPriceEstimate;

  /// Shown when the provider has no bookable services
  ///
  /// In en, this message translates to:
  /// **'This provider has no bookable services yet.'**
  String get bookingNoServices;

  /// Service dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Choose a service'**
  String get bookingChooseService;

  /// Schedule picker placeholder
  ///
  /// In en, this message translates to:
  /// **'Select date & time'**
  String get bookingSelectDateTime;

  /// Hours stepper label
  ///
  /// In en, this message translates to:
  /// **'Estimated hours'**
  String get bookingEstimatedHours;

  /// Address field hint
  ///
  /// In en, this message translates to:
  /// **'Address / landmark (optional)'**
  String get bookingAddressHint;

  /// Note under the address field
  ///
  /// In en, this message translates to:
  /// **'Add your location to include an accurate travel fee.'**
  String get bookingLocationNote;

  /// Coordinate field label
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get bookingLatitude;

  /// Coordinate field label
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get bookingLongitude;

  /// Task title field hint
  ///
  /// In en, this message translates to:
  /// **'Short title (e.g. Fix kitchen sink)'**
  String get bookingTitleHint;

  /// Task description field hint
  ///
  /// In en, this message translates to:
  /// **'Describe what you need (optional)'**
  String get bookingDescriptionHint;

  /// Contact name field hint
  ///
  /// In en, this message translates to:
  /// **'Contact name'**
  String get bookingContactName;

  /// Contact phone field hint
  ///
  /// In en, this message translates to:
  /// **'Contact phone'**
  String get bookingContactPhone;

  /// Shown while a price quote loads
  ///
  /// In en, this message translates to:
  /// **'Calculating estimate…'**
  String get bookingCalculating;

  /// Shown when a price quote could not be computed
  ///
  /// In en, this message translates to:
  /// **'Estimate unavailable. Final price is confirmed on booking.'**
  String get bookingEstimateUnavailable;

  /// Work fee price row with hours and hourly rate
  ///
  /// In en, this message translates to:
  /// **'Work fee ({hours} × {rate})'**
  String bookingWorkFeeLabel(String hours, String rate);

  /// Travel price row with distance
  ///
  /// In en, this message translates to:
  /// **'Travel ({km} km)'**
  String bookingTravelLabel(String km);

  /// Price breakdown total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get bookingTotal;

  /// Confirm bar total label
  ///
  /// In en, this message translates to:
  /// **'Estimated total'**
  String get bookingEstimatedTotal;

  /// Confirm booking button
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get bookingConfirm;

  /// Validation error
  ///
  /// In en, this message translates to:
  /// **'Please choose a service.'**
  String get bookingErrChooseService;

  /// Validation error
  ///
  /// In en, this message translates to:
  /// **'Please pick a date and time.'**
  String get bookingErrPickDateTime;

  /// Validation error
  ///
  /// In en, this message translates to:
  /// **'Choose a time in the future.'**
  String get bookingErrFutureTime;

  /// Snackbar after creating a booking
  ///
  /// In en, this message translates to:
  /// **'Booking request sent to the provider.'**
  String get bookingRequestSent;

  /// Short suffix for a number of hours
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get unitHoursShort;

  /// Payment section title / header
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get commonPayment;

  /// Booking detail header
  ///
  /// In en, this message translates to:
  /// **'Your booking'**
  String get bdYourBooking;

  /// Provider name in the booking subtitle
  ///
  /// In en, this message translates to:
  /// **'with {name}'**
  String bdWithProvider(String name);

  /// Timeline section title
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get bdProgress;

  /// Details section title
  ///
  /// In en, this message translates to:
  /// **'Booking details'**
  String get bdBookingDetails;

  /// Price section title
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get bdPrice;

  /// Dispute section title
  ///
  /// In en, this message translates to:
  /// **'Problem with this job?'**
  String get bdProblemTitle;

  /// Booking status
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get statusRequested;

  /// Booking status subtitle
  ///
  /// In en, this message translates to:
  /// **'Waiting for the provider to accept'**
  String get statusRequestedSub;

  /// Booking status
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// Booking status subtitle
  ///
  /// In en, this message translates to:
  /// **'Provider accepted your request'**
  String get statusAcceptedSub;

  /// Booking status
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get statusEnRoute;

  /// Booking status subtitle
  ///
  /// In en, this message translates to:
  /// **'Provider is heading to you'**
  String get statusEnRouteSub;

  /// Booking status
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusStarted;

  /// Booking status subtitle
  ///
  /// In en, this message translates to:
  /// **'Work has started'**
  String get statusStartedSub;

  /// Booking status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// Booking status subtitle
  ///
  /// In en, this message translates to:
  /// **'Work finished'**
  String get statusCompletedSub;

  /// Booking status
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get statusRated;

  /// Booking status subtitle
  ///
  /// In en, this message translates to:
  /// **'You left a review'**
  String get statusRatedSub;

  /// Booking status
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// Booking status subtitle
  ///
  /// In en, this message translates to:
  /// **'Payment settled'**
  String get statusPaidSub;

  /// Booking status
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// Booking status subtitle
  ///
  /// In en, this message translates to:
  /// **'This booking was cancelled'**
  String get statusCancelledSub;

  /// Booking status
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get statusDeclined;

  /// Booking status subtitle
  ///
  /// In en, this message translates to:
  /// **'Provider declined the request'**
  String get statusDeclinedSub;

  /// Booking status
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// Booking status subtitle
  ///
  /// In en, this message translates to:
  /// **'Provider did not respond in time'**
  String get statusExpiredSub;

  /// Details row label
  ///
  /// In en, this message translates to:
  /// **'Estimated'**
  String get bdRowEstimated;

  /// Details row label
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get bdRowTask;

  /// Details row label
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get bdRowAddress;

  /// Details row label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get bdRowNotes;

  /// Payment card status
  ///
  /// In en, this message translates to:
  /// **'Paid, released to provider'**
  String get bdPaidReleased;

  /// Payment card status
  ///
  /// In en, this message translates to:
  /// **'Held securely in escrow'**
  String get bdHeldEscrow;

  /// Payment card status
  ///
  /// In en, this message translates to:
  /// **'Payment due'**
  String get bdPaymentDue;

  /// Payment card action
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get bdRelease;

  /// Payment card action
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get bdPayNow;

  /// Dispute button / dialog title
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get bdReportProblem;

  /// Dispute status
  ///
  /// In en, this message translates to:
  /// **'Resolved, refunded'**
  String get bdResolvedRefunded;

  /// Dispute status
  ///
  /// In en, this message translates to:
  /// **'Reviewed, dismissed'**
  String get bdReviewedDismissed;

  /// Dispute header with status
  ///
  /// In en, this message translates to:
  /// **'Dispute · {label}'**
  String bdDisputeLabel(String label);

  /// Admin resolution note
  ///
  /// In en, this message translates to:
  /// **'Admin: {note}'**
  String bdAdminNote(String note);

  /// Dispute dialog prompt
  ///
  /// In en, this message translates to:
  /// **'Tell us what went wrong. Our team will review it.'**
  String get bdDisputePrompt;

  /// Dispute reason field hint
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get bdWhatHappened;

  /// Dispute submit button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get bdSubmit;

  /// Snackbar after raising a dispute
  ///
  /// In en, this message translates to:
  /// **'Dispute submitted for review.'**
  String get bdDisputeSubmitted;

  /// Action to open live tracking
  ///
  /// In en, this message translates to:
  /// **'Track live'**
  String get bdTrackLive;

  /// Action to review a completed job
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get bdLeaveReview;

  /// Action to rebook after a cancellation
  ///
  /// In en, this message translates to:
  /// **'Book again'**
  String get bdBookAgain;

  /// Cancel dialog title
  ///
  /// In en, this message translates to:
  /// **'Cancel this booking?'**
  String get bdCancelTitle;

  /// Cancel dialog prompt
  ///
  /// In en, this message translates to:
  /// **'The provider will be notified.'**
  String get bdCancelPrompt;

  /// Cancel reason field hint
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get bdReasonOptional;

  /// Cancel dialog dismiss button
  ///
  /// In en, this message translates to:
  /// **'Keep booking'**
  String get bdKeepBooking;

  /// Cancel dialog confirm button
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get bdCancelBooking;

  /// Snackbar after cancelling
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled.'**
  String get bdBookingCancelled;

  /// Platform commission label
  ///
  /// In en, this message translates to:
  /// **'Platform fee'**
  String get commonPlatformFee;

  /// Payment section title
  ///
  /// In en, this message translates to:
  /// **'Payment summary'**
  String get paySummary;

  /// Escrow stepper label
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get payStepPay;

  /// Escrow stepper label
  ///
  /// In en, this message translates to:
  /// **'In escrow'**
  String get payStepEscrow;

  /// Escrow stepper label
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get payStepReleased;

  /// Payment summary row label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get payAmount;

  /// Payment summary row label
  ///
  /// In en, this message translates to:
  /// **'Provider receives'**
  String get payProviderReceives;

  /// Note shown before a payment is made
  ///
  /// In en, this message translates to:
  /// **'A small platform fee is applied when you pay; the rest goes to your provider.'**
  String get payFeeNote;

  /// Link to the receipt
  ///
  /// In en, this message translates to:
  /// **'View receipt'**
  String get payViewReceipt;

  /// Escrow explanation before paying
  ///
  /// In en, this message translates to:
  /// **'Your payment is held securely by GIGGO and only released to the provider when you confirm the job is done.'**
  String get payEscrowNote0;

  /// Escrow explanation while held
  ///
  /// In en, this message translates to:
  /// **'Funds are held in escrow. Release them once you are happy with the completed work.'**
  String get payEscrowNote1;

  /// Escrow explanation after release
  ///
  /// In en, this message translates to:
  /// **'Payment released to the provider. This booking is settled.'**
  String get payEscrowNote2;

  /// Release action button
  ///
  /// In en, this message translates to:
  /// **'Release to provider'**
  String get payReleaseToProvider;

  /// Pay action button with amount
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String payPayAmount(String amount);

  /// Snackbar after paying
  ///
  /// In en, this message translates to:
  /// **'Payment secured, held safely in escrow.'**
  String get paySecured;

  /// Snackbar after releasing
  ///
  /// In en, this message translates to:
  /// **'Released to the provider. Thank you!'**
  String get payReleasedThanks;

  /// Shown before a receipt exists
  ///
  /// In en, this message translates to:
  /// **'Your receipt will be available once the payment is captured.'**
  String get receiptUnavailable;

  /// Receipt screen header
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receiptTitle;

  /// Copy button tooltip
  ///
  /// In en, this message translates to:
  /// **'Copy to share'**
  String get receiptCopyTooltip;

  /// Receipt document subtitle
  ///
  /// In en, this message translates to:
  /// **'Payment receipt'**
  String get receiptPaymentReceipt;

  /// Receipt number label
  ///
  /// In en, this message translates to:
  /// **'Receipt no.'**
  String get receiptNo;

  /// Issue date label
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get receiptIssued;

  /// Booking reference label
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get receiptBooking;

  /// Customer party label
  ///
  /// In en, this message translates to:
  /// **'Billed to'**
  String get receiptBilledTo;

  /// Provider party label
  ///
  /// In en, this message translates to:
  /// **'Service by'**
  String get receiptServiceBy;

  /// Job title party label
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get receiptJob;

  /// Completion date party label
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get receiptCompleted;

  /// Receipt line item
  ///
  /// In en, this message translates to:
  /// **'Base call-out'**
  String get receiptBaseCallout;

  /// Labour line item with hours and rate
  ///
  /// In en, this message translates to:
  /// **'Labour · {hours} h × {rate}'**
  String receiptLabour(String hours, String rate);

  /// Travel line item with distance
  ///
  /// In en, this message translates to:
  /// **'Travel · {km} km'**
  String receiptTravelLine(String km);

  /// Receipt total label
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get receiptTotalPaid;

  /// Receipt status chip
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get receiptStatusPaid;

  /// Receipt status chip
  ///
  /// In en, this message translates to:
  /// **'IN ESCROW'**
  String get receiptStatusInEscrow;

  /// Escrow split label
  ///
  /// In en, this message translates to:
  /// **'Provider received'**
  String get receiptProviderReceived;

  /// Payment method label
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get receiptMethod;

  /// Receipt footer note
  ///
  /// In en, this message translates to:
  /// **'This is a computer-generated receipt.'**
  String get receiptComputerGenerated;

  /// Snackbar after copying the receipt
  ///
  /// In en, this message translates to:
  /// **'Receipt copied to clipboard.'**
  String get receiptCopied;

  /// Customer tasks section
  ///
  /// In en, this message translates to:
  /// **'Tasks Requested'**
  String get tasksRequested;

  /// Customer tasks section
  ///
  /// In en, this message translates to:
  /// **'Tasks To Get Done'**
  String get tasksToGetDone;

  /// Tasks section
  ///
  /// In en, this message translates to:
  /// **'Ongoing Tasks'**
  String get tasksOngoing;

  /// Tasks section
  ///
  /// In en, this message translates to:
  /// **'Tasks Completed'**
  String get tasksCompleted;

  /// Provider jobs section
  ///
  /// In en, this message translates to:
  /// **'Tasks Requests'**
  String get tasksRequests;

  /// Provider jobs section
  ///
  /// In en, this message translates to:
  /// **'Tasks To Do'**
  String get tasksToDo;

  /// Fallback title for a booking
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get tasksTaskFallback;

  /// Fallback title for a job
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get tasksJobFallback;

  /// Task action
  ///
  /// In en, this message translates to:
  /// **'View Fee'**
  String get tasksViewFee;

  /// Task action
  ///
  /// In en, this message translates to:
  /// **'View Journey'**
  String get tasksViewJourney;

  /// Task action
  ///
  /// In en, this message translates to:
  /// **'Pay Fee'**
  String get tasksPayFee;

  /// Task action
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get tasksRate;

  /// Job action
  ///
  /// In en, this message translates to:
  /// **'View Map'**
  String get tasksViewMap;

  /// Job action
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get tasksAccept;

  /// Job action
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get tasksDeny;

  /// Job action
  ///
  /// In en, this message translates to:
  /// **'Start Journey'**
  String get tasksStartJourney;

  /// Job action
  ///
  /// In en, this message translates to:
  /// **'Start Task'**
  String get tasksStartTask;

  /// Job action
  ///
  /// In en, this message translates to:
  /// **'End Task'**
  String get tasksEndTask;

  /// Snackbar
  ///
  /// In en, this message translates to:
  /// **'Job accepted'**
  String get jobAccepted;

  /// Snackbar
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get jobOnTheWay;

  /// Snackbar
  ///
  /// In en, this message translates to:
  /// **'Job started'**
  String get jobStarted;

  /// Snackbar
  ///
  /// In en, this message translates to:
  /// **'Job completed'**
  String get jobCompleted;

  /// Snackbar
  ///
  /// In en, this message translates to:
  /// **'Request declined'**
  String get requestDeclined;

  /// Snackbar
  ///
  /// In en, this message translates to:
  /// **'Job cancelled'**
  String get jobCancelled;

  /// Customer view of task start time
  ///
  /// In en, this message translates to:
  /// **'Provider started the task at : {time}'**
  String tasksProviderStartedAt(String time);

  /// Task end time
  ///
  /// In en, this message translates to:
  /// **'Ended the task at : {time}'**
  String tasksEndedAt(String time);

  /// Task duration
  ///
  /// In en, this message translates to:
  /// **'Duration : {dur}'**
  String tasksDuration(String dur);

  /// Provider view of task start time
  ///
  /// In en, this message translates to:
  /// **'Started the task at : {time}'**
  String tasksStartedAt(String time);

  /// Dialog dismiss button
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get tasksKeep;

  /// Customer cancel dialog title
  ///
  /// In en, this message translates to:
  /// **'Cancel this task?'**
  String get tasksCancelTaskTitle;

  /// Customer cancel dialog body
  ///
  /// In en, this message translates to:
  /// **'This cancels your request. You can book again anytime.'**
  String get tasksCancelTaskBody;

  /// Customer cancel confirm
  ///
  /// In en, this message translates to:
  /// **'Cancel task'**
  String get tasksCancelTask;

  /// Snackbar
  ///
  /// In en, this message translates to:
  /// **'Task cancelled'**
  String get tasksTaskCancelled;

  /// Cancel error snackbar
  ///
  /// In en, this message translates to:
  /// **'Could not cancel: {error}'**
  String tasksCouldNotCancel(String error);

  /// Provider decline dialog title
  ///
  /// In en, this message translates to:
  /// **'Decline this request?'**
  String get tasksDeclineTitle;

  /// Provider decline dialog body
  ///
  /// In en, this message translates to:
  /// **'The customer will be notified that you can\'t take this job.'**
  String get tasksDeclineBody;

  /// Provider decline confirm
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get tasksDecline;

  /// Provider cancel dialog title
  ///
  /// In en, this message translates to:
  /// **'Cancel this job?'**
  String get tasksCancelJobTitle;

  /// Provider cancel dialog body
  ///
  /// In en, this message translates to:
  /// **'This cancels an accepted job. The customer will be notified.'**
  String get tasksCancelJobBody;

  /// Provider cancel confirm
  ///
  /// In en, this message translates to:
  /// **'Cancel job'**
  String get tasksCancelJob;

  /// Placeholder feature snackbar
  ///
  /// In en, this message translates to:
  /// **'{what} is coming soon'**
  String tasksComingSoon(String what);

  /// Coming-soon feature name
  ///
  /// In en, this message translates to:
  /// **'Calling'**
  String get tasksCalling;

  /// Coming-soon feature name
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get tasksChat;

  /// Customer empty state
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get tasksNoTasks;

  /// Customer empty state body
  ///
  /// In en, this message translates to:
  /// **'Find a trusted professional and book your first service.'**
  String get tasksNoTasksBody;

  /// Customer empty state action
  ///
  /// In en, this message translates to:
  /// **'Find a provider'**
  String get tasksFindProvider;

  /// Provider empty state
  ///
  /// In en, this message translates to:
  /// **'No jobs yet'**
  String get tasksNoJobs;

  /// Provider empty state body
  ///
  /// In en, this message translates to:
  /// **'New booking requests will appear here.'**
  String get tasksNoJobsBody;

  /// Shop search hint
  ///
  /// In en, this message translates to:
  /// **'Search Products'**
  String get shopSearchProducts;

  /// Shop menu: wishlist
  ///
  /// In en, this message translates to:
  /// **'Saved tools'**
  String get shopSavedTools;

  /// Shop menu: orders
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get shopMyOrders;

  /// Shop menu section header
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get shopCategories;

  /// Shop category filter: all
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get shopAllCategories;

  /// Shop empty state
  ///
  /// In en, this message translates to:
  /// **'No tools listed yet, check back soon.'**
  String get shopNoTools;

  /// Shop empty search state
  ///
  /// In en, this message translates to:
  /// **'No tools match your search.'**
  String get shopNoMatch;

  /// Snackbar for an out-of-stock tool
  ///
  /// In en, this message translates to:
  /// **'This tool is currently unavailable'**
  String get shopUnavailable;

  /// Tool detail section title
  ///
  /// In en, this message translates to:
  /// **'About this tool'**
  String get toolAboutTool;

  /// Buy button with price
  ///
  /// In en, this message translates to:
  /// **'Buy · {amount}'**
  String toolBuyPrice(String amount);

  /// Wishlist heart tooltip when saved
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get wishlistSaved;

  /// Wishlist heart tooltip when not saved
  ///
  /// In en, this message translates to:
  /// **'Save for later'**
  String get wishlistSaveForLater;

  /// Checkout header
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// Checkout section title
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get checkoutQuantity;

  /// Checkout section title
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get checkoutDelivery;

  /// Shipping address field
  ///
  /// In en, this message translates to:
  /// **'Shipping address'**
  String get checkoutShippingAddress;

  /// Unit price on the checkout tool card
  ///
  /// In en, this message translates to:
  /// **'{amount} each'**
  String checkoutPriceEach(String amount);

  /// Quantity stepper label
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get checkoutUnits;

  /// Place order button
  ///
  /// In en, this message translates to:
  /// **'Place & pay'**
  String get checkoutPlacePay;

  /// Snackbar after placing an order
  ///
  /// In en, this message translates to:
  /// **'Order placed, thank you!'**
  String get checkoutOrderPlaced;

  /// Orders empty state
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmpty;

  /// Orders empty state body
  ///
  /// In en, this message translates to:
  /// **'Tools you buy from the Shop will appear here.'**
  String get ordersEmptyBody;

  /// Order quantity, unit price and total
  ///
  /// In en, this message translates to:
  /// **'{qty} × {unit}  ·  Total {total}'**
  String ordersLine(int qty, String unit, String total);

  /// Order status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ordersPending;

  /// Snackbar after paying for an order
  ///
  /// In en, this message translates to:
  /// **'Payment complete.'**
  String get ordersPaymentComplete;

  /// Snackbar after cancelling an order
  ///
  /// In en, this message translates to:
  /// **'Order cancelled.'**
  String get ordersCancelled;

  /// Wishlist empty state
  ///
  /// In en, this message translates to:
  /// **'No saved tools yet.\nTap the heart on a tool to save it.'**
  String get wishlistEmpty;

  /// Remove-from-wishlist tooltip
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get wishlistRemove;
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
