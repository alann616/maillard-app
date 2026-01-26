import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF1A1A1A);
  static const Color secondary = Color(0xFFF5F5F5);
  static const Color accent = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  
  static TextStyle get titleLarge => GoogleFonts.jetBrainsMono(
    fontSize: 20, fontWeight: FontWeight.bold, color: primary
  );
  
  static TextStyle get priceTag => GoogleFonts.jetBrainsMono(
    fontSize: 18, fontWeight: FontWeight.w700, color: accent
  );
  
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade200),
  );
}