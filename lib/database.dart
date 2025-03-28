import 'dart:async';
import 'customer_dao.dart';
import 'customer_item.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'vehicle_item.dart';
part 'database.g.dart'; // Generated code

@Database(version: 1, entities: [CustomerItem])
abstract class AppDatabase extends FloorDatabase {
  CustomerDAO get customerDAO;
}

