import 'package:equatable/equatable.dart';

import '../../domain/entities/debt.dart';
import '../../domain/entities/snowball_plan.dart';

class DebtsState extends Equatable {
  final bool isLoading;
  final List<Debt> debts;
  final double monthlyExtra;
  final SnowballPlan? plan;
  final String? errorMessage;

  const DebtsState({
    this.isLoading = false,
    this.debts = const [],
    this.monthlyExtra = 0,
    this.plan,
    this.errorMessage,
  });

  /// Suma del saldo actual de todas las deudas activas.
  double get totalBalance =>
      debts.where((d) => !d.isPaidOff).fold(0.0, (s, d) => s + d.currentBalance);

  /// La deuda más pequeña activa (next snowball target).
  Debt? get nextTarget {
    final active = debts.where((d) => !d.isPaidOff).toList()
      ..sort((a, b) => a.currentBalance.compareTo(b.currentBalance));
    return active.isEmpty ? null : active.first;
  }

  bool get isDebtFree => debts.every((d) => d.isPaidOff);

  DebtsState copyWith({
    bool? isLoading,
    List<Debt>? debts,
    double? monthlyExtra,
    SnowballPlan? plan,
    String? errorMessage,
    bool clearError = false,
    bool clearPlan = false,
  }) {
    return DebtsState(
      isLoading: isLoading ?? this.isLoading,
      debts: debts ?? this.debts,
      monthlyExtra: monthlyExtra ?? this.monthlyExtra,
      plan: clearPlan ? null : (plan ?? this.plan),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, debts, monthlyExtra, plan, errorMessage];
}
