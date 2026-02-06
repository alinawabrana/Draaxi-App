import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  const ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class AuthRepository {
  AuthRepository({http.Client? client}) : _client = client ?? http.Client() {
    _loadAuthToken();
  }

  static const String _baseUrl = 'https://draaxi.com/api';
  static const String _authTokenKey = 'auth_token';

  final http.Client _client;
  final Map<String, String> _cookies = {};
  String? _authToken;

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_cookies.isNotEmpty) {
      headers['Cookie'] = _cookieHeader;
    }
    if (_cookies.containsKey('XSRF-TOKEN')) {
      headers['X-XSRF-TOKEN'] = _cookies['XSRF-TOKEN']!;
    }
    // Add Bearer token for authenticated requests
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<void> _loadAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString(_authTokenKey);
      if (_authToken != null && _authToken!.isNotEmpty) {
        debugPrint('[API] Auth token loaded from shared preferences');
      }
    } catch (e) {
      debugPrint('[API] Failed to load auth token: $e');
    }
  }

  Future<void> setAuthToken(String? token) async {
    _authToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (token != null && token.isNotEmpty) {
        await prefs.setString(_authTokenKey, token);
        debugPrint('[API] Auth token saved to shared preferences');
      } else {
        await prefs.remove(_authTokenKey);
        debugPrint('[API] Auth token removed from shared preferences');
      }
    } catch (e) {
      debugPrint('[API] Failed to save auth token: $e');
    }
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authTokenKey);
      debugPrint('[API] Auth token cleared from shared preferences');
    } catch (e) {
      debugPrint('[API] Failed to clear auth token: $e');
    }
  }

  void clearCookies() {
    _cookies.clear();
    debugPrint('[API] Cookies cleared');
  }

  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  String get _cookieHeader =>
      _cookies.entries.map((entry) => '${entry.key}=${entry.value}').join('; ');

  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String phone,
    required String countryCode,
    required String gender,
    required String password,
    required String passwordConfirmation,
    String role = 'rider',
  }) async {
    final response = await _postWithResponse(
      '/auth/signup',
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'country_code': countryCode,
        'gender': gender,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
      },
      followRedirects: false,
    );
    return response;
  }

  Future<void> verifyOtp({required String otp}) async {
    await _post(
      '/rider/verify-otp',
      body: {'otp': otp},
      followRedirects: false,
    );
  }

  Future<Map<String, dynamic>> verifySignupOtp({
    required String otp,
    required String token,
  }) async {
    final response = await _postWithResponse(
      '/auth/verify-signup-otp',
      body: {'otp': otp, 'token': token},
      followRedirects: false,
    );

    // Extract and store the token from verification response if present
    final authToken = response['token'] as String?;
    if (authToken != null && authToken.isNotEmpty) {
      await setAuthToken(authToken);
      debugPrint(
        '[API] Auth token stored from signup: ${authToken.substring(0, 10)}...',
      );
    }

    return response;
  }

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _postWithResponse(
      '/auth/login',
      body: {'identifier': identifier, 'password': password},
      followRedirects: false,
    );

    // Extract and store the token from login response
    final token = response['token'] as String?;
    if (token != null && token.isNotEmpty) {
      setAuthToken(token);
      debugPrint('[API] Auth token stored: ${token.substring(0, 10)}...');
    }

    return response;
  }

  Future<Map<String, dynamic>> sendForgotOtp({required String email}) async {
    final response = await _postWithResponse(
      '/auth/send-forgot-otp',
      body: {'email': email},
      followRedirects: false,
    );
    return response;
  }

  Future<void> verifyForgotOtp({
    required String otp,
    required String token,
  }) async {
    await _post(
      '/auth/verify-forgot-otp',
      body: {'otp': otp, 'reset_token': token},
      followRedirects: false,
    );
  }

  Future<Map<String, dynamic>> resetPassword({
    required String password,
    required String passwordConfirmation,
    required String resetToken,
  }) async {
    final response = await _postWithResponse(
      '/auth/reset-password',
      body: {
        'password': password,
        'password_confirmation': passwordConfirmation,
        'reset_token': resetToken,
      },
      followRedirects: false,
    );

    // Extract and store the token from reset password response if present
    final authToken = response['token'] as String?;
    if (authToken != null && authToken.isNotEmpty) {
      await setAuthToken(authToken);
      debugPrint(
        '[API] Auth token stored from password reset: ${authToken.substring(0, 10)}...',
      );
    }

    return response;
  }

  Future<void> skipOtp() async {
    await _post('/rider/skip-otp', body: const {}, followRedirects: false);
  }

  Future<void> setPassword({
    required String password,
    required String passwordConfirmation,
  }) async {
    await _post(
      '/rider/set-password',
      body: {
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      followRedirects: false,
    );
  }

  void _captureCookie(http.Response response) {
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie == null || rawCookie.isEmpty) {
      return;
    }

    for (final entry in _parseCookieHeader(rawCookie).entries) {
      _cookies[entry.key] = entry.value;
    }

    if (_cookies.isNotEmpty) {
      debugPrint('[API] Stored cookies: $_cookieHeader');
      debugPrint('[API] Cookie keys: ${_cookies.keys.toList()}');
    }
  }

  void _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 400) {
      return;
    }

    throw ApiException(_parseErrorMessage(response.body), statusCode);
  }

  void _logResponse(String method, String url, http.Response response) {
    debugPrint(
      '[API] $method $url\n'
      'Status: ${response.statusCode}\n'
      'Headers: ${response.headers}\n'
      'Body: ${response.body}',
    );
  }

  String _parseErrorMessage(String responseBody) {
    if (responseBody.isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] is String &&
            (decoded['message'] as String).isNotEmpty) {
          return decoded['message'] as String;
        }
        if (decoded['error'] is String &&
            (decoded['error'] as String).isNotEmpty) {
          return decoded['error'] as String;
        }
        if (decoded['errors'] is Map<String, dynamic>) {
          final errors = decoded['errors'] as Map<String, dynamic>;
          final messages = errors.values
              .whereType<List>()
              .expand((value) => value)
              .whereType<String>()
              .toList();
          if (messages.isNotEmpty) {
            return messages.join('\n');
          }
        }
      }
    } catch (_) {
      // Ignore JSON parsing errors and fall back to default message.
    }

    return 'Something went wrong. Please try again.';
  }

  Future<void> _post(
    String path, {
    required Map<String, dynamic> body,
    required bool followRedirects,
  }) async {
    await _postWithResponse(path, body: body, followRedirects: followRedirects);
  }

  Future<Map<String, dynamic>> _postWithResponse(
    String path, {
    required Map<String, dynamic> body,
    required bool followRedirects,
  }) async {
    await _ensureCsrfCookie();
    final uri = Uri.parse('$_baseUrl$path');
    final request = http.Request('POST', uri)
      ..headers.addAll(_headers)
      ..body = jsonEncode(body)
      ..followRedirects = followRedirects;

    if (_cookies.isNotEmpty) {
      debugPrint('[API] Using cookies: $_cookieHeader');
      debugPrint('[API] Cookie keys in use: ${_cookies.keys.toList()}');
    }

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    _captureCookie(response);
    _logResponse('POST', uri.toString(), response);
    _handleResponse(response);

    // Parse and return response body
    try {
      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (_) {
      // If parsing fails, return empty map
    }
    return {};
  }

  Future<void> _ensureCsrfCookie() async {
    final hasXsrf = _cookies.containsKey('XSRF-TOKEN');
    final hasSession =
        _cookies.containsKey('laravel_session') ||
        _cookies.containsKey('laravel-session');

    if (hasXsrf && hasSession) {
      return;
    }

    final uri = Uri.parse('https://draaxi.com/sanctum/csrf-cookie');
    final request = http.Request('GET', uri)
      ..headers.addAll({'Accept': 'application/json'})
      ..followRedirects = false;

    if (_cookies.isNotEmpty) {
      request.headers['Cookie'] = _cookieHeader;
    }

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    _captureCookie(response);
    _logResponse('GET', uri.toString(), response);

    if (response.statusCode >= 400) {
      throw ApiException(
        'Unable to initialise session (status ${response.statusCode}).',
        response.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    await _ensureCsrfCookie();
    final uri = Uri.parse('$_baseUrl/user');
    final request = http.Request('GET', uri)
      ..headers.addAll(_headers)
      ..followRedirects = false;

    if (_cookies.isNotEmpty) {
      debugPrint('[API] Using cookies: $_cookieHeader');
    }

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    _captureCookie(response);
    _logResponse('GET', uri.toString(), response);
    _handleResponse(response);

    try {
      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (_) {
      // If parsing fails, return empty map
    }
    return {};
  }

  Future<void> logout() async {
    await _post('/logout', body: const {}, followRedirects: false);
    // Only clear auth token if logout API call is successful
    await clearAuthToken();
    _cookies.clear();
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? city,
    String? street,
    String? district,
    File? profileImage,
  }) async {
    await _ensureCsrfCookie();
    final uri = Uri.parse('$_baseUrl/profile');

    // If profile image is provided, use multipart request
    if (profileImage != null) {
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll(_headers);
      request.headers.remove('Content-Type'); // Let multipart set it

      // Add cookies if available
      if (_cookies.isNotEmpty) {
        request.headers['Cookie'] = _cookieHeader;
      }

      // Add form fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['phone'] = phone;

      if (city != null && city.isNotEmpty) {
        request.fields['city'] = city;
      }
      if (street != null && street.isNotEmpty) {
        request.fields['street'] = street;
      }
      if (district != null && district.isNotEmpty) {
        request.fields['district'] = district;
      }

      // Add the image file
      final fileStream = http.ByteStream(profileImage.openRead());
      final fileLength = await profileImage.length();
      final multipartFile = http.MultipartFile(
        'profile_image',
        fileStream,
        fileLength,
        filename: profileImage.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Add XSRF token if available
      if (_cookies.containsKey('XSRF-TOKEN')) {
        request.headers['X-XSRF-TOKEN'] = _cookies['XSRF-TOKEN']!;
      }

      if (_cookies.isNotEmpty) {
        debugPrint('[API] Using cookies: $_cookieHeader');
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      _captureCookie(response);
      _logResponse('POST', uri.toString(), response);
      _handleResponse(response);

      // Parse and return response body
      try {
        if (response.body.isNotEmpty) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
        }
      } catch (_) {
        // Ignore JSON parsing errors
      }

      return {};
    } else {
      // No image, use regular JSON request
      final body = <String, dynamic>{
        'name': name,
        'email': email,
        'phone': phone,
      };

      if (city != null && city.isNotEmpty) {
        body['city'] = city;
      }
      if (street != null && street.isNotEmpty) {
        body['street'] = street;
      }
      if (district != null && district.isNotEmpty) {
        body['district'] = district;
      }

      final response = await _postWithResponse(
        '/profile',
        body: body,
        followRedirects: false,
      );
      return response;
    }
  }

  Map<String, String> _parseCookieHeader(String header) {
    final result = <String, String>{};
    final pieces = header.split(RegExp(r'(?<=\S),(?=\s*\S+=)'));

    for (final piece in pieces) {
      final cookieAndAttributes = piece.trim().split(';');
      if (cookieAndAttributes.isEmpty) continue;

      final keyValue = cookieAndAttributes.first;
      final separatorIndex = keyValue.indexOf('=');
      if (separatorIndex == -1) continue;

      final name = keyValue.substring(0, separatorIndex).trim();
      final value = keyValue.substring(separatorIndex + 1).trim();
      if (name.isEmpty) continue;

      result[name] = value;
    }

    return result;
  }
}
