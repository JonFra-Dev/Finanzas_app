import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/debts_providers.dart';

class SnowballPlanScreen extends ConsumerWidget {
  const SnowballPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(debtsNotifierProvider);
    final plan = state.plan;
    final fmt = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFmt = DateFormat('dd MMMM yyyy', 'es_CO');

    return Scaffold(
      appBar: AppBar(title: const Text('Plan Snowball')),
      body: plan == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Aún no tienes deudas para calcular un plan.\n'
                  'Agrega tus deudas en la pantalla anterior.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: AppColors.indigo,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fecha de libertad financiera',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFmt.format(plan.freedomDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${plan.totalMonths} meses · '
                          '${(plan.totalMonths / 12).toStringAsFixed(1)} años',
                          style: const TextStyle(
                            color: AppColors.yellow,
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
                        leading: const Icon(Icons.savings,
                            color: AppColors.income),
                        title: const Text('Capital total'),
                        trailing: Text(
                          fmt.format(plan.totalPrincipalPaid),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(Icons.warning_amber,
                            color: AppColors.warning),
                        title: const Text('Intereses totales'),
                        trailing: Text(
                          fmt.format(plan.totalInterestPaid),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(Icons.bolt,
                            color: AppColors.purple),
                        title: const Text('Snowball mensual'),
                        subtitle: const Text(
                            'Pagos mínimos + tu extra mensual'),
                        trailing: Text(
                          fmt.format(plan.monthlySnowballPower),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
                  child: Text(
                    'Línea de tiempo de tus victorias',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                ...plan.milestones.asMap().entries.map((entry) {
                  final i = entry.key;
                  final m = entry.value;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.income,
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(m.debt.name),
                      subtitle: Text(
                        '${m.monthsFromStart} meses · ${dateFmt.format(m.payoffDate)}\n'
                        'Intereses pagados: ${fmt.format(m.interestPaidOnThisDebt)}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.check_circle,
                          color: AppColors.income),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.purple),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              color: AppColors.purple),
                          SizedBox(width: 8),
                          Text(
                            'El método de Dave Ramsey',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Atacas SIEMPRE la deuda más pequeña primero, '
                        'sin importar la tasa de interés. Cada victoria '
                        'genera momentum psicológico que te mantiene en el plan.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
