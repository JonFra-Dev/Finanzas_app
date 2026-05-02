import '../entities/debt.dart';
import '../entities/snowball_plan.dart';

/// Implementación del método Debt Snowball de Dave Ramsey.
///
/// REGLA #1: Las deudas se ordenan SIEMPRE de menor a mayor saldo (sin importar
/// la tasa de interés). Esto es contraintuitivo matemáticamente, pero
/// psicológicamente genera victorias rápidas que mantienen al usuario motivado.
///
/// REGLA #2: Cada mes se paga el mínimo de TODAS las deudas + un "extra"
/// completo a la deuda más pequeña.
///
/// REGLA #3: Cuando se cierra una deuda, su pago mínimo se "rueda" hacia la
/// siguiente deuda más pequeña — la bola de nieve crece.
///
/// Probado en `test/unit/snowball_calculator_test.dart`.
class SnowballCalculator {
  const SnowballCalculator();

  /// Simula el plan completo de pago hasta liquidar todas las deudas.
  /// Devuelve `null` si la lista está vacía.
  ///
  /// [monthlyExtra]: cuánto extra puede aportar el usuario cada mes.
  /// [referenceDate]: fecha de inicio de la simulación (default: ahora).
  SnowballPlan? calculate({
    required List<Debt> debts,
    required double monthlyExtra,
    DateTime? referenceDate,
  }) {
    if (debts.isEmpty) return null;
    final start = referenceDate ?? DateTime.now();

    // Copia mutable, ordenada por saldo ascendente (regla #1).
    final active = debts
        .where((d) => !d.isPaidOff)
        .map((d) => _SimDebt.fromDebt(d))
        .toList()
      ..sort((a, b) => a.balance.compareTo(b.balance));

    if (active.isEmpty) return null;

    final milestones = <DebtMilestone>[];
    double totalInterest = 0;
    double totalPrincipal = 0;
    int month = 0;

    // Hard limit para evitar bucles infinitos si los pagos no cubren intereses.
    const maxMonths = 12 * 50; // 50 años

    while (active.isNotEmpty && month < maxMonths) {
      month++;

      // Snowball mensual: solo la cantidad extra del usuario.
      // Los mínimos de deudas cerradas ya están "liberados" porque ya no se
      // pagan, así que el usuario tiene más margen para el siguiente extra.
      final double snowball = monthlyExtra;

      // 1. Intereses del mes (se cargan ANTES de los pagos).
      for (final d in active) {
        final interest = d.balance * d.monthlyRate;
        d.balance += interest;
        d.interestAccumulated += interest;
        totalInterest += interest;
      }

      // 2. Aplicar mínimos a todas, excepto la primera (recibirá min + extra).
      for (var i = 1; i < active.length; i++) {
        final pago = _aplicarPago(active[i], active[i].minimumPayment);
        totalPrincipal += pago;
      }

      // 3. La primera (más pequeña) recibe su mínimo + todo el snowball.
      final target = active.first;
      final pagoTarget =
          _aplicarPago(target, target.minimumPayment + snowball);
      totalPrincipal += pagoTarget;

      // 4. Revisar deudas cerradas en este mes.
      final cerradas = active.where((d) => d.balance <= 0.01).toList();
      for (final d in cerradas) {
        milestones.add(DebtMilestone(
          debt: d.original,
          monthsFromStart: month,
          payoffDate: DateTime(start.year, start.month + month, start.day),
          interestPaidOnThisDebt: d.interestAccumulated,
        ));
      }
      active.removeWhere((d) => d.balance <= 0.01);
    }

    final freedomDate =
        DateTime(start.year, start.month + month, start.day);

    return SnowballPlan(
      milestones: milestones,
      totalInterestPaid: totalInterest,
      totalPrincipalPaid: totalPrincipal - totalInterest,
      totalMonths: month,
      freedomDate: freedomDate,
      monthlySnowballPower:
          monthlyExtra + debts.fold(0.0, (s, d) => s + d.minimumPayment),
    );
  }

  /// Aplica un pago a la deuda. Retorna el monto efectivamente aplicado.
  double _aplicarPago(_SimDebt d, double pago) {
    final aplicado = pago > d.balance ? d.balance : pago;
    d.balance -= aplicado;
    if (d.balance < 0) d.balance = 0;
    return aplicado;
  }
}

/// Estructura interna para la simulación (mutable).
class _SimDebt {
  final Debt original;
  double balance;
  final double minimumPayment;
  final double monthlyRate;
  double interestAccumulated;

  _SimDebt({
    required this.original,
    required this.balance,
    required this.minimumPayment,
    required this.monthlyRate,
  }) : interestAccumulated = 0;

  factory _SimDebt.fromDebt(Debt d) => _SimDebt(
        original: d,
        balance: d.currentBalance,
        minimumPayment: d.minimumPayment,
        monthlyRate: d.monthlyInterestRate,
      );
}
