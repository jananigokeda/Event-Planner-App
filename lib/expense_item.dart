// expense_item.dart
// Model class representing an expense item.
import 'package:floor/floor.dart';

@entity
class ExpenseItem {
  @PrimaryKey(autoGenerate: true)
  final int? id; // Primary key, auto-generated.
  final String name; // Name of the expense.
  final String category;//Category of the expense.
  final String amount;
  final String date;
  final String paymentMethod ;

  ExpenseItem(this.id, this.name, this.category,this.amount,this.date,this.paymentMethod);
}