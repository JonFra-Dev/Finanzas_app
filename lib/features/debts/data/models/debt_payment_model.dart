import '../../domain/entities/debt_payment.dart';

class DebtPaymentModel extends DebtPayment {
  const DebtPaymentModel({
    required super.id,
    required super.debtId,
    required super.amount,
    required super.date,
    super.note,
  });

  factory DebtPaymentModel.fromJson(Map<String, dynamic> json) {
    return DebtPaymentModel(
      id: json['id'] as String,
      debtId: json['debtId'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }

  factory DebtPaymentModel.fromEntity(DebtPayment p) => DebtPaymentModel(
        id: p.id,
        debtId: p.debtId,
        amount: p.amount,
        date: p.date,
        note: p.note,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'debtId': debtId,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
      };
}
