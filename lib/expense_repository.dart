import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'expense_item.dart';

/// A repository class for securely saving and retrieving expense form data.
/// Currently uses EncryptedSharedPreferences for storing the last entered expense.
class ExpenseRepository {
  final EncryptedSharedPreferences _storage = EncryptedSharedPreferences();

  // Keys for storing last entered expense values
  static const String lastExpenseNameKey = "last_expense_name";
  static const String lastExpenseCategoryKey = "last_expense_category";
  static const String lastExpenseAmountKey = "last_expense_amount";
  static const String lastExpenseDateKey = "last_expense_date";
  static const String lastExpensePaymentMethodKey = "last_expense_payment_method";

  /// Saves the last entered expense details in EncryptedSharedPreferences.
  Future<void> saveData(String name, String category, String amount, String date, String paymentMethod) async {
    await Future.wait([
      _storage.setString(lastExpenseNameKey, name),
      _storage.setString(lastExpenseCategoryKey, category),
      _storage.setString(lastExpenseAmountKey, amount),
      _storage.setString(lastExpenseDateKey, date),
      _storage.setString(lastExpensePaymentMethodKey, paymentMethod),
    ]);
  }

  /// Loads the last saved expense data from EncryptedSharedPreferences.
  Future<Map<String, String>> loadData() async {
    return {
      "name": await _storage.getString(lastExpenseNameKey) ?? '',
      "category": await _storage.getString(lastExpenseCategoryKey) ?? '',
      "amount": await _storage.getString(lastExpenseAmountKey) ?? '',
      "date": await _storage.getString(lastExpenseDateKey) ?? '',
      "paymentMethod": await _storage.getString(lastExpensePaymentMethodKey) ?? '',
    };
  }

  /*/// Placeholder method to support saving a full list of expenses.
  /// In the future, this can be expanded to persist data to a database or file.
  Future<void> saveExpenseList(List<ExpenseItem> expenses) async {
    // Store the list in a persistent storage (e.g., database or file)
  }


  /// Placeholder method to retrieve all stored expenses.
  /// Can be connected to a database or local file storage.
  Future<List<ExpenseItem>> getAllExpenses() async {
    // Retrieve the list of all expenses (from database or file)
    return [];
  }*/
}
