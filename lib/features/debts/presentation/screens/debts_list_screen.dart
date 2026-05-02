import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/debts_providers.dart';
import '../widgets/debt_card.dart';
import '../widgets/snowball_summary_card.dart';

class DebtsListScreen extends ConsumerStatefulWidget {
  const DebtsListScreen({super.key});

  @override
  ConsumerState<DebtsListScreen> createState() => _DebtsListScreenState();
}

class _DebtsListScreenState extends ConsumerState<DebtsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(debtsNotifierProvider.notifier).loadAll();
    });
  }

  Future<void> _editMonthlyExtra() async {
    final state = ref.read(debtsNotifierProvider);
    final controller =
        TextEditingController(text: state.monthlyExtra.toStringAsFixed(0));
    final v = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pago extra mensual'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cuánto extra puedes aportar cada mes para acelerar tu plan snowball.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                prefixText: '\$ ',
                labelText: 'Monto mensual',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final n = double.tryParse(controller.text.replaceAll(',', '.'));
              Navigator.pop(ctx, n);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (v != null && v >= 0) {
      await ref.read(debtsNotifierProvider.notifier).setMonthlyExtra(v);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(debtsNotifierProvider);
    final fmt = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis deudas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Pago extra mensual',
            onPressed: _editMonthlyExtra,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(debtsNotifierProvider.notifier).loadAll(),
        child: state.isLoading && state.debts.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.only(bottom: 100, top: 8),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // Header con saldo total
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.indigo,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saldo total a pagar',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fmt.format(state.totalBalance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pago extra mensual: ${fmt.format(state.monthlyExtra)}',
                          style: const TextStyle(
                            color: AppColors.yellow,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (state.plan != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SnowballSummaryCard(
                        plan: state.plan!,
                        onTap: () => context.push('/debts/plan'),
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'Ordenadas por saldo (snowball)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (state.debts.isEmpty && !state.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.celebration,
                              size: 64, color: AppColors.income),
                          SizedBox(height: 12),
                          Text(
                            '¡No tienes deudas registradas!\nAgrega una con el botón "Nueva".',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  else
                    ...state.debts.map(
                      (d) => DebtCard(
                        debt: d,
                        isTarget: state.nextTarget?.id == d.id,
                        onTap: () => context.push('/debts/${d.id}'),
                        onDelete: () => ref
                            .read(debtsNotifierProvider.notifier)
                            .remove(d.id),
                      ),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/debts/add'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva deuda'),
      ),
    );
  }
}
