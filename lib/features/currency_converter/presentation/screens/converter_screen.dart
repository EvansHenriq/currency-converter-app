import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
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
  final Map<String, TextEditingController> _controllers = {};
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
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String code) {
    return _controllers.putIfAbsent(
      code,
      () => TextEditingController(
        text: CurrencyFormatter.formatValue(0, code),
      ),
    );
  }

  void _disposeController(String code) {
    _controllers[code]?.dispose();
    _controllers.remove(code);
  }

  void _clearAll(List<String> activeCurrencies) {
    for (final code in activeCurrencies) {
      _controllers[code]?.clear();
    }
  }

  void _updateFields(
    ConversionResult result,
    String sourceCode,
    List<String> activeCurrencies,
  ) {
    if (_isUpdating) return;
    _isUpdating = true;

    for (final code in activeCurrencies) {
      if (code != sourceCode) {
        _controllers[code]?.text = CurrencyFormatter.formatValue(result[code], code);
      }
    }

    _isUpdating = false;
  }

  void _recalculateFromExistingValues() {
    final currentState = ref.read(currencyProvider);
    if (currentState is! CurrencyLoaded) return;

    for (final code in currentState.activeCurrencies) {
      final controller = _controllers[code];
      if (controller != null && controller.text.isNotEmpty) {
        final amount = CurrencyFormatter.parseValue(controller.text, code);
        if (amount != null && amount > 0) {
          _onCurrencyChanged(controller.text, code);
          return;
        }
      }
    }
  }

  void _onCurrencyChanged(String text, String currencyCode) {
    if (_isUpdating) return;

    final currentState = ref.read(currencyProvider);
    if (currentState is! CurrencyLoaded) return;

    if (text.isEmpty) {
      _clearAll(currentState.activeCurrencies);
      return;
    }

    final amount = CurrencyFormatter.parseValue(text, currencyCode);
    if (amount != null) {
      final ratesMap = <String, double>{};
      for (final code in currentState.activeCurrencies) {
        ratesMap[code] = currentState.rates.rateFor(code);
      }

      final result = ConvertCurrency()(
        ConvertCurrencyParams(
          amount: amount,
          fromCurrency: currencyCode,
          fromRate: currentState.rates.rateFor(currencyCode),
          rates: ratesMap,
        ),
      );

      _updateFields(result, currencyCode, currentState.activeCurrencies);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Conversor de Moedas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(CurrencyState state) {
    return switch (state) {
      CurrencyInitial() || CurrencyLoading() => const LoadingIndicator(),
      CurrencyError(
        :final message
      ) =>
        _buildError(message),
      CurrencyLoaded() => _buildConverter(state),
    };
  }

  Widget _buildError(String message) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 32,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Falha ao carregar',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref.read(currencyProvider.notifier).fetchRates(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConverter(CurrencyLoaded state) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 32),
              _buildConverterCard(theme, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.currency_exchange_rounded,
            size: 32,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Converter moedas',
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Valores atualizados em tempo real',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildConverterCard(ThemeData theme, CurrencyLoaded state) {
    final activeCurrencies = state.activeCurrencies;
    final canDelete = state.canDelete;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            for (int i = 0; i < activeCurrencies.length; i++) ...[
              if (i > 0) _buildDivider(theme),
              _buildCurrencyRow(activeCurrencies[i], canDelete, theme),
            ],
            if (state.availableToAdd.isNotEmpty) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _showAddCurrencySheet(state),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Adicionar moeda'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyRow(String code, bool canDelete, ThemeData theme) {
    return Row(
      key: ValueKey(code),
      children: [
        Expanded(
          child: CurrencyInputField(
            label: CurrencyMetadata.labelFor(code),
            prefix: CurrencyMetadata.prefixFor(code),
            currencyCode: code,
            controller: _controllerFor(code),
            onChanged: (text) => _onCurrencyChanged(text, code),
          ),
        ),
        if (canDelete)
          IconButton(
            icon: Icon(
              Icons.remove_circle_outline,
              color: theme.colorScheme.error,
            ),
            tooltip: 'Remover $code',
            onPressed: () {
              _disposeController(code);
              ref.read(currencyProvider.notifier).removeCurrency(code);
            },
          ),
      ],
    );
  }

  void _showAddCurrencySheet(CurrencyLoaded state) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final available = state.availableToAdd;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Adicionar moeda',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(height: 1),
              ListView.builder(
                shrinkWrap: true,
                itemCount: available.length,
                itemBuilder: (context, index) {
                  final code = available[index];
                  final name = code == 'BRL' ? 'Real Brasileiro' : state.rates[code]?.name ?? code;
                  return ListTile(
                    leading: Text(
                      CurrencyMetadata.flagFor(code),
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(code),
                    subtitle: Text(name),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(currencyProvider.notifier).addCurrency(code);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _recalculateFromExistingValues();
                      });
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.swap_vert_rounded,
              size: 20,
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
