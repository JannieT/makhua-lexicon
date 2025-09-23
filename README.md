# Makhua Shirima Lexicon

## Setup

For setting up the Dart SDK and Flutter, see the
[official documentation](https://flutter.io/)

To set up Firebase, run the following using your specific bundle id:

```
firebase login
flutterfire configure -i your.ios.bundle-id.here -a net.kiekies.makhua_lexicon
```

Or log in to the project firebase console and download the firebase config files for
Android and iOS. Put the two files here:

```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

## Test

To run all unit and widget tests:

```
flutter test test/
```

## Release

Update the release version number in pubspec.yaml, for example:

```
version: 0.2.2+5
```

set the database to production in `lib/src/qa/config.dart`

web deploy:

```
flutter build web
firebase deploy
```

### App localisation

To add a new language, say Spanish:

1. add a translation file called `lib/src/localization/app_es.arb`
2. add the language to the `supportedLocales` list in `lib/src/app.dart`

Every time you build your app, an up-to-date app_localizations.dart file is generated in
the untracked `.dart_tool/flutter_gen/gen_l10n` folder so that the new strings and
functions become available on the build context for you to reference.

The widely used "Application Resource Bundles" format is basically just json with some
standard conventions to add meta-data to translation phrases. For example, a phrase that
takes a parameter could be specified as follows:

```
{
    "greeting": "Morning {name}!",
    "@greeting": {
        "description": "Greet the user by their name.",
        "placeholders": {
            "name": {
                "type": "String",
                "example": "Jane"
            }
        }
    }
}
```

For more detail on formatting localized dates, numbers and plurals see [the docs][3]

## Roadmap

- add translations
- export MVP
- offline caching/sync



[3]: https://ishort.ink/owwv