import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Persian Futurism Palette
  static const Color gold = Color(0xFFD4A843);
  static const Color goldLight = Color(0xFFF0D68A);
  static const Color goldDark = Color(0xFFB8892E);
  static const Color teal = Color(0xFF06B6D4);
  static const Color rose = Color(0xFFE11D48);
  static const Color emerald = Color(0xFF10B981);

  static const Color bg = Color(0xFF0B0E17);
  static const Color surface = Color(0xFF141926);
  static const Color card = Color(0xFF1C2333);
  static const Color cardBorder = Color(0xFF2A3346);
  static const Color divider = Color(0xFF1E2738);
  static const Color textPrimary = Color(0xFFF8F6F0);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Priority colors
  static const Color priorityCritical = Color(0xFFE11D48);
  static const Color priorityHigh = Color(0xFFF97316);
  static const Color priorityMedium = Color(0xFFFBBF24);
  static const Color priorityLow = Color(0xFF34D399);

  // Category colors
  static const Color categoryWork = gold;
  static const Color categoryPersonal = rose;
  static const Color categoryHealth = emerald;
  static const Color categoryEducation = teal;
  static const Color categoryFinance = Color(0xFFF59E0B);
  static const Color categoryFamily = Color(0xFF8B5CF6);

  static const _radius = 12.0;
  static const _cardRadius = 16.0;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: gold,
        secondary: teal,
        tertiary: rose,
        error: rose,
        surface: surface,
        onPrimary: bg,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: bg,
      splashColor: gold.withValues(alpha: 0.08),
      highlightColor: gold.withValues(alpha: 0.04),

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: surface,
        foregroundColor: textPrimary,
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        actionsIconTheme: IconThemeData(color: textSecondary),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: BorderSide(color: cardBorder, width: 0.5),
        ),
        color: card,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: bg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: rose, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: textMuted),
        labelStyle: TextStyle(color: textSecondary),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: gold.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.w600);
          }
          return TextStyle(color: textMuted, fontSize: 11);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: gold, size: 22);
          }
          return IconThemeData(color: textMuted, size: 22);
        }),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        selectedItemColor: gold,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        backgroundColor: surface,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        backgroundColor: card,
        selectedColor: gold.withValues(alpha: 0.2),
        labelStyle: TextStyle(color: textPrimary, fontSize: 13),
      ),

      dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 1),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return gold;
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return gold.withValues(alpha: 0.3);
          return divider;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return gold;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(bg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: bg,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: goldLight),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: textPrimary,
        unselectedLabelColor: textMuted,
        indicatorColor: gold,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: gold,
        inactiveTrackColor: divider,
        thumbColor: gold,
        overlayColor: gold.withValues(alpha: 0.1),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: gold,
        linearTrackColor: divider,
      ),
      canvasColor: surface,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: gold,
        secondary: teal,
        tertiary: rose,
        error: rose,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F6F0),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1A2E),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_cardRadius)),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F3F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        selectedItemColor: gold,
        unselectedItemColor: Color(0xFF6B7280),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE5E7EB), thickness: 1),
    );
  }
}
