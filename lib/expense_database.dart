import 'dart:async';
import 'package:floor/floor.dart';
import 'expense_item.dart';
import 'expense_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

// Define the database
@Database(version: 1, entities: [ExpenseItem])
abstract class ExpenseDatabase extends FloorDatabase {
  ExpenseDao get expenseDao;
}
