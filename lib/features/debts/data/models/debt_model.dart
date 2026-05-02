import '../../domain/entities/debt.dart';

class DebtModel extends Debt {
  const DebtModel({
    required super.id,
    required super.name,
    required super.originalAmount,
    required super.currentBalance,
    required super.minimumPayment,
    required super.annualInterestRate,
    required super.createdAt,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'] as String,
      name: json['name'] as String,
      originalAmount: (json['originalAmount'] as num).toDouble(),
      currentBalance: (json['currentBalance'] as num).toDouble(),
      minimumPayment: (json['minimumPayment'] as num).toDouble(),
      annualInterestRate: (json['annualInterestRate'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory DebtModel.fromEntity(Debt d) => DebtModel(
        id: d.id,
        name: d.name,
        originalAmount: d.originalAmount,
        currentBalance: d.currentBalance,
        minimumPayment: d.minimumPayment,
        annualInterestRate: d.annualInterestRate,
        createdAt: d.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'originalAmount': originalAmount,
        'currentBalance': currentBalance,
        'minimumPayment': minimumPayment,
        'annualInterestRate': annualInterestRate,
        'createdAt': createdAt.toIso8601String(),
      };
}
