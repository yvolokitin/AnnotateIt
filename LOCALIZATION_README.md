# Localization in AnnotateIt

This document provides an overview of the localization implementation in the AnnotateIt application.

## Supported Languages

The application supports the following languages:

- English (en)
- Spanish (es)
- French (fr)
- German (de)
- Italian (it)
- Portuguese (pt)
- Dutch (nl)

## Localization Files

The localization files are located in the `lib/l10n` directory. Each language has its own ARB file:

- `intl_en.arb` - English (template)
- `intl_es.arb` - Spanish
- `intl_fr.arb` - French
- `intl_de.arb` - German
- `intl_it.arb` - Italian
- `intl_pt.arb` - Portuguese
- `intl_nl.arb` - Dutch

The English ARB file (`intl_en.arb`) serves as the template for other languages. All ARB files contain translations for all UI strings used in the application.

## Configuration

The localization is configured in the `l10n.yaml` file at the root of the project:

```yaml
arb-dir: lib/l10n
template-arb-file: intl_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/gen_l10n
```

This configuration generates the necessary Dart files in the `lib/gen_l10n` directory, which are then used by the application to display text in the selected language.

## Language Selection

Users can select their preferred language in the application settings:

1. Navigate to the Account page
2. Go to Application Settings
3. Under "General Settings", find the "Country / Language" section
4. Select the desired language

The application will immediately update to display all UI elements in the selected language. The language preference is saved and will be used the next time the application is launched.

## Implementation Details

### Main Application

The main application (`lib/main.dart`) sets up the localization delegates and supported locales:

```
// In MaterialApp widget
MaterialApp(
  // Localization setup
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  
  // Use explicit locale if set, otherwise use resolution callback
  locale: _locale,
  
  // Use user's preferred language if available, otherwise use system locale with fallback to English
  localeResolutionCallback: (locale, supportedLocales) {
    // First try to use the user's preferred language from settings
    final userLanguage = UserSession.instance.isInitialized 
        ? UserSession.instance.getUser().language 
        : null;
        
    if (userLanguage != null && userLanguage.isNotEmpty) {
      for (final supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == userLanguage) {
          return supportedLocale;
        }
      }
    }
    
    // If user language preference is not set or not supported, try system locale
    if (locale != null) {
      for (final supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return supportedLocale;
        }
      }
    }
    
    // Default to English
    return const Locale('en');
  },
)
```

### Language Selection UI

The language selection UI is implemented in `lib/widgets/account/application_settings.dart`:

```
// Country/language selection
Widget _buildCountrySelection(BuildContext context, bool isWide, bool isTablet) {
  final countryNames = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'nl': 'Dutch',
  };

  // ... widget structure ...

  // When a language is selected
  GestureDetector(
    onTap: () {
      // Update the user's language preference
      onUserChange(user.copyWith(language: code));
      
      // Update the app's locale to reflect the language change
      // This will trigger a rebuild of the MaterialApp with the new locale
      if (AnnotateItApp.instance != null) {
        AnnotateItApp.instance!.updateLocale();
      }
    },
    child: // ... card widget ...
  )
}
```

### Using Localized Strings

To use localized strings in the application, import the generated AppLocalizations class and access the strings through the context:

```dart
import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

// In a widget build method
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Text(l10n.someStringKey);
}
```

## Adding New Strings

To add new strings to the application:

1. Add the string to the English ARB file (`intl_en.arb`) with a unique key
2. Add translations for the string to all other language ARB files
3. Use the string in the application as described above

## Updating Translations

To update existing translations:

1. Modify the translation in the appropriate ARB file
2. The changes will be automatically picked up when the application is rebuilt

## Generating Localization Files

The localization files are automatically generated when the application is built. To manually generate them, run:

```
flutter gen-l10n
```

This will generate the necessary Dart files in the `lib/gen_l10n` directory based on the ARB files and the configuration in `l10n.yaml`.