import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'expense_item.dart';

class ExpenseRepository {
  final EncryptedSharedPreferences _storage = EncryptedSharedPreferences();
  static const String lastExpenseNameKey = "last_expense_name";
  static const String lastExpenseCategoryKey = "last_expense_category";
  static const String lastExpenseAmountKey = "last_expense_amount";
  static const String lastExpenseDateKey = "last_expense_date";
  static const String lastExpensePaymentMethodKey = "last_expense_payment_method";

  /// Saves expense information in EncryptedSharedPreferences.
  Future<void> saveData(String name, String category, String amount, String date, String paymentMethod) async {
    await Future.wait([
      _storage.setString(lastExpenseNameKey, name),
      _storage.setString(lastExpenseCategoryKey, category),
      _storage.setString(lastExpenseAmountKey, amount),
      _storage.setString(lastExpenseDateKey, date),
      _storage.setString(lastExpensePaymentMethodKey, paymentMethod),
    ]);
  }

  /// Loads the last entered expense details.
  Future<Map<String, String>> loadData() async {
    return {
      "name": await _storage.getString(lastExpenseNameKey) ?? '',
      "category": await _storage.getString(lastExpenseCategoryKey) ?? '',
      "amount": await _storage.getString(lastExpenseAmountKey) ?? '',
      "date": await _storage.getString(lastExpenseDateKey) ?? '',
      "paymentMethod": await _storage.getString(lastExpensePaymentMethodKey) ?? '',
    };
  }

  /// This method could be modified to interact with a database or file for expenses.
  Future<void> saveExpenseList(List<ExpenseItem> expenses) async {
    // Store the list in a persistent storage (e.g., database or file)
  }

  Future<List<ExpenseItem>> getAllExpenses() async {
    // Retrieve the list of all expenses (from database or file)
    return [];
  }
}
