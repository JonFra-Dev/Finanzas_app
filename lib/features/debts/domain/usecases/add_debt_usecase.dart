import '../../../../core/utils/result.dart';
import '../entities/debt.dart';
import '../repositories/debt_repository.dart';

class AddDebtUseCase {
  final DebtRepository repository;
  const AddDebtUseCase(this.repository);

  Future<Result<Debt>> call(Debt debt) => repository.add(debt);
}
