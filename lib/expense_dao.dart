// expense_dao.dart
// Data Access Object (DAO) for ExpenseItem, handles database queries.
import 'package:floor/floor.dart';
import 'expense_item.dart';

@dao
abstract class ExpenseDao {
  /// Retrieves all expense items from the database.
  @Query("Select * from ExpenseItem")
  Future<List<ExpenseItem>> getAllItems();

  /// Inserts a new expense item into the database.
  @insert
  Future<void> insertItem(ExpenseItem itm);

  /// Deletes an expense item from the database.
  @delete
  Future<void> deleteItem(ExpenseItem itm);
}