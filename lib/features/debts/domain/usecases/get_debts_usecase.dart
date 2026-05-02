import '../../../../core/utils/result.dart';
import '../entities/debt.dart';
import '../repositories/debt_repository.dart';

class GetDebtsUseCase {
  final DebtRepository repository;
  const GetDebtsUseCase(this.repository);

  /// Devuelve las deudas ordenadas por saldo ascendente (regla snowball).
  Future<Result<List<Debt>>> call() async {
    final result = await repository.getAll();
    return result.fold(
      onSuccess: (list) {
        final sorted = [...list]
          ..sort((a, b) => a.currentBalance.compareTo(b.currentBalance));
        return Success(sorted);
      },
      onFailure: (f) => FailureResult<List<Debt>>(f),
    );
  }
}
