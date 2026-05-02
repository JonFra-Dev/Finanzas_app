import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/debt.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/usecases/add_debt_usecase.dart';
import '../../domain/usecases/delete_debt_usecase.dart';
import '../../domain/usecases/get_debts_usecase.dart';
import '../../domain/usecases/make_payment_usecase.dart';
import '../../domain/usecases/snowball_calculator.dart';
import 'debts_state.dart';

class DebtsNotifier extends StateNotifier<DebtsState> {
  final GetDebtsUseCase getDebts;
  final AddDebtUseCase addDebt;
  final DeleteDebtUseCase deleteDebt;
  final MakePaymentUseCase makePayment;
  final DebtRepository repository;
  final SnowballCalculator calculator;

  DebtsNotifier({
    required this.getDebts,
    required this.addDebt,
    required this.deleteDebt,
    required this.makePayment,
    required this.repository,
    required this.calculator,
  }) : super(const DebtsState());

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final debtsResult = await getDebts();
    final extraResult = await repository.getMonthlyExtra();

    debtsResult.fold(
      onSuccess: (debts) {
        final extra = extraResult.valueOrNull ?? 0;
        final plan = calculator.calculate(
          debts: debts,
          monthlyExtra: extra,
        );
        state = state.copyWith(
          isLoading: false,
          debts: debts,
          monthlyExtra: extra,
          plan: plan,
        );
      },
      onFailure: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
      },
    );
  }

  Future<bool> add(Debt debt) async {
    final result = await addDebt(debt);
    return result.fold(
      onSuccess: (_) async {
        await loadAll();
        return true;
      },
      onFailure: (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
    );
  }

  Future<void> remove(String id) async {
    await deleteDebt(id);
    await loadAll();
  }

  Future<bool> registerPayment({
    required Debt debt,
    required double amount,
    String? note,
  }) async {
    final result = await makePayment(debt: debt, amount: amount, note: note);
    return result.fold(
      onSuccess: (_) async {
        await loadAll();
        return true;
      },
      onFailure: (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
    );
  }

  Future<void> setMonthlyExtra(double amount) async {
    await repository.setMonthlyExtra(amount);
    await loadAll();
  }

  void clearError() => state = state.copyWith(clearError: true);
}
