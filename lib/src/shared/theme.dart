import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// http://material-foundation.github.io?primary=%23B00000&tertiary=%236B9E53&bodyFont=Roboto&displayFont=Roboto+Slab&colorMatch=false
class MaterialTheme {
  final BuildContext context;
  late final TextTheme textTheme;

  MaterialTheme(this.context) {
    textTheme = createTextTheme(context, 'Roboto', 'Roboto Slab');
  }

  ThemeData get dark {
    return _theme(_darkScheme());
  }

  ThemeData get light {
    return _theme(_lightScheme());
  }

  ThemeData _theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        )
        .copyWith(
          headlineLarge: GoogleFonts.robotoSlab(
            fontSize: 57,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
          ),
          displayMedium: GoogleFonts.robotoSlab(
            fontSize: 45,
            fontWeight: FontWeight.w400,
          ),
        ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );

  static ColorScheme _lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff904b40),
      surfaceTint: Color(0xff904b40),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdad4),
      onPrimaryContainer: Color(0xff73342b),
      secondary: Color(0xff775651),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffdad4),
      onSecondaryContainer: Color(0xff5d3f3b),
      tertiary: Color(0xff436833),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffc4efac),
      onTertiaryContainer: Color(0xff2c4f1d),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff231918),
      onSurfaceVariant: Color(0xff534341),
      outline: Color(0xff857370),
      outlineVariant: Color(0xffd8c2be),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff392e2c),
      inversePrimary: Color(0xffffb4a8),
      primaryFixed: Color(0xffffdad4),
      onPrimaryFixed: Color(0xff3a0905),
      primaryFixedDim: Color(0xffffb4a8),
      onPrimaryFixedVariant: Color(0xff73342b),
      secondaryFixed: Color(0xffffdad4),
      onSecondaryFixed: Color(0xff2c1512),
      secondaryFixedDim: Color(0xffe7bdb6),
      onSecondaryFixedVariant: Color(0xff5d3f3b),
      tertiaryFixed: Color(0xffc4efac),
      onTertiaryFixed: Color(0xff062100),
      tertiaryFixedDim: Color(0xffa9d292),
      onTertiaryFixedVariant: Color(0xff2c4f1d),
      surfaceDim: Color(0xffe8d6d3),
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff0ee),
      surfaceContainer: Color(0xfffceae7),
      surfaceContainerHigh: Color(0xfff7e4e1),
      surfaceContainerHighest: Color(0xfff1dfdc),
    );
  }

  static ColorScheme _darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb4a8),
      surfaceTint: Color(0xffffb4a8),
      onPrimary: Color(0xff561e16),
      primaryContainer: Color(0xff73342b),
      onPrimaryContainer: Color(0xffffdad4),
      secondary: Color(0xffe7bdb6),
      onSecondary: Color(0xff442925),
      secondaryContainer: Color(0xff5d3f3b),
      onSecondaryContainer: Color(0xffffdad4),
      tertiary: Color(0xffa9d292),
      onTertiary: Color(0xff163808),
      tertiaryContainer: Color(0xff2c4f1d),
      onTertiaryContainer: Color(0xffc4efac),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff1a1110),
      onSurface: Color(0xfff1dfdc),
      onSurfaceVariant: Color(0xffd8c2be),
      outline: Color(0xffa08c89),
      outlineVariant: Color(0xff534341),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff1dfdc),
      inversePrimary: Color(0xff904b40),
      primaryFixed: Color(0xffffdad4),
      onPrimaryFixed: Color(0xff3a0905),
      primaryFixedDim: Color(0xffffb4a8),
      onPrimaryFixedVariant: Color(0xff73342b),
      secondaryFixed: Color(0xffffdad4),
      onSecondaryFixed: Color(0xff2c1512),
      secondaryFixedDim: Color(0xffe7bdb6),
      onSecondaryFixedVariant: Color(0xff5d3f3b),
      tertiaryFixed: Color(0xffc4efac),
      onTertiaryFixed: Color(0xff062100),
      tertiaryFixedDim: Color(0xffa9d292),
      onTertiaryFixedVariant: Color(0xff2c4f1d),
      surfaceDim: Color(0xff1a1110),
      surfaceBright: Color(0xff423735),
      surfaceContainerLowest: Color(0xff140c0b),
      surfaceContainerLow: Color(0xff231918),
      surfaceContainer: Color(0xff271d1c),
      surfaceContainerHigh: Color(0xff322826),
      surfaceContainerHighest: Color(0xff3d3230),
    );
  }
}

TextTheme createTextTheme(
  BuildContext context,
  String bodyFontString,
  String displayFontString,
) {
  TextTheme baseTextTheme = Theme.of(context).textTheme;
  TextTheme bodyTextTheme = GoogleFonts.getTextTheme(
    bodyFontString,
    baseTextTheme,
  );
  TextTheme displayTextTheme = GoogleFonts.getTextTheme(
    displayFontString,
    baseTextTheme,
  );
  TextTheme textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );
  return textTheme;
}
