import 'package:cst2335_final/vehicle_item.dart';
import 'package:floor/floor.dart';

// This calss is responsible for all the database operations.
@dao
abstract class VehicleDao {
  @Query("SELECT * FROM vehicle_item")
  Future<List<VehicleItem>> getAllItems();

  @insert
  Future<void> insertItem(VehicleItem item);

  @delete
  Future<void> deleteItem(VehicleItem item);

  @update
  Future<void> updateItem(VehicleItem item);
}