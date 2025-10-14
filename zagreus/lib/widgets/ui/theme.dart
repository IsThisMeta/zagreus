import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:zagreus/core.dart';

class ZagTheme {
  /// Initialize the theme by setting the system navigation and system colours.
  void initialize() {
    //Set system UI overlay style (navbar, statusbar)
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
  }

  /// Returns the active [ThemeData] by checking the theme database value.
  ThemeData activeTheme({Brightness? systemBrightness}) {
    // Determine if we should use light theme
    bool useLightTheme = false;
    if (ZagreusDatabase.THEME_FOLLOW_SYSTEM.read() && systemBrightness != null) {
      useLightTheme = systemBrightness == Brightness.light;
    } else {
      useLightTheme = themeMode == 'light';
    }
    
    if (useLightTheme) {
      return _lightTheme();
    }
    return isAMOLEDTheme ? _pureBlackTheme() : _midnightTheme();
  }
  
  /// Get the current accent color based on theme
  static Color get currentAccent {
    return themeMode == 'light' ? ZagColours.currentAccentLight : ZagColours.currentAccent;
  }

  static bool get isAMOLEDTheme => ZagreusDatabase.THEME_AMOLED.read();
  static bool get useBorders => ZagreusDatabase.THEME_AMOLED_BORDER.read();
  static bool get useLightBorders => ZagreusDatabase.THEME_LIGHT_BORDER.read();
  static String get themeMode => ZagreusDatabase.THEME_MODE.read();

