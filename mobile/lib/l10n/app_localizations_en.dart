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

  @override
  String get bookingRequestTitle => 'Request a booking';

  @override
  String get bookingViewProfile => 'View Profile';

  @override
  String get bookingSectionService => 'Service';

  @override
  String get bookingSectionWhen => 'When';

  @override
  String get bookingSectionWhere => 'Where';

  @override
  String get bookingSectionTaskDetails => 'Task details';

  @override
  String get bookingSectionContact => 'Contact';

  @override
  String get bookingSectionPriceEstimate => 'Price estimate';

  @override
  String get bookingNoServices => 'This provider has no bookable services yet.';

  @override
  String get bookingChooseService => 'Choose a service';

  @override
  String get bookingSelectDateTime => 'Select date & time';

  @override
  String get bookingEstimatedHours => 'Estimated hours';

  @override
  String get bookingAddressHint => 'Address / landmark (optional)';

  @override
  String get bookingLocationNote =>
      'Add your location to include an accurate travel fee.';

  @override
  String get bookingLatitude => 'Latitude';

  @override
  String get bookingLongitude => 'Longitude';

  @override
  String get bookingTitleHint => 'Short title (e.g. Fix kitchen sink)';

  @override
  String get bookingDescriptionHint => 'Describe what you need (optional)';

  @override
  String get bookingContactName => 'Contact name';

  @override
  String get bookingContactPhone => 'Contact phone';

  @override
  String get bookingCalculating => 'Calculating estimate…';

  @override
  String get bookingEstimateUnavailable =>
      'Estimate unavailable. Final price is confirmed on booking.';

  @override
  String bookingWorkFeeLabel(String hours, String rate) {
    return 'Work fee ($hours × $rate)';
  }

  @override
  String bookingTravelLabel(String km) {
    return 'Travel ($km km)';
  }

  @override
  String get bookingTotal => 'Total';

  @override
  String get bookingEstimatedTotal => 'Estimated total';

  @override
  String get bookingConfirm => 'Confirm booking';

  @override
  String get bookingErrChooseService => 'Please choose a service.';

  @override
  String get bookingErrPickDateTime => 'Please pick a date and time.';

  @override
  String get bookingErrFutureTime => 'Choose a time in the future.';

  @override
  String get bookingRequestSent => 'Booking request sent to the provider.';

  @override
  String get unitHoursShort => 'h';

  @override
  String get commonPayment => 'Payment';

  @override
  String get bdYourBooking => 'Your booking';

  @override
  String bdWithProvider(String name) {
    return 'with $name';
  }

  @override
  String get bdProgress => 'Progress';

  @override
  String get bdBookingDetails => 'Booking details';

  @override
  String get bdPrice => 'Price';

  @override
  String get bdProblemTitle => 'Problem with this job?';

  @override
  String get statusRequested => 'Requested';

  @override
  String get statusRequestedSub => 'Waiting for the provider to accept';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusAcceptedSub => 'Provider accepted your request';

  @override
  String get statusEnRoute => 'On the way';

  @override
  String get statusEnRouteSub => 'Provider is heading to you';

  @override
  String get statusStarted => 'In progress';

  @override
  String get statusStartedSub => 'Work has started';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCompletedSub => 'Work finished';

  @override
  String get statusRated => 'Reviewed';

  @override
  String get statusRatedSub => 'You left a review';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusPaidSub => 'Payment settled';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusCancelledSub => 'This booking was cancelled';

  @override
  String get statusDeclined => 'Declined';

  @override
  String get statusDeclinedSub => 'Provider declined the request';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusExpiredSub => 'Provider did not respond in time';

  @override
  String get bdRowEstimated => 'Estimated';

  @override
  String get bdRowTask => 'Task';

  @override
  String get bdRowAddress => 'Address';

  @override
  String get bdRowNotes => 'Notes';

  @override
  String get bdPaidReleased => 'Paid, released to provider';

  @override
  String get bdHeldEscrow => 'Held securely in escrow';

  @override
  String get bdPaymentDue => 'Payment due';

  @override
  String get bdRelease => 'Release';

  @override
  String get bdPayNow => 'Pay now';

  @override
  String get bdReportProblem => 'Report a problem';

  @override
  String get bdResolvedRefunded => 'Resolved, refunded';

  @override
  String get bdReviewedDismissed => 'Reviewed, dismissed';

  @override
  String bdDisputeLabel(String label) {
    return 'Dispute · $label';
  }

  @override
  String bdAdminNote(String note) {
    return 'Admin: $note';
  }

  @override
  String get bdDisputePrompt =>
      'Tell us what went wrong. Our team will review it.';

  @override
  String get bdWhatHappened => 'What happened?';

  @override
  String get bdSubmit => 'Submit';

  @override
  String get bdDisputeSubmitted => 'Dispute submitted for review.';

  @override
  String get bdTrackLive => 'Track live';

  @override
  String get bdLeaveReview => 'Leave a review';

  @override
  String get bdBookAgain => 'Book again';

  @override
  String get bdCancelTitle => 'Cancel this booking?';

  @override
  String get bdCancelPrompt => 'The provider will be notified.';

  @override
  String get bdReasonOptional => 'Reason (optional)';

  @override
  String get bdKeepBooking => 'Keep booking';

  @override
  String get bdCancelBooking => 'Cancel booking';

  @override
  String get bdBookingCancelled => 'Booking cancelled.';

  @override
  String get commonPlatformFee => 'Platform fee';

  @override
  String get paySummary => 'Payment summary';

  @override
  String get payStepPay => 'Pay';

  @override
  String get payStepEscrow => 'In escrow';

  @override
  String get payStepReleased => 'Released';

  @override
  String get payAmount => 'Amount';

  @override
  String get payProviderReceives => 'Provider receives';

  @override
  String get payFeeNote =>
      'A small platform fee is applied when you pay; the rest goes to your provider.';

  @override
  String get payViewReceipt => 'View receipt';

  @override
  String get payEscrowNote0 =>
      'Your payment is held securely by GIGGO and only released to the provider when you confirm the job is done.';

  @override
  String get payEscrowNote1 =>
      'Funds are held in escrow. Release them once you are happy with the completed work.';

  @override
  String get payEscrowNote2 =>
      'Payment released to the provider. This booking is settled.';

  @override
  String get payReleaseToProvider => 'Release to provider';

  @override
  String payPayAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String get paySecured => 'Payment secured, held safely in escrow.';

  @override
  String get payReleasedThanks => 'Released to the provider. Thank you!';

  @override
  String get receiptUnavailable =>
      'Your receipt will be available once the payment is captured.';

  @override
  String get receiptTitle => 'Receipt';

  @override
  String get receiptCopyTooltip => 'Copy to share';

  @override
  String get receiptPaymentReceipt => 'Payment receipt';

  @override
  String get receiptNo => 'Receipt no.';

  @override
  String get receiptIssued => 'Issued';

  @override
  String get receiptBooking => 'Booking';

  @override
  String get receiptBilledTo => 'Billed to';

  @override
  String get receiptServiceBy => 'Service by';

  @override
  String get receiptJob => 'Job';

  @override
  String get receiptCompleted => 'Completed';

  @override
  String get receiptBaseCallout => 'Base call-out';

  @override
  String receiptLabour(String hours, String rate) {
    return 'Labour · $hours h × $rate';
  }

  @override
  String receiptTravelLine(String km) {
    return 'Travel · $km km';
  }

  @override
  String get receiptTotalPaid => 'Total paid';

  @override
  String get receiptStatusPaid => 'PAID';

  @override
  String get receiptStatusInEscrow => 'IN ESCROW';

  @override
  String get receiptProviderReceived => 'Provider received';

  @override
  String get receiptMethod => 'Method';

  @override
  String get receiptComputerGenerated =>
      'This is a computer-generated receipt.';

  @override
  String get receiptCopied => 'Receipt copied to clipboard.';

  @override
  String get tasksRequested => 'Tasks Requested';

  @override
  String get tasksToGetDone => 'Tasks To Get Done';

  @override
  String get tasksOngoing => 'Ongoing Tasks';

  @override
  String get tasksCompleted => 'Tasks Completed';

  @override
  String get tasksRequests => 'Tasks Requests';

  @override
  String get tasksToDo => 'Tasks To Do';

  @override
  String get tasksTaskFallback => 'Task';

  @override
  String get tasksJobFallback => 'Job';

  @override
  String get tasksViewFee => 'View Fee';

  @override
  String get tasksViewJourney => 'View Journey';

  @override
  String get tasksPayFee => 'Pay Fee';

  @override
  String get tasksRate => 'Rate';

  @override
  String get tasksViewMap => 'View Map';

  @override
  String get tasksAccept => 'Accept';

  @override
  String get tasksDeny => 'Deny';

  @override
  String get tasksStartJourney => 'Start Journey';

  @override
  String get tasksStartTask => 'Start Task';

  @override
  String get tasksEndTask => 'End Task';

  @override
  String get jobAccepted => 'Job accepted';

  @override
  String get jobOnTheWay => 'On the way';

  @override
  String get jobStarted => 'Job started';

  @override
  String get jobCompleted => 'Job completed';

  @override
  String get requestDeclined => 'Request declined';

  @override
  String get jobCancelled => 'Job cancelled';

  @override
  String tasksProviderStartedAt(String time) {
    return 'Provider started the task at : $time';
  }

  @override
  String tasksEndedAt(String time) {
    return 'Ended the task at : $time';
  }

  @override
  String tasksDuration(String dur) {
    return 'Duration : $dur';
  }

  @override
  String tasksStartedAt(String time) {
    return 'Started the task at : $time';
  }

  @override
  String get tasksKeep => 'Keep';

  @override
  String get tasksCancelTaskTitle => 'Cancel this task?';

  @override
  String get tasksCancelTaskBody =>
      'This cancels your request. You can book again anytime.';

  @override
  String get tasksCancelTask => 'Cancel task';

  @override
  String get tasksTaskCancelled => 'Task cancelled';

  @override
  String tasksCouldNotCancel(String error) {
    return 'Could not cancel: $error';
  }

  @override
  String get tasksDeclineTitle => 'Decline this request?';

  @override
  String get tasksDeclineBody =>
      'The customer will be notified that you can\'t take this job.';

  @override
  String get tasksDecline => 'Decline';

  @override
  String get tasksCancelJobTitle => 'Cancel this job?';

  @override
  String get tasksCancelJobBody =>
      'This cancels an accepted job. The customer will be notified.';

  @override
  String get tasksCancelJob => 'Cancel job';

  @override
  String tasksComingSoon(String what) {
    return '$what is coming soon';
  }

  @override
  String get tasksCalling => 'Calling';

  @override
  String get tasksChat => 'Chat';

  @override
  String get tasksNoTasks => 'No tasks yet';

  @override
  String get tasksNoTasksBody =>
      'Find a trusted professional and book your first service.';

  @override
  String get tasksFindProvider => 'Find a provider';

  @override
  String get tasksNoJobs => 'No jobs yet';

  @override
  String get tasksNoJobsBody => 'New booking requests will appear here.';

  @override
  String get shopSearchProducts => 'Search Products';

  @override
  String get shopSavedTools => 'Saved tools';

  @override
  String get shopMyOrders => 'My orders';

  @override
  String get shopCategories => 'Categories';

  @override
  String get shopAllCategories => 'All categories';

  @override
  String get shopNoTools => 'No tools listed yet, check back soon.';

  @override
  String get shopNoMatch => 'No tools match your search.';

  @override
  String get shopUnavailable => 'This tool is currently unavailable';

  @override
  String get toolAboutTool => 'About this tool';

  @override
  String toolBuyPrice(String amount) {
    return 'Buy · $amount';
  }

  @override
  String get wishlistSaved => 'Saved';

  @override
  String get wishlistSaveForLater => 'Save for later';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutQuantity => 'Quantity';

  @override
  String get checkoutDelivery => 'Delivery';

  @override
  String get checkoutShippingAddress => 'Shipping address';

  @override
  String checkoutPriceEach(String amount) {
    return '$amount each';
  }

  @override
  String get checkoutUnits => 'Units';

  @override
  String get checkoutPlacePay => 'Place & pay';

  @override
  String get checkoutOrderPlaced => 'Order placed, thank you!';
}
