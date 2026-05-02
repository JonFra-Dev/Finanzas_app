import '../../../../core/utils/result.dart';
import '../repositories/debt_repository.dart';

class DeleteDebtUseCase {
  final DebtRepository repository;
  const DeleteDebtUseCase(this.repository);

  Future<Result<void>> call(String id) => repository.delete(id);
}
