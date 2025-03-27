import 'dart:async';
import 'customer_dao.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'customer_item.dart';

part 'database.g.dart';

@Database(version: 1, entities: [CustomerItem])
abstract class AppDatabase extends FloorDatabase {
  var expenseDao;

  CustomerDAO get customerDao;
}
