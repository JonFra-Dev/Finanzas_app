import 'package:finanzas_app/core/utils/result.dart';
import 'package:finanzas_app/features/debts/data/datasources/debt_local_datasource.dart';
import 'package:finanzas_app/features/debts/data/repositories/debt_repository_impl.dart';
import 'package:finanzas_app/features/debts/domain/entities/debt.dart';
import 'package:finanzas_app/features/debts/domain/entities/debt_payment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DebtRepositoryImpl repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = DebtRepositoryImpl(DebtLocalDataSource(prefs));
  });

  Debt buildDebt(String id, double balance) => Debt(
        id: id,
        name: 'Debt $id',
        originalAmount: balance,
        currentBalance: balance,
        minimumPayment: balance * 0.05,
        annualInterestRate: 12,
        createdAt: DateTime(2026, 1, 1),
      );

  test('add y getAll persisten/leen correctamente', () async {
    await repo.add(buildDebt('1', 1000));
    await repo.add(buildDebt('2', 2000));
    final r = await repo.getAll();
    expect(r, isA<Success>());
    expect(r.valueOrNull!.length, 2);
  });

  test('update modifica el saldo de una deuda existente', () async {
    await repo.add(buildDebt('1', 1000));
    await repo.update(buildDebt('1', 1000).copyWith(currentBalance: 500));
    final list = (await repo.getAll()).valueOrNull!;
    expect(list.length, 1);
    expect(list.first.currentBalance, 500);
  });

  test('delete remueve la deuda y todos sus pagos', () async {
    await repo.add(buildDebt('1', 1000));
    await repo.addPayment(DebtPayment(
      id: 'p1',
      debtId: '1',
      amount: 100,
      date: DateTime.now(),
    ));
    await repo.delete('1');
    expect((await repo.getAll()).valueOrNull, isEmpty);
    expect((await repo.getPaymentsForDebt('1')).valueOrNull, isEmpty);
  });

  test('setMonthlyExtra y getMonthlyExtra funcionan', () async {
    expect((await repo.getMonthlyExtra()).valueOrNull, 0);
    await repo.setMonthlyExtra(250);
    expect((await repo.getMonthlyExtra()).valueOrNull, 250);
  });
}
