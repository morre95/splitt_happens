import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../core/constants.dart';
import '../core/exceptions.dart';

/// Manages the device's identity and backend app token.
///
/// The `device_id` is generated once per install and kept in secure storage; it
/// is the durable identity the backend uses to keep logging usage to the same
/// user, even when the disposable app token is refreshed. During the current
/// testing phase the device auto-registers on first use — there is no login.
class BackendClient {
  /// Creates a [BackendClient]. An [http.Client] and [FlutterSecureStorage]
  /// may be injected for testing.
  BackendClient({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  final http.Client _client;
  final FlutterSecureStorage _storage;

  static const Uuid _uuid = Uuid();

  /// Returns a usable app token, registering the device if none is cached.
  Future<String> ensureToken() async {
    final String? cached = await _storage.read(key: SettingsKeys.appToken);
    if (cached != null && cached.isNotEmpty) return cached;
    return refreshToken();
  }

  /// Forces a fresh registration, returning (and caching) a new app token.
  ///
  /// Called on first use and whenever the backend rejects the current token.
  Future<String> refreshToken() async {
    final String deviceId = await _deviceId();
    final Uri uri = Uri.parse('${BackendConfig.baseUrl}${BackendConfig.registerPath}');

    final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: const <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(<String, String>{'device_id': deviceId}),
          )
          .timeout(BackendConfig.requestTimeout);
    } on TimeoutException catch (error) {
      throw NetworkException('Registration timed out. Check your connection.', error);
    } catch (error) {
      throw NetworkException('Failed to reach the Split Happens backend.', error);
    }

    if (response.statusCode != 200) {
      throw NetworkException(
        'Backend registration failed (status ${response.statusCode}).',
        response.body,
      );
    }

    final String token;
    try {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      token = data['token'] as String;
    } catch (error) {
      throw NetworkException('Unexpected registration response.', error);
    }

    await _storage.write(key: SettingsKeys.appToken, value: token);
    return token;
  }

  /// Returns the persisted device id, generating and storing one on first use.
  Future<String> _deviceId() async {
    final String? existing = await _storage.read(key: SettingsKeys.deviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final String generated = _uuid.v4();
    await _storage.write(key: SettingsKeys.deviceId, value: generated);
    return generated;
  }
}
