/// Domain exceptions for Split Happens.
///
/// Every service wraps low-level failures in one of these typed exceptions so
/// the UI and providers can react with context instead of opaque errors.
library;

/// Base class for all Split Happens domain failures.
sealed class AppException implements Exception {
  /// Creates an exception with a human-readable [message] and an optional
  /// [cause] (the original error that triggered this failure).
  const AppException(this.message, [this.cause]);

  /// A human-readable description of what went wrong.
  final String message;

  /// The underlying error, if any, kept for debugging.
  final Object? cause;

  @override
  String toString() =>
      '$runtimeType: $message${cause == null ? '' : ' (cause: $cause)'}';
}

/// Thrown when on-device OCR fails to extract text from an image.
class OcrException extends AppException {
  /// Creates an [OcrException].
  const OcrException(super.message, [super.cause]);
}

/// Thrown when the LLM fails to parse OCR text into structured data.
///
/// Carries the [rawResponse] body when available to aid debugging of
/// malformed model output.
class ParseException extends AppException {
  /// Creates a [ParseException], optionally retaining the [rawResponse].
  const ParseException(super.message, [super.cause, this.rawResponse]);

  /// The raw response body returned by the LLM, if captured.
  final String? rawResponse;

  @override
  String toString() => rawResponse == null
      ? super.toString()
      : '${super.toString()}\nRaw response: $rawResponse';
}

/// Thrown when a network call fails or times out.
class NetworkException extends AppException {
  /// Creates a [NetworkException].
  const NetworkException(super.message, [super.cause]);
}
