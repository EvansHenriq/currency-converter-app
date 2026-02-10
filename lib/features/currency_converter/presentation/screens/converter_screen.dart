import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/convert_currency.dart';
import '../providers/currency_provider.dart';
import '../widgets/currency_input_field.dart';
import '../widgets/loading_indicator.dart';

class ConverterScreen extends ConsumerStatefulWidget {
  const ConverterScreen({super.key});

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen> {
  final _realController = TextEditingController();
  final _dolarController = TextEditingController();
  final _euroController = TextEditingController();

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currencyProvider.notifier).fetchRates();
    });
  }

  @override
  void dispose() {
    _realController.dispose();
    _dolarController.dispose();
    _euroController.dispose();
    super.dispose();
  }

  void _clearAll() {
    _realController.clear();
    _dolarController.clear();
    _euroController.clear();
  }

  void _updateFields(ConversionResult result, CurrencyType source) {
    if (_isUpdating) return;
    _isUpdating = true;

    if (source != CurrencyType.brl) {
      _realController.text = result.brl.toStringAsFixed(2);
    }
    if (source != CurrencyType.usd) {
      _dolarController.text = result.usd.toStringAsFixed(2);
    }
    if (source != CurrencyType.eur) {
      _euroController.text = result.eur.toStringAsFixed(2);
    }

    _isUpdating = false;
  }

  void _onCurrencyChanged(String text, CurrencyType type) {
    if (_isUpdating) return;

    if (text.isEmpty) {
      _clearAll();
      ref.read(currencyProvider.notifier).clearConversion();
      return;
    }

    final amount = double.tryParse(text);
    if (amount != null) {
      ref.read(currencyProvider.notifier).convert(amount, type);

      final state = ref.read(currencyProvider);
      if (state is CurrencyLoaded && state.conversionResult != null) {
        _updateFields(state.conversionResult!, type);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor de Moedas'),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(CurrencyState state) {
    return switch (state) {
      CurrencyInitial() || CurrencyLoading() => const LoadingIndicator(),
      CurrencyError(:final message) => _buildError(message),
      CurrencyLoaded() => _buildConverter(),
    };
  }

  Widget _buildError(String message) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro: $message',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(currencyProvider.notifier).fetchRates(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConverter() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.currency_exchange_rounded,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            'Converter moedas',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CurrencyInputField(
                    label: 'Real',
                    prefix: 'R\$ ',
                    controller: _realController,
                    onChanged: (text) =>
                        _onCurrencyChanged(text, CurrencyType.brl),
                  ),
                  const SizedBox(height: 16),
                  CurrencyInputField(
                    label: 'Dolar',
                    prefix: 'US\$ ',
                    controller: _dolarController,
                    onChanged: (text) =>
                        _onCurrencyChanged(text, CurrencyType.usd),
                  ),
                  const SizedBox(height: 16),
                  CurrencyInputField(
                    label: 'Euro',
                    prefix: '\u20AC ',
                    controller: _euroController,
                    onChanged: (text) =>
                        _onCurrencyChanged(text, CurrencyType.eur),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
