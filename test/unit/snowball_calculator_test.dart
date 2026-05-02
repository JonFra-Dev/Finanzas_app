import 'package:finanzas_app/features/debts/domain/entities/debt.dart';
import 'package:finanzas_app/features/debts/domain/usecases/snowball_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SnowballCalculator calc;
  final start = DateTime(2026, 1, 1);

  setUp(() => calc = const SnowballCalculator());

  Debt debt({
    required String name,
    required double balance,
    double minimum = 50,
    double rate = 0,
  }) =>
      Debt(
        id: name,
        name: name,
        originalAmount: balance,
        currentBalance: balance,
        minimumPayment: minimum,
        annualInterestRate: rate,
        createdAt: start,
      );

  group('SnowballCalculator.calculate', () {
    test('lista vacía retorna null', () {
      final r = calc.calculate(
        debts: const [],
        monthlyExtra: 100,
        referenceDate: start,
      );
      expect(r, isNull);
    });

    test('una deuda sin interés se paga en (balance / pago) meses', () {
      final r = calc.calculate(
        debts: [debt(name: 'A', balance: 1000, minimum: 100)],
        monthlyExtra: 100, // total mensual = 200
        referenceDate: start,
      )!;
      // 1000 / 200 = 5 meses exactos
      expect(r.totalMonths, 5);
      expect(r.milestones.length, 1);
      expect(r.totalInterestPaid, 0);
    });

    test('ordena las deudas de menor a mayor saldo (regla snowball)', () {
      final big = debt(name: 'Hipoteca', balance: 100000, minimum: 500);
      final small = debt(name: 'Tarjeta', balance: 500, minimum: 50);
      final medium = debt(name: 'Carro', balance: 5000, minimum: 200);

      final r = calc.calculate(
        debts: [big, small, medium], // Orden no ordenado intencional
        monthlyExtra: 200,
        referenceDate: start,
      )!;

      // El primer milestone DEBE ser la deuda más pequeña (Tarjeta)
      expect(r.milestones.first.debt.name, 'Tarjeta');
      // El último milestone DEBE ser la más grande (Hipoteca)
      expect(r.milestones.last.debt.name, 'Hipoteca');
    });

    test('el snowball mensual = extra + suma de mínimos', () {
      final r = calc.calculate(
        debts: [
          debt(name: 'A', balance: 100, minimum: 30),
          debt(name: 'B', balance: 200, minimum: 50),
        ],
        monthlyExtra: 100,
        referenceDate: start,
      )!;
      expect(r.monthlySnowballPower, 180); // 100 + 30 + 50
    });

    test('ignora deudas ya pagadas (balance = 0)', () {
      final paid = debt(name: 'Pagada', balance: 0, minimum: 50);
      final active = debt(name: 'Activa', balance: 1000, minimum: 100);

      final r = calc.calculate(
        debts: [paid, active],
        monthlyExtra: 0,
        referenceDate: start,
      )!;
      expect(r.milestones.length, 1);
      expect(r.milestones.first.debt.name, 'Activa');
    });

    test('con interés alto, suma intereses al total pagado', () {
      // Una sola deuda con 24% anual = 2% mensual
      final r = calc.calculate(
        debts: [
          debt(name: 'TC', balance: 1000, minimum: 100, rate: 24),
        ],
        monthlyExtra: 0,
        referenceDate: start,
      )!;
      expect(r.totalInterestPaid, greaterThan(0));
      expect(r.totalMonths, greaterThan(10)); // > sin interés
    });
  });
}
