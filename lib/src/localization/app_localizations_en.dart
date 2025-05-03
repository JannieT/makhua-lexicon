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

  @override
  String get searchEntries => 'Search entries...';

  @override
  String get latest => 'Latest';

  @override
  String get noEntriesFound => 'No entries found';

  @override
  String updatedAt(String time) {
    return 'Updated $time';
  }

  @override
  String timeAgoMinutes(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String timeAgoHours(int hours) {
    return '$hours hours ago';
  }

  @override
  String timeAgoDays(int days) {
    return '$days days ago';
  }

  @override
  String timeAgoWeeks(int weeks) {
    return '$weeks weeks ago';
  }

  @override
  String timeAgoMonths(int months) {
    return '$months months ago';
  }

  @override
  String timeAgoYears(int years) {
    return '$years years ago';
  }
}
