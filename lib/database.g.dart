// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ExpenseDao? _expenseDaoInstance;

  CustomerDao? _customerDaoInstance;

  VehicleDao? _vehicleDAOInstance;

  EventPlannerDao? _eventPlannerDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `CustomerItem` (`id` INTEGER NOT NULL, `firstName` TEXT NOT NULL, `lastName` TEXT NOT NULL, `address` TEXT NOT NULL, `birthday` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `vehicle_item` (`vehicleId` INTEGER PRIMARY KEY AUTOINCREMENT, `vehicleName` TEXT NOT NULL, `vehicleType` TEXT NOT NULL, `serviceType` TEXT NOT NULL, `serviceDate` TEXT NOT NULL, `mileage` TEXT NOT NULL, `cost` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ExpenseItem` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, `category` TEXT NOT NULL, `amount` TEXT NOT NULL, `date` TEXT NOT NULL, `paymentMethod` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `event_planner_item` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `date` TEXT NOT NULL, `time` TEXT NOT NULL, `location` TEXT NOT NULL, `description` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ExpenseDao get expenseDao {
    return _expenseDaoInstance ??= _$ExpenseDao(database, changeListener);
  }

  @override
  CustomerDao get customerDao {
    return _customerDaoInstance ??= _$CustomerDao(database, changeListener);
  }

  @override
  VehicleDao get vehicleDAO {
    return _vehicleDAOInstance ??= _$VehicleDao(database, changeListener);
  }

  @override
  EventPlannerDao get eventPlannerDao {
    return _eventPlannerDaoInstance ??=
        _$EventPlannerDao(database, changeListener);
  }
}

class _$ExpenseDao extends ExpenseDao {
  _$ExpenseDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _expenseItemInsertionAdapter = InsertionAdapter(
            database,
            'ExpenseItem',
            (ExpenseItem item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'category': item.category,
                  'amount': item.amount,
                  'date': item.date,
                  'paymentMethod': item.paymentMethod
                }),
        _expenseItemDeletionAdapter = DeletionAdapter(
            database,
            'ExpenseItem',
            ['id'],
            (ExpenseItem item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'category': item.category,
                  'amount': item.amount,
                  'date': item.date,
                  'paymentMethod': item.paymentMethod
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ExpenseItem> _expenseItemInsertionAdapter;

  final DeletionAdapter<ExpenseItem> _expenseItemDeletionAdapter;

  @override
  Future<List<ExpenseItem>> getAllItems() async {
    return _queryAdapter.queryList('SELECT * FROM ExpenseItem',
        mapper: (Map<String, Object?> row) => ExpenseItem(
            row['id'] as int,
            row['name'] as String,
            row['category'] as String,
            row['amount'] as String,
            row['date'] as String,
            row['paymentMethod'] as String));
  }

  @override
  Future<void> insertItem(ExpenseItem itm) async {
    await _expenseItemInsertionAdapter.insert(itm, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteItem(ExpenseItem itm) async {
    await _expenseItemDeletionAdapter.delete(itm);
  }
}

class _$CustomerDao extends CustomerDao {
  _$CustomerDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _customerItemInsertionAdapter = InsertionAdapter(
            database,
            'CustomerItem',
            (CustomerItem item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'birthday': item.birthday
                }),
        _customerItemUpdateAdapter = UpdateAdapter(
            database,
            'CustomerItem',
            ['id'],
            (CustomerItem item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'birthday': item.birthday
                }),
        _customerItemDeletionAdapter = DeletionAdapter(
            database,
            'CustomerItem',
            ['id'],
            (CustomerItem item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'birthday': item.birthday
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CustomerItem> _customerItemInsertionAdapter;

  final UpdateAdapter<CustomerItem> _customerItemUpdateAdapter;

  final DeletionAdapter<CustomerItem> _customerItemDeletionAdapter;

  @override
  Future<List<CustomerItem>> getAllItem() async {
    return _queryAdapter.queryList('Select * from CustomerItem',
        mapper: (Map<String, Object?> row) => CustomerItem(
            row['id'] as int,
            row['firstName'] as String,
            row['lastName'] as String,
            row['address'] as String,
            row['birthday'] as String));
  }

  @override
  Future<void> insertItem(CustomerItem itm) async {
    await _customerItemInsertionAdapter.insert(itm, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateItem(CustomerItem itm) async {
    await _customerItemUpdateAdapter.update(itm, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteItem(CustomerItem itm) async {
    await _customerItemDeletionAdapter.delete(itm);
  }
}

class _$VehicleDao extends VehicleDao {
  _$VehicleDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _vehicleItemInsertionAdapter = InsertionAdapter(
            database,
            'vehicle_item',
            (VehicleItem item) => <String, Object?>{
                  'vehicleId': item.vehicleId,
                  'vehicleName': item.vehicleName,
                  'vehicleType': item.vehicleType,
                  'serviceType': item.serviceType,
                  'serviceDate': item.serviceDate,
                  'mileage': item.mileage,
                  'cost': item.cost
                }),
        _vehicleItemUpdateAdapter = UpdateAdapter(
            database,
            'vehicle_item',
            ['vehicleId'],
            (VehicleItem item) => <String, Object?>{
                  'vehicleId': item.vehicleId,
                  'vehicleName': item.vehicleName,
                  'vehicleType': item.vehicleType,
                  'serviceType': item.serviceType,
                  'serviceDate': item.serviceDate,
                  'mileage': item.mileage,
                  'cost': item.cost
                }),
        _vehicleItemDeletionAdapter = DeletionAdapter(
            database,
            'vehicle_item',
            ['vehicleId'],
            (VehicleItem item) => <String, Object?>{
                  'vehicleId': item.vehicleId,
                  'vehicleName': item.vehicleName,
                  'vehicleType': item.vehicleType,
                  'serviceType': item.serviceType,
                  'serviceDate': item.serviceDate,
                  'mileage': item.mileage,
                  'cost': item.cost
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<VehicleItem> _vehicleItemInsertionAdapter;

  final UpdateAdapter<VehicleItem> _vehicleItemUpdateAdapter;

  final DeletionAdapter<VehicleItem> _vehicleItemDeletionAdapter;

  @override
  Future<List<VehicleItem>> getAllItems() async {
    return _queryAdapter.queryList('SELECT * FROM vehicle_item',
        mapper: (Map<String, Object?> row) => VehicleItem(
            vehicleId: row['vehicleId'] as int?,
            vehicleName: row['vehicleName'] as String,
            vehicleType: row['vehicleType'] as String,
            serviceType: row['serviceType'] as String,
            serviceDate: row['serviceDate'] as String,
            mileage: row['mileage'] as String,
            cost: row['cost'] as String));
  }

  @override
  Future<void> insertItem(VehicleItem item) async {
    await _vehicleItemInsertionAdapter.insert(item, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateItem(VehicleItem item) async {
    await _vehicleItemUpdateAdapter.update(item, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteItem(VehicleItem item) async {
    await _vehicleItemDeletionAdapter.delete(item);
  }
}

class _$EventPlannerDao extends EventPlannerDao {
  _$EventPlannerDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _eventPlannerItemInsertionAdapter = InsertionAdapter(
            database,
            'event_planner_item',
            (EventPlannerItem item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'date': item.date,
                  'time': item.time,
                  'location': item.location,
                  'description': item.description
                }),
        _eventPlannerItemUpdateAdapter = UpdateAdapter(
            database,
            'event_planner_item',
            ['id'],
            (EventPlannerItem item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'date': item.date,
                  'time': item.time,
                  'location': item.location,
                  'description': item.description
                }),
        _eventPlannerItemDeletionAdapter = DeletionAdapter(
            database,
            'event_planner_item',
            ['id'],
            (EventPlannerItem item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'date': item.date,
                  'time': item.time,
                  'location': item.location,
                  'description': item.description
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<EventPlannerItem> _eventPlannerItemInsertionAdapter;

  final UpdateAdapter<EventPlannerItem> _eventPlannerItemUpdateAdapter;

  final DeletionAdapter<EventPlannerItem> _eventPlannerItemDeletionAdapter;

  @override
  Future<List<EventPlannerItem>> getAllItems() async {
    return _queryAdapter.queryList('SELECT * FROM event_planner_item',
        mapper: (Map<String, Object?> row) => EventPlannerItem(
            id: row['id'] as int?,
            name: row['name'] as String,
            date: row['date'] as String,
            time: row['time'] as String,
            location: row['location'] as String,
            description: row['description'] as String));
  }

  @override
  Future<void> insertItem(EventPlannerItem item) async {
    await _eventPlannerItemInsertionAdapter.insert(
        item, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateItem(EventPlannerItem item) async {
    await _eventPlannerItemUpdateAdapter.update(item, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteItem(EventPlannerItem item) async {
    await _eventPlannerItemDeletionAdapter.delete(item);
  }
}
