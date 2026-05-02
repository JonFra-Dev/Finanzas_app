import 'package:equatable/equatable.dart';

import 'debt.dart';

/// Resultado de la simulación del método snowball para un set de deudas.
class SnowballPlan extends Equatable {
  final List<DebtMilestone> milestones;
  final double totalInterestPaid;
  final double totalPrincipalPaid;
  final int totalMonths;
  final DateTime freedomDate;
  final double monthlySnowballPower;

  const SnowballPlan({
    required this.milestones,
    required this.totalInterestPaid,
    required this.totalPrincipalPaid,
    required this.totalMonths,
    required this.freedomDate,
    required this.monthlySnowballPower,
  });

  double get totalPaid => totalPrincipalPaid + totalInterestPaid;

  @override
  List<Object?> get props => [
        milestones,
        totalInterestPaid,
        totalPrincipalPaid,
        totalMonths,
        freedomDate,
        monthlySnowballPower,
      ];
}

/// Hito: cuándo se termina de pagar cada deuda según el plan.
class DebtMilestone extends Equatable {
  final Debt debt;
  final int monthsFromStart;
  final DateTime payoffDate;
  final double interestPaidOnThisDebt;

  const DebtMilestone({
    required this.debt,
    required this.monthsFromStart,
    required this.payoffDate,
    required this.interestPaidOnThisDebt,
  });

  @override
  List<Object?> get props =>
      [debt, monthsFromStart, payoffDate, interestPaidOnThisDebt];
}
