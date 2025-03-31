import 'dart:async';
import 'package:cst2335_final/expense_dao.dart';
import 'package:cst2335_final/vehicle_dao.dart';
import 'package:cst2335_final/customer_dao.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:cst2335_final/vehicle_item.dart';
import 'package:cst2335_final/customer_item.dart';
import 'package:cst2335_final/expense_item.dart';
part 'database.g.dart';

@Database(version: 1, entities: [CustomerItem, VehicleItem, ExpenseItem])
abstract class AppDatabase extends FloorDatabase {
  ExpenseDao get expenseDao;
  CustomerDao get customerDao;
  VehicleDao get vehicleDAO;
}
