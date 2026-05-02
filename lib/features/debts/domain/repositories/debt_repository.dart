import '../../../../core/utils/result.dart';
import '../entities/debt.dart';
import '../entities/debt_payment.dart';

abstract class DebtRepository {
  Future<Result<List<Debt>>> getAll();
  Future<Result<Debt>> add(Debt debt);
  Future<Result<Debt>> update(Debt debt);
  Future<Result<void>> delete(String id);

  Future<Result<List<DebtPayment>>> getPaymentsForDebt(String debtId);
  Future<Result<DebtPayment>> addPayment(DebtPayment payment);

  /// Cantidad extra que el usuario puede aportar mensualmente al snowball.
  Future<Result<void>> setMonthlyExtra(double amount);
  Future<Result<double>> getMonthlyExtra();
}
