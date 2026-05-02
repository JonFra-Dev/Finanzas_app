import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../providers/debts_providers.dart';

class DebtDetailScreen extends ConsumerStatefulWidget {
  final String debtId;
  const DebtDetailScreen({super.key, required this.debtId});

  @override
  ConsumerState<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends ConsumerState<DebtDetailScreen> {
  Future<void> _registerPayment() async {
    final state = ref.read(debtsNotifierProvider);
    final debt = state.debts.firstWhere((d) => d.id == widget.debtId);
    final controller = TextEditingController();

    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar pago'),
        content: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: InputDecoration(
              prefixText: '\$ ',
              labelText: 'Monto',
              helperText:
                  'Saldo actual: ${NumberFormat.currency(locale: "es_CO", symbol: "\$", decimalDigits: 0).format(debt.currentBalance)}',
            ),
            validator: Validators.amount,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(controller.text.replaceAll(',', '.'));
              Navigator.pop(ctx, v);
            },
            child: const Text('Pagar'),
          ),
        ],
      ),
    );

    if (amount != null && amount > 0 && mounted) {
      final ok = await ref.read(debtsNotifierProvider.notifier).registerPayment(
            debt: debt,
            amount: amount,
          );
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(amount >= debt.currentBalance
                ? '🎉 ¡Deuda pagada completa!'
                : 'Pago registrado'),
            backgroundColor: AppColors.income,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(debtsNotifierProvider);
    final debt = state.debts.where((d) => d.id == widget.debtId).firstOrNull;

    if (debt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(child: Text('Deuda no encontrada')),
      );
    }

    final fmt = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFmt = DateFormat('dd MMMM yyyy', 'es_CO');

    return Scaffold(
      appBar: AppBar(title: Text(debt.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldo pendiente',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fmt.format(debt.currentBalance),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: debt.isPaidOff
                          ? AppColors.income
                          : AppColors.expense,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (debt.percentPaid / 100).clamp(0, 1),
                      minHeight: 10,
                      backgroundColor: AppColors.cardLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        debt.isPaidOff
                            ? AppColors.income
                            : AppColors.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Has pagado ${debt.percentPaid.toStringAsFixed(1)}% de '
                    '${fmt.format(debt.originalAmount)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.payments_outlined,
                      color: AppColors.indigo),
                  title: const Text('Pago mínimo mensual'),
                  trailing: Text(
                    fmt.format(debt.minimumPayment),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.percent, color: AppColors.purple),
                  title: const Text('Tasa de interés anual'),
                  trailing: Text(
                    '${debt.annualInterestRate.toStringAsFixed(2)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading:
                      const Icon(Icons.event, color: AppColors.textSecondary),
                  title: const Text('Registrada el'),
                  trailing: Text(dateFmt.format(debt.createdAt)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!debt.isPaidOff)
            ElevatedButton.icon(
              onPressed: _registerPayment,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Registrar pago'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.income.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.income),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.income),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¡Felicitaciones! Pagaste esta deuda completa. '
                      'El snowball ahora rueda hacia la siguiente.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
