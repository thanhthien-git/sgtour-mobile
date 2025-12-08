/// App-wide Constants
class AppConstants {
  // Empty state messages
  static const String emptyTourList = 'No tours found';
  static const String emptySearchResults = 'No results match your search';
  static const String noNetworkConnection = 'No internet connection';

  // Error messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String unauthorizedError = 'You are not authorized to perform this action.';
  static const String serverError = 'Server error. Please try again later.';

  // Success messages
  static const String operationSuccess = 'Operation completed successfully';
  static const String bookingSuccess = 'Tour booked successfully';

  // Dialog titles
  static const String confirmTitle = 'Confirm';
  static const String alertTitle = 'Alert';
  static const String errorTitle = 'Error';
  static const String successTitle = 'Success';

  // Button labels
  static const String confirmButton = 'Confirm';
  static const String cancelButton = 'Cancel';
  static const String okButton = 'OK';
  static const String retryButton = 'Retry';
}

/// Durations
class AppDurations {
  static const Duration shortDuration = Duration(milliseconds: 300);
  static const Duration mediumDuration = Duration(milliseconds: 500);
  static const Duration longDuration = Duration(milliseconds: 1000);
}

/// Padding/Spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Border Radius
class AppBorderRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double full = 100.0;
}
