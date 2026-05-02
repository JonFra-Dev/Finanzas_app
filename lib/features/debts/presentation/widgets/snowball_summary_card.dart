import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/snowball_plan.dart';

/// Tarjeta destacada del plan snowball — la "moneda visible" del feature.
class SnowballSummaryCard extends StatelessWidget {
  final SnowballPlan plan;
  final VoidCallback onTap;

  const SnowballSummaryCard({
    super.key,
    required this.plan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFmt = DateFormat('MMMM yyyy', 'es_CO');
    final years = plan.totalMonths ~/ 12;
    final months = plan.totalMonths % 12;

    return Card(
      color: AppColors.purple,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.ac_unit, color: AppColors.yellow, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Tu Plan Snowball',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Vas a estar libre de deudas en',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                years > 0
                    ? '$years año${years == 1 ? "" : "s"} y $months mes${months == 1 ? "" : "es"}'
                    : '$months mes${months == 1 ? "" : "es"}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Aprox. ${dateFmt.format(plan.freedomDate)}',
                style: const TextStyle(color: AppColors.yellow, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _Stat(
                      label: 'Intereses totales',
                      value: fmt.format(plan.totalInterestPaid),
                    ),
                  ),
                  Expanded(
                    child: _Stat(
                      label: 'Snowball mensual',
                      value: fmt.format(plan.monthlySnowballPower),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Ver plan completo',
                        style: TextStyle(color: AppColors.yellow)),
                    Icon(Icons.chevron_right, color: AppColors.yellow),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
