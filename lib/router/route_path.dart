/// Route path constants for easy access
/// Use these for navigation: context.go(RoutePath.signIn)
class RoutePath {
  RoutePath._();

  // Auth routes
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String profile = '/profile';

  // Main routes
  static const String dashboard = '/dashboard';
  static const String students = '/students';
  static const String timer = '/timer';
  static const String payments = '/payments';
  static const String reports = '/reports';
  static const String settings = '/settings';

  // Error routes
  static const String notFound = '/404';
}
