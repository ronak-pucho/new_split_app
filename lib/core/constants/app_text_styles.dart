import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle displayLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.onSurface);

  static TextStyle displayMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface);

  static TextStyle headingLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface);

  static TextStyle headingMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface);

  static TextStyle bodyLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.onSurface);

  static TextStyle bodyMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7));

  static TextStyle caption(BuildContext context) =>
      GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5));

  static TextStyle button(BuildContext context) =>
      GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600,
          letterSpacing: 0.3, color: Colors.white);

  static TextStyle labelMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.primary);
}
