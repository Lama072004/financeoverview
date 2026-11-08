import 'package:flutter/material.dart';

/// The four colours from the reference card (traditional Japanese colours),
/// measured from the screenshot.
abstract final class Palette {
  /// 若苗色 Dark Greenish Glaucous – calm main colour.
  static const glaucous = Color(0xFF9EA79D);

  /// 卵色 Cream Yellow – accent.
  static const creamYellow = Color(0xFFE09E2D);

  /// 紅樺色 Pompeian Red – negative values only.
  static const pompeianRed = Color(0xFF960513);

  /// 鶸色 Light Green Yellow – positive values.
  static const greenYellow = Color(0xFFAFAC08);

  // Contrast-tuned variants.
  static const glaucousDeep = Color(0xFF56665A);
  static const glaucousInk = Color(0xFF2B352E);
  static const glaucousMist = Color(0xFFE1E6DE);
  static const greenYellowDeep = Color(0xFF6F6C00);
  static const greenYellowBright = Color(0xFFC9C52C);
  static const redBright = Color(0xFFE0525E);
  static const creamYellowBright = Color(0xFFEAAE45);

  /// Category / account colours, derived from glaucous, cream yellow and
  /// green yellow. Red is deliberately left out: it only ever means
  /// "negative" (and debts in the net worth chart).
  static const chartLight = <Color>[
    Color(0xFF9EA79D),
    Color(0xFFE09E2D),
    Color(0xFFAFAC08),
    Color(0xFF56665A),
    Color(0xFFF0C877),
    Color(0xFF7E7C06),
    Color(0xFFC6CEC4),
    Color(0xFFB8761A),
    Color(0xFFD6D36B),
    Color(0xFF3F4A42),
  ];

  static const chartDark = <Color>[
    Color(0xFFA9B3A8),
    Color(0xFFE8A93C),
    Color(0xFFC9C52C),
    Color(0xFF768A7B),
    Color(0xFFF3D08A),
    Color(0xFF9E9B12),
    Color(0xFFD3DAD1),
    Color(0xFFC98A2E),
    Color(0xFFE2DF85),
    Color(0xFF5E6F62),
  ];
}
