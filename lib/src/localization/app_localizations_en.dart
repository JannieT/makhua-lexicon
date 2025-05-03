// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Makhua Shirima Lexicon';

  @override
  String get loginTitle => 'Makhua Shirima Lexicon';

  @override
  String get loginLabel => 'Sign In';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get emailRequired => 'Email cannot be empty';

  @override
  String get passwordRequired => 'Password cannot be empty';

  @override
  String get userDoesntExistsWithGivenEmail => 'No user with this email';

  @override
  String get invalidEmailOrPassword => 'Invalid email or password';

  @override
  String get somethingWentWrongPleaseTryAgain => 'Something went wrong, please try again';
}
