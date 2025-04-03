import 'dart:async';
import 'customer_dao.dart';
import 'package:floor/floor.dart';

import 'package:sqflite/sqflite.dart' as sqflite;

import 'customer_item.dart';
import 'expense_item.dart';
import 'package:cst2335_final/VehicleMaintenancePage.dart';
import 'expense_dao.dart';

part 'database.g.dart';

@Database(version: 1, entities: [CustomerItem,ExpenseItem])
abstract class AppDatabase extends FloorDatabase {


  CustomerDAO get customerDao;
  ExpenseDao get expenseDao;


}
