import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/debt_model.dart';
import '../models/debt_payment_model.dart';

/// Persistencia local de deudas y pagos en SharedPreferences.
class DebtLocalDataSource {
  static const String _kDebts = 'debts_list';
  static const String _kPayments = 'debts_payments';
  static const String _kMonthlyExtra = 'debts_monthly_extra';

  final SharedPreferences prefs;
  DebtLocalDataSource(this.prefs);

  // ============== DEUDAS ==============

  Future<List<DebtModel>> getAll() async {
    final raw = prefs.getString(_kDebts);
    if (raw == null || raw.isEmpty) return [];
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((e) => DebtModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeAll(List<DebtModel> list) async {
    final encoded = json.encode(list.map((d) => d.toJson()).toList());
    await prefs.setString(_kDebts, encoded);
  }

  Future<DebtModel> add(DebtModel debt) async {
    final list = await getAll();
    list.add(debt);
    await _writeAll(list);
    return debt;
  }

  Future<DebtModel> update(DebtModel debt) async {
    final list = await getAll();
    final i = list.indexWhere((d) => d.id == debt.id);
    if (i == -1) {
      list.add(debt);
    } else {
      list[i] = debt;
    }
    await _writeAll(list);
    return debt;
  }

  Future<void> delete(String id) async {
    final list = await getAll();
    list.removeWhere((d) => d.id == id);
    await _writeAll(list);
    // También eliminar todos los pagos de esta deuda.
    final payments = await getAllPayments();
    payments.removeWhere((p) => p.debtId == id);
    await _writeAllPayments(payments);
  }

  // ============== PAGOS ==============

  Future<List<DebtPaymentModel>> getAllPayments() async {
    final raw = prefs.getString(_kPayments);
    if (raw == null || raw.isEmpty) return [];
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((e) => DebtPaymentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeAllPayments(List<DebtPaymentModel> list) async {
    final encoded = json.encode(list.map((p) => p.toJson()).toList());
    await prefs.setString(_kPayments, encoded);
  }

  Future<List<DebtPaymentModel>> getPaymentsForDebt(String debtId) async {
    final all = await getAllPayments();
    return all.where((p) => p.debtId == debtId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<DebtPaymentModel> addPayment(DebtPaymentModel payment) async {
    final list = await getAllPayments();
    list.add(payment);
    await _writeAllPayments(list);
    return payment;
  }

  // ============== EXTRA MENSUAL ==============

  Future<void> setMonthlyExtra(double amount) async {
    await prefs.setDouble(_kMonthlyExtra, amount);
  }

  double getMonthlyExtra() => prefs.getDouble(_kMonthlyExtra) ?? 0;
}
