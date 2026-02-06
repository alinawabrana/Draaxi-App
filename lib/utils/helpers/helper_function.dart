import 'package:flutter/material.dart';

class AHelperFunction {
  const AHelperFunction._();

  static const String _imageBaseUrl = 'https://draaxi.com/storage/app/public/';

  /// Checks if the current theme is dark mode
  /// Returns true if dark mode is active, false otherwise
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Prefixes an image path with the base URL if it's not already a full URL
  /// Returns the full URL for the image
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    // If the path already starts with http:// or https://, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Remove leading slash if present to avoid double slashes
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;

    // Return the full URL
    return '$_imageBaseUrl$cleanPath';
  }
}
