import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/debt.dart';
import '../entities/debt_payment.dart';
import '../repositories/debt_repository.dart';

/// Aplica un pago a una deuda y actualiza el saldo.
class MakePaymentUseCase {
  final DebtRepository repository;
  const MakePaymentUseCase(this.repository);

  Future<Result<Debt>> call({
    required Debt debt,
    required double amount,
    String? note,
  }) async {
    if (amount <= 0) {
      return const FailureResult(
        ValidationFailure('El monto debe ser positivo'),
      );
    }
    final applied = amount > debt.currentBalance ? debt.currentBalance : amount;

    final payment = DebtPayment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      debtId: debt.id,
      amount: applied,
      date: DateTime.now(),
      note: note,
    );

    final paymentResult = await repository.addPayment(payment);
    if (paymentResult.isFailure) {
      return FailureResult(paymentResult.failureOrNull!);
    }

    final updatedDebt = debt.copyWith(
      currentBalance: debt.currentBalance - applied,
    );
    return repository.update(updatedDebt);
  }
}
