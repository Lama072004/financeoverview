import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/prefs.dart';
import 'palette.dart';

const fontFamily = 'PlusJakartaSans';

/// App-specific colours that Material's ColorScheme has no slot for.
@immutable
class FinanceColors extends ThemeExtension<FinanceColors> {
  const FinanceColors({
    required this.positive,
    required this.negative,
    required this.accent,
    required this.onAccent,
    required this.muted,
    required this.cardShadow,
    required this.cardBorder,
    required this.chart,
    required this.liquidLine,
    required this.investedLine,
    required this.debtLine,
    required this.totalLine,
    required this.track,
  });

  final Color positive;
  final Color negative;
  final Color accent;
  final Color onAccent;

  /// Secondary text.
  final Color muted;
  final List<BoxShadow> cardShadow;
  final Color? cardBorder;
  final List<Color> chart;
  final Color liquidLine;
  final Color investedLine;
  final Color debtLine;
  final Color totalLine;

  /// Background of progress bars.
  final Color track;

  Color chartColor(int index) => chart[index % chart.length];

  /// Colour for a signed amount: positive, negative or neutral for zero.
  Color signed(double value, {Color? neutral}) {
    if (value > 0.004) return positive;
    if (value < -0.004) return negative;
    return neutral ?? muted;
  }

  @override
  FinanceColors copyWith() => this;

  @override
  FinanceColors lerp(ThemeExtension<FinanceColors>? other, double t) =>
      other is FinanceColors && t >= 0.5 ? other : this;
}

extension FinanceTheme on BuildContext {
  FinanceColors get fin => Theme.of(this).extension<FinanceColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
}

/// Tabular figures so amounts line up in columns.
TextStyle money(TextStyle? style) =>
    (style ?? const TextStyle()).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

class AppTheme {
  static ThemeData light() => _build(
        brightness: Brightness.light,
        background: const Color(0xFFF7F3EA),
        surface: const Color(0xFFFFFDF8),
        surfaceHigh: const Color(0xFFF1ECE1),
        outline: const Color(0xFFE4DDCF),
        text: const Color(0xFF1E2320),
        muted: const Color(0xFF6B736C),
        primary: Palette.glaucousDeep,
        onPrimary: Colors.white,
        primaryContainer: Palette.glaucousMist,
        onPrimaryContainer: Palette.glaucousInk,
        fin: const FinanceColors(
          positive: Palette.greenYellowDeep,
          negative: Palette.pompeianRed,
          accent: Palette.creamYellow,
          onAccent: Color(0xFF2B1D05),
          muted: Color(0xFF6B736C),
          cardShadow: [
            BoxShadow(color: Color(0x0D3B3A2E), blurRadius: 18, offset: Offset(0, 6)),
            BoxShadow(color: Color(0x0A3B3A2E), blurRadius: 3, offset: Offset(0, 1)),
          ],
          cardBorder: null,
          chart: Palette.chartLight,
          totalLine: Palette.glaucousDeep,
          liquidLine: Palette.creamYellow,
          investedLine: Palette.greenYellow,
          debtLine: Palette.pompeianRed,
          track: Color(0xFFECE6DA),
        ),
      );

  static ThemeData dark(DarkVariant variant) {
    final black = variant == DarkVariant.black;
    return _build(
      brightness: Brightness.dark,
      background: black ? Colors.black : const Color(0xFF151716),
      surface: black ? const Color(0xFF0F1110) : const Color(0xFF1F2220),
      surfaceHigh: black ? const Color(0xFF1A1D1B) : const Color(0xFF2A2E2B),
      outline: black ? const Color(0xFF252926) : const Color(0xFF353A36),
      text: const Color(0xFFEEEFEA),
      muted: const Color(0xFF9DA59E),
      primary: const Color(0xFFA9B3A8),
      onPrimary: const Color(0xFF141A15),
      primaryContainer: const Color(0xFF2C352E),
      onPrimaryContainer: const Color(0xFFDCE3DA),
      fin: FinanceColors(
        positive: Palette.greenYellowBright,
        negative: Palette.redBright,
        accent: Palette.creamYellowBright,
        onAccent: const Color(0xFF241703),
        muted: const Color(0xFF9DA59E),
        cardShadow: const [],
        cardBorder: black ? const Color(0xFF1E2220) : const Color(0xFF2B302C),
        chart: Palette.chartDark,
        totalLine: const Color(0xFFDCE3DA),
        liquidLine: Palette.creamYellowBright,
        investedLine: Palette.greenYellowBright,
        debtLine: Palette.redBright,
        track: black ? const Color(0xFF1F2321) : const Color(0xFF2E332F),
      ),
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceHigh,
    required Color outline,
    required Color text,
    required Color muted,
    required Color primary,
    required Color onPrimary,
    required Color primaryContainer,
    required Color onPrimaryContainer,
    required FinanceColors fin,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: fin.accent,
      onSecondary: fin.onAccent,
      secondaryContainer: fin.accent.withValues(alpha: 0.18),
      onSecondaryContainer: text,
      tertiary: fin.positive,
      onTertiary: onPrimary,
      error: fin.negative,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
      onSurfaceVariant: muted,
      surfaceContainerLowest: background,
      surfaceContainerLow: surface,
      surfaceContainer: surface,
      surfaceContainerHigh: surfaceHigh,
      surfaceContainerHighest: surfaceHigh,
      outline: outline,
      outlineVariant: outline,
      shadow: Colors.black,
      inverseSurface: text,
      onInverseSurface: background,
    );

    final base = ThemeData(brightness: brightness, fontFamily: fontFamily, useMaterial3: true);
    final t = base.textTheme.apply(bodyColor: text, displayColor: text, fontFamily: fontFamily);
    final textTheme = t.copyWith(
      displaySmall: t.displaySmall?.copyWith(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.8),
      headlineMedium: t.headlineMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6),
      headlineSmall: t.headlineSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleLarge: t.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.2),
      titleMedium: t.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: t.titleSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: t.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: t.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: t.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: muted),
      labelLarge: t.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: t.labelMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: muted),
      labelSmall: t.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4, color: muted),
    );

    final radius = BorderRadius.circular(14);
    final overlay = brightness == Brightness.light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light;

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: textTheme,
      extensions: [fin],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: overlay.copyWith(statusBarColor: Colors.transparent),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: muted,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHigh,
        border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: primary, width: 1.6)),
        errorBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: fin.negative)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: fin.negative, width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: textTheme.bodyMedium?.copyWith(color: muted),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: primary, fontWeight: FontWeight.w600),
        hintStyle: textTheme.bodyMedium?.copyWith(color: muted.withValues(alpha: 0.7)),
        helperStyle: textTheme.bodySmall,
        helperMaxLines: 3,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size(64, 52),
          side: BorderSide(color: outline, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: fin.accent,
        foregroundColor: fin.onAccent,
        elevation: 2,
        highlightElevation: 4,
        shape: const CircleBorder(),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        padding: EdgeInsets.zero,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStatePropertyAll(textTheme.labelMedium?.copyWith(color: null)),
          side: WidgetStatePropertyAll(BorderSide(color: outline)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? primaryContainer : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? onPrimaryContainer : muted,
          ),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surfaceHigh,
        selectedColor: primaryContainer,
        side: BorderSide.none,
        labelStyle: textTheme.labelMedium?.copyWith(color: text),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        showCheckmark: false,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? onPrimary : muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : surfaceHigh,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : outline,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: outline,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: muted),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: text,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: background),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary, linearTrackColor: fin.track),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: primaryContainer,
        headerForegroundColor: onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