  /// Midnight theme (Default)
  ThemeData _midnightTheme() {
    // Check if LunaSea colors are enabled
    final useLunaColors = ZagreusDatabase.THEME_USE_LUNASEA_COLORS.read();
    final primary = useLunaColors ? LunaColours.primary : ZagColours.primary;
    final secondary = useLunaColors ? LunaColours.secondary : ZagColours.secondary;
    final accent = useLunaColors ? LunaColours.accent : ZagColours.currentAccent;

    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      canvasColor: primary,
      primaryColor: secondary,
      highlightColor: accent.withOpacity(ZagUI.OPACITY_SPLASH / 2),
      cardColor: secondary,
      hoverColor: accent.withOpacity(ZagUI.OPACITY_SPLASH / 2),
      splashColor: accent.withOpacity(ZagUI.OPACITY_SPLASH),
      dialogTheme: DialogThemeData(
        backgroundColor: secondary,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: secondary,
          borderRadius: BorderRadius.all(Radius.circular(ZagUI.BORDER_RADIUS)),
        ),
        textStyle: TextStyle(
          color: ZagColours.grey,
          fontSize: ZagUI.FONT_SIZE_SUBHEADER,
        ),
        preferBelow: true,
      ),
      unselectedWidgetColor: Colors.white,
      textTheme: _sharedTextTheme,
      textButtonTheme: _sharedTextButtonThemeData(accent),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// AMOLED/Pure black theme
  ThemeData _pureBlackTheme() {
    // Check if LunaSea colors are enabled for accent color
    final useLunaColors = ZagreusDatabase.THEME_USE_LUNASEA_COLORS.read();
    final accent = useLunaColors ? LunaColours.accent : ZagColours.currentAccent;

    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      canvasColor: Colors.black,
      primaryColor: Colors.black,
      highlightColor: accent.withOpacity(ZagUI.OPACITY_SPLASH / 2),
      cardColor: Colors.black,
      hoverColor: accent.withOpacity(ZagUI.OPACITY_SPLASH / 2),
      splashColor: accent.withOpacity(ZagUI.OPACITY_SPLASH),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.black,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: const BorderRadius.all(
            Radius.circular(ZagUI.BORDER_RADIUS),
          ),
          border: useBorders ? Border.all(color: ZagColours.white10) : null,
        ),
        textStyle: const TextStyle(
          color: ZagColours.grey,
          fontSize: ZagUI.FONT_SIZE_SUBHEADER,
        ),
        preferBelow: true,
      ),
      unselectedWidgetColor: Colors.white,
      textTheme: _sharedTextTheme,
      textButtonTheme: _sharedTextButtonThemeData(accent),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// Light theme
  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      canvasColor: ZagColours.primaryLight,
      primaryColor: ZagColours.secondaryLight,
      highlightColor: ZagColours.currentAccentLight.withOpacity(ZagUI.OPACITY_SPLASH / 2),
      cardColor: ZagColours.secondaryLight,
      hoverColor: ZagColours.currentAccentLight.withOpacity(ZagUI.OPACITY_SPLASH / 2),
      splashColor: ZagColours.currentAccentLight.withOpacity(ZagUI.OPACITY_SPLASH),
      dialogTheme: DialogThemeData(
        backgroundColor: ZagColours.secondaryLight,
      ),
      iconTheme: const IconThemeData(
        color: Colors.black87,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ZagColours.secondaryLight,
        foregroundColor: Colors.black87,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: IconThemeData(color: Colors.black87),
        elevation: 0,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: const BorderRadius.all(Radius.circular(ZagUI.BORDER_RADIUS)),
          border: useLightBorders ? Border.all(color: Colors.black12) : null,
        ),
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: ZagUI.FONT_SIZE_SUBHEADER,
        ),
        preferBelow: true,
      ),
      unselectedWidgetColor: Colors.black54,
      textTheme: _lightTextTheme,
      textButtonTheme: _lightTextButtonThemeData,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  SystemUiOverlayStyle get overlayStyle {
    bool isLight = themeMode == 'light';
    return SystemUiOverlayStyle(
      systemNavigationBarColor: isLight
          ? ZagColours.secondaryLight
          : (ZagreusDatabase.THEME_AMOLED.read()
              ? Colors.black
              : ZagColours.secondary),
      systemNavigationBarDividerColor: isLight
          ? ZagColours.secondaryLight
          : (ZagreusDatabase.THEME_AMOLED.read()
              ? Colors.black
              : ZagColours.secondary),
      statusBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
    );
  }

  TextTheme get _sharedTextTheme {
    const textStyle = TextStyle(color: Colors.white);
    return const TextTheme(
      displaySmall: textStyle,
      displayMedium: textStyle,
      displayLarge: textStyle,
      headlineSmall: textStyle,
      headlineMedium: textStyle,
      headlineLarge: textStyle,
      bodySmall: textStyle,
      bodyMedium: textStyle,
      bodyLarge: textStyle,
      titleSmall: textStyle,
      titleMedium: textStyle,
      titleLarge: textStyle,
      labelSmall: textStyle,
      labelMedium: textStyle,
      labelLarge: textStyle,
    );
  }

  TextButtonThemeData _sharedTextButtonThemeData(Color accentColor) {
    return TextButtonThemeData(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all<Color>(
          accentColor.withOpacity(ZagUI.OPACITY_SPLASH),
        ),
      ),
    );
  }

  TextTheme get _lightTextTheme {
    const textStyle = TextStyle(color: Colors.black87);
    return const TextTheme(
      displaySmall: textStyle,
      displayMedium: textStyle,
      displayLarge: textStyle,
      headlineSmall: textStyle,
      headlineMedium: textStyle,
      headlineLarge: textStyle,
      bodySmall: textStyle,
      bodyMedium: textStyle,
      bodyLarge: textStyle,
      titleSmall: textStyle,
      titleMedium: textStyle,
      titleLarge: textStyle,
      labelSmall: textStyle,
      labelMedium: textStyle,
      labelLarge: textStyle,
    );
  }

  TextButtonThemeData get _lightTextButtonThemeData {
    return TextButtonThemeData(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all<Color>(
          ZagColours.currentAccentLight.withOpacity(ZagUI.OPACITY_SPLASH),
        ),
      ),
    );
  }
}
