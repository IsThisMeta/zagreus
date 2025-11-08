import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

/// LunaSea original colors - for legacy theme toggle
class LunaColours {
  /// Core accent colour (LunaSea teal)
  static const Color accent = Color(0xFF4ECCA3);

  /// Light mode accent colour (darker teal for readability)
  static const Color accentLight = Color(0xFF2AA88F);

  /// Core primary colour (background)
  static const Color primary = Color(0xFF32323E);

  /// Core secondary colour (appbar, bottom bar, etc.)
  static const Color secondary = Color(0xFF282834);

  static const Color blue = Color(0xFF00A8E8);
  static const Color blueGrey = Color(0xFF848FA5);
  static const Color grey = Color(0xFFBBBBBB);
  static const Color orange = Color(0xFFFF9000);
  static const Color purple = Color(0xFF9649CB);
  static const Color red = Color(0xFFF71735);

  /// Shades of White
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);
}

class ZagColours {
  /// List of Zagreus colours in order that the should appear in a list.
  ///
  /// Use [byListIndex] to fetch the colour at the any index
  static const _LIST_COLOR_ICONS = [
    blue,
    accent,
    red,
    orange,
    purple,
    blueGrey,
  ];

  /// Core accent colour (brighter teal for dark mode)
  static const Color accent = Color(0xFF2B9A9A);

  /// Dark mode accent colour - using brighter color for better visibility
  static const Color accentDark = Color(0xFF6FE0CC);

  /// Light mode accent colour (darker teal)
  static const Color accentLight = Color(0xFF2A7A82);
  
  // Dark Mode Colors
  static const Color primaryDark = Color(0xFF232534);
  static const Color secondaryDark = Color(0xFF1A1B28);
  
  // Light Mode Colors
  // Pure white background with subtle gray cards
  static const Color primaryLight = Color(0xFFFAFAF8);  // Neutral off-white background
  static const Color secondaryLight = Color(0xFFFAFAF8);  // Match primary for flat light mode
  
  /// Zagreus app black background - RGB(35, 37, 52)
  static const Color zagreusBackground = Color(0xFF232534);

  /// Core primary colour (background)
  static const Color primary = Color(0xFF232534);

  /// Core secondary colour (appbar, bottom bar, etc.),
  static const Color secondary = Color(0xFF1A1B28);

  static const Color blue = Color(0xFF00A8E8);
  static const Color blueGrey = Color(0xFF848FA5);
  static const Color grey = Color(0xFFBBBBBB);
  static const Color orange = Color(0xFFFF9000);
  static const Color purple = Color(0xFF9649CB);
  static const Color red = Color(0xFFF71735);

  /// Shades of White
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);

  /// Returns the correct colour for a graph by what layer it is on the graph canvas.
  Color byGraphLayer(int index) {
    switch (index) {
      case 0:
        return ZagColours.currentAccent;
      case 1:
        return ZagColours.purple;
      case 2:
        return ZagColours.blue;
      default:
        return byListIndex(index);
    }
  }

  /// Return the correct colour for a list.
  /// If the index is greater than the list of colour's length, uses modulus to loop list.
  Color byListIndex(int index) {
    return _LIST_COLOR_ICONS[index % _LIST_COLOR_ICONS.length];
  }
  
  /// Get theme-aware primary color
  static Color primaryColor(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    return isLight ? primaryLight : primaryDark;
  }
  
  /// Get theme-aware secondary color
  static Color secondaryColor(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    return isLight ? secondaryLight : secondaryDark;
  }
  
  /// Get theme-aware accent color
  static Color accentColor(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    return isLight ? accentLight : accentDark;
  }

  /// Get current accent color (respects LunaSea toggle and light/dark theme)
  static Color get currentAccent {
    final useLunaColors = ZagreusDatabase.THEME_USE_LUNASEA_COLORS.read();
    final themeMode = ZagreusDatabase.THEME_MODE.read();
    final isLightMode = themeMode == 'light';

    if (isLightMode) {
      return useLunaColors ? LunaColours.accentLight : accentLight;
    }
    return useLunaColors ? LunaColours.accent : accent;
  }

  /// Get current accent color for light mode (respects LunaSea toggle)
  static Color get currentAccentLight {
    final useLunaColors = ZagreusDatabase.THEME_USE_LUNASEA_COLORS.read();
    return useLunaColors ? LunaColours.accentLight : accentLight;
  }
}

extension ZagColor on Color {
  Color disabled([bool condition = true]) {
    if (condition) return this.withOpacity(ZagUI.OPACITY_DISABLED);
    return this;
  }

  Color enabled([bool condition = true]) {
    if (condition) return this;
    return this.withOpacity(ZagUI.OPACITY_DISABLED);
  }

  Color selected([bool condition = true]) {
    if (condition) return this.withOpacity(ZagUI.OPACITY_SELECTED);
    return this;
  }

  Color dimmed() => this.withOpacity(ZagUI.OPACITY_DIMMED);
}
