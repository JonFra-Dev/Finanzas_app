import 'package:equatable/equatable.dart';

/// Una deuda activa del usuario (tarjeta de crédito, préstamo, hipoteca, etc.).
///
/// Sigue la filosofía del método Snowball de Dave Ramsey: lo importante es
/// el saldo actual, no la tasa de interés. Las deudas se ordenan de menor a
/// mayor saldo para ganar momentum psicológico al ir cerrándolas.
class Debt extends Equatable {
  final String id;
  final String name;
  final double originalAmount;
  final double currentBalance;
  final double minimumPayment;
  final double annualInterestRate; // Porcentaje (ej: 24.5 para 24.5%)
  final DateTime createdAt;

  const Debt({
    required this.id,
    required this.name,
    required this.originalAmount,
    required this.currentBalance,
    required this.minimumPayment,
    required this.annualInterestRate,
    required this.createdAt,
  });

  /// Porcentaje pagado de la deuda original (0-100).
  double get percentPaid {
    if (originalAmount <= 0) return 0;
    final paid = originalAmount - currentBalance;
    return (paid / originalAmount * 100).clamp(0, 100);
  }

  /// La deuda está pagada completamente.
  bool get isPaidOff => currentBalance <= 0;

  /// Tasa mensual derivada de la anual.
  double get monthlyInterestRate => annualInterestRate / 100 / 12;

  Debt copyWith({
    String? id,
    String? name,
    double? originalAmount,
    double? currentBalance,
    double? minimumPayment,
    double? annualInterestRate,
    DateTime? createdAt,
  }) {
    return Debt(
      id: id ?? this.id,
      name: name ?? this.name,
      originalAmount: originalAmount ?? this.originalAmount,
      currentBalance: currentBalance ?? this.currentBalance,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      annualInterestRate: annualInterestRate ?? this.annualInterestRate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        originalAmount,
        currentBalance,
        minimumPayment,
        annualInterestRate,
        createdAt,
      ];
}
