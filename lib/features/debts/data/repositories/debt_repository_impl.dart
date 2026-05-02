import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/debt.dart';
import '../../domain/entities/debt_payment.dart';
import '../../domain/repositories/debt_repository.dart';
import '../datasources/debt_local_datasource.dart';
import '../models/debt_model.dart';
import '../models/debt_payment_model.dart';

class DebtRepositoryImpl implements DebtRepository {
  final DebtLocalDataSource localDataSource;
  DebtRepositoryImpl(this.localDataSource);

  @override
  Future<Result<List<Debt>>> getAll() async {
    try {
      return Success(await localDataSource.getAll());
    } catch (e) {
      return FailureResult(CacheFailure('Error al leer deudas: $e'));
    }
  }

  @override
  Future<Result<Debt>> add(Debt debt) async {
    try {
      final saved = await localDataSource.add(DebtModel.fromEntity(debt));
      return Success(saved);
    } catch (e) {
      return FailureResult(CacheFailure('Error al guardar deuda: $e'));
    }
  }

  @override
  Future<Result<Debt>> update(Debt debt) async {
    try {
      final saved = await localDataSource.update(DebtModel.fromEntity(debt));
      return Success(saved);
    } catch (e) {
      return FailureResult(CacheFailure('Error al actualizar deuda: $e'));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await localDataSource.delete(id);
      return const Success(null);
    } catch (e) {
      return FailureResult(CacheFailure('Error al eliminar deuda: $e'));
    }
  }

  @override
  Future<Result<List<DebtPayment>>> getPaymentsForDebt(String debtId) async {
    try {
      return Success(await localDataSource.getPaymentsForDebt(debtId));
    } catch (e) {
      return FailureResult(CacheFailure('Error al leer pagos: $e'));
    }
  }

  @override
  Future<Result<DebtPayment>> addPayment(DebtPayment payment) async {
    try {
      final saved = await localDataSource
          .addPayment(DebtPaymentModel.fromEntity(payment));
      return Success(saved);
    } catch (e) {
      return FailureResult(CacheFailure('Error al guardar pago: $e'));
    }
  }

  @override
  Future<Result<void>> setMonthlyExtra(double amount) async {
    try {
      await localDataSource.setMonthlyExtra(amount);
      return const Success(null);
    } catch (e) {
      return FailureResult(CacheFailure('Error al guardar extra: $e'));
    }
  }

  @override
  Future<Result<double>> getMonthlyExtra() async {
    try {
      return Success(localDataSource.getMonthlyExtra());
    } catch (e) {
      return FailureResult(CacheFailure('Error al leer extra: $e'));
    }
  }
}
