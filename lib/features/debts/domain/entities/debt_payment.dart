import 'package:equatable/equatable.dart';

/// Pago aplicado a una deuda específica.
class DebtPayment extends Equatable {
  final String id;
  final String debtId;
  final double amount;
  final DateTime date;
  final String? note;

  const DebtPayment({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.date,
    this.note,
  });

  @override
  List<Object?> get props => [id, debtId, amount, date, note];
}
