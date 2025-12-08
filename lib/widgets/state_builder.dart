import 'package:flutter/material.dart';

/// Use this widget to handle loading, error, and success states
class StateBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext, T) onSuccess;
  final Widget Function(BuildContext, String)? onError;
  final Widget? onLoading;

  const StateBuilder({
    super.key,
    required this.future,
    required this.onSuccess,
    this.onError,
    this.onLoading,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return onLoading ?? _defaultLoading();
        }

        if (snapshot.hasError) {
          return onError?.call(context, snapshot.error.toString()) ??
              _defaultError(snapshot.error.toString());
        }

        if (snapshot.hasData) {
          return onSuccess(context, snapshot.data as T);
        }

        return _defaultError('No data available');
      },
    );
  }

  Widget _defaultLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _defaultError(String error) {
    return Center(
      child: Text('Error: $error'),
    );
  }
}
