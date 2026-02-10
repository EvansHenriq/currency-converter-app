import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({
    super.key,
    this.message = 'Carregando dados...',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            message,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
