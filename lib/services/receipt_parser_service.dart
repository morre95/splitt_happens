import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../core/exceptions.dart';
import '../models/receipt_parse_result.dart';
import 'backend_client.dart';

/// System prompt instructing the LLM to return strict JSON for a receipt.
const String _systemPrompt = '''
You are a receipt parser. Extract all purchased items from the raw OCR text of a receipt.
Return ONLY a valid JSON object — no markdown, no explanation, no code fences.
The JSON must match this exact schema:
{
  "items": [{"name": "string", "quantity": number, "unit_price": number}],
  "subtotal": number,
  "tax": number,
  "tip": number,
  "total": number
}
Rules:
- Expand abbreviated item names to readable English where obvious (e.g. "CHKN SNDWCH" → "Chicken Sandwich").
- quantity defaults to 1 if not shown.
- All prices are plain numbers, no currency symbols.
- If tax, tip, or subtotal are not found, set them to 0.
- Do not include header lines, store name, address, phone number, or payment method lines as items.''';

/// Converts raw OCR text into a structured [ReceiptParseResult] by calling the
/// Split Happens backend, which proxies the request through LiteLLM.
class ReceiptParserService {
  /// Creates a [ReceiptParserService].
  ///
  /// An [http.Client], [BackendClient], and the [model] may be injected for
  /// testing; all fall back to sensible defaults.
  ReceiptParserService({
    http.Client? client,
    BackendClient? backend,
    this.model = BackendConfig.defaultModel,
  })  : _client = client ?? http.Client(),
        _backend = backend ?? BackendClient(client: client);

  final http.Client _client;
  final BackendClient _backend;

  /// The model id used for parsing (forwarded to the backend).
  final String model;

  /// Parses [ocrText] into a [ReceiptParseResult].
  ///
  /// Authentication uses the backend app token; if the token is rejected it is
  /// refreshed once and the request retried. Throws [NetworkException] on
  /// timeout or transport failure, and [ParseException] when the response is
  /// malformed or contains no items.
  Future<ReceiptParseResult> parse(String ocrText) async {
    http.Response response = await _post(ocrText, await _backend.ensureToken());

    // The backend returns 401 when the app token has expired/rotated. Refresh
    // it (same device → same user, so budget/spend persist) and retry once.
    if (response.statusCode == 401) {
      response = await _post(ocrText, await _backend.refreshToken());
    }

    if (response.statusCode != 200) {
      throw ParseException(
        'Parsing service returned status ${response.statusCode}.',
        null,
        response.body,
      );
    }

    return _decode(response.body);
  }

  /// Posts the OCR text to the backend chat-completions proxy using [token].
  Future<http.Response> _post(String ocrText, String token) async {
    final Uri uri = Uri.parse(
      '${BackendConfig.baseUrl}${BackendConfig.chatCompletionsPath}',
    );
    final Map<String, dynamic> payload = <String, dynamic>{
      'model': model,
      'temperature': BackendConfig.temperature,
      'messages': <Map<String, String>>[
        <String, String>{'role': 'system', 'content': _systemPrompt},
        <String, String>{'role': 'user', 'content': ocrText},
      ],
    };

    try {
      return await _client
          .post(
            uri,
            headers: <String, String>{
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(BackendConfig.requestTimeout);
    } on TimeoutException catch (error) {
      throw NetworkException(
        'Parsing timed out. Check your connection or try a different model.',
        error,
      );
    } catch (error) {
      throw NetworkException('Failed to reach the parsing service.', error);
    }
  }

  /// Decodes the OpenAI-compatible envelope, extracts the model's message,
  /// and validates the embedded JSON.
  ReceiptParseResult _decode(String body) {
    final String content;
    try {
      final Map<String, dynamic> envelope =
          jsonDecode(body) as Map<String, dynamic>;
      final List<dynamic> choices = envelope['choices'] as List<dynamic>;
      final Map<String, dynamic> message =
          (choices.first as Map<String, dynamic>)['message']
              as Map<String, dynamic>;
      content = message['content'] as String;
    } catch (error) {
      throw ParseException(
        'Unexpected response shape from parsing service.',
        error,
        body,
      );
    }

    final ReceiptParseResult result;
    try {
      final Map<String, dynamic> json =
          jsonDecode(_stripFences(content)) as Map<String, dynamic>;
      result = ReceiptParseResult.fromJson(json);
    } catch (error) {
      throw ParseException(
        'Model did not return valid receipt JSON.',
        error,
        content,
      );
    }

    if (result.items.isEmpty) {
      throw ParseException(
        'No items were found on the receipt.',
        null,
        content,
      );
    }
    return result;
  }

  /// Strips markdown code fences the model may add despite instructions.
  String _stripFences(String content) {
    final String trimmed = content.trim();
    if (!trimmed.startsWith('```')) {
      return trimmed;
    }
    final int firstNewline = trimmed.indexOf('\n');
    final int lastFence = trimmed.lastIndexOf('```');
    if (firstNewline == -1 || lastFence <= firstNewline) {
      return trimmed;
    }
    return trimmed.substring(firstNewline + 1, lastFence).trim();
  }
}
