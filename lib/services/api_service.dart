import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

/// Result of an API call.
class ApiResult<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  const ApiResult({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });
}

/// Central HTTP client for the Wishlist Tracker PHP REST API.
class ApiService {
  ApiService._();

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, dynamic> _decodeBody(http.Response res) {
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  static String _messageForStatus(int code) {
    switch (code) {
      case 400:
        return 'Permintaan tidak valid.';
      case 401:
        return 'Email atau password salah.';
      case 404:
        return 'Data tidak ditemukan.';
      case 409:
        return 'Email sudah terdaftar.';
      case 500:
        return 'Terjadi kesalahan pada server.';
      default:
        return 'Terjadi kesalahan. Coba lagi.';
    }
  }

  static String _messageForNetwork() {
    return 'Gagal terhubung ke server. Pastikan API berjalan.';
  }

  static String _messageForTimeout() {
    return 'Waktu koneksi habis. Periksa koneksi Anda.';
  }

  static ApiResult<T> _parse<T>(
    http.Response res,
    T? Function(Map<String, dynamic> body) parse,
  ) {
    final body = _decodeBody(res);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return ApiResult(
        success: body['success'] ?? true,
        message: (body['message'] as String?) ?? 'Success',
        data: parse(body),
        statusCode: res.statusCode,
      );
    }
    return ApiResult(
      // Non-2xx: failed result with a user-friendly message.
      success: false,
      message:
          (body['message'] as String?) ?? _messageForStatus(res.statusCode),
      data: null,
      statusCode: res.statusCode,
    );
  }

  /// Unified request runner for all API calls.
  static Future<ApiResult<T>> _run<T>(
    Future<http.Response> Function() request, {
    required T? Function(Map<String, dynamic> body) parse,
  }) async {
    try {
      final res = await request().timeout(ApiConfig.timeout);
      return _parse(res, parse);
    } on TimeoutException {
      return ApiResult(
        success: false,
        message: _messageForTimeout(),
        data: null,
        statusCode: 0,
      );
    } on http.ClientException {
      return ApiResult(
        success: false,
        message: _messageForNetwork(),
        data: null,
        statusCode: 0,
      );
    } on FormatException {
      return ApiResult(
        success: false,
        message: _messageForNetwork(),
        data: null,
        statusCode: 0,
      );
    } catch (_) {
      return ApiResult(
        success: false,
        message: _messageForNetwork(),
        data: null,
        statusCode: 0,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Auth
  // -------------------------------------------------------------------------

  static Future<ApiResult<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(
      () => http.post(
        ApiConfig.register(),
        headers: _jsonHeaders,
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      ),
      parse: (body) => body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : null,
    );
  }

  static Future<ApiResult<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) {
    return _run(
      () => http.post(
        ApiConfig.login(),
        headers: _jsonHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      ),
      parse: (body) => body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : null,
    );
  }

  // -------------------------------------------------------------------------
  // Wishlist
  // -------------------------------------------------------------------------

  static Future<ApiResult<List<Map<String, dynamic>>>> getWishlists(
    int userId,
  ) {
    return _run(
      () => http.get(ApiConfig.wishlists(userId), headers: _jsonHeaders),
      parse: (body) => body['data'] is List
          ? List<Map<String, dynamic>>.from(body['data'] as List)
          : const [],
    );
  }
}
