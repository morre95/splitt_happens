import 'package:flutter/material.dart';

import '../core/exceptions.dart';

/// A centred error state with a retry button, shown for failed [AsyncValue]s.
class ErrorRetryView extends StatelessWidget {
  /// Creates an [ErrorRetryView] for [error], calling [onRetry] when tapped.
  const ErrorRetryView({
    required this.error,
    required this.onRetry,
    super.key,
  });

  /// The error to display. [AppException]s show their friendly message.
  final Object error;

  /// Invoked when the user taps "Retry".
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final String message =
        error is AppException ? (error as AppException).message : '$error';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
