import 'package:floor/floor.dart';
import 'customer_item.dart';

@dao
abstract class CustomerDAO {

  @Query("Select * from CustomerItem")
  Future<List<CustomerItem>> getAllItem();

  @insert
  Future<void> insertItem(CustomerItem itm);

  @update
  Future<void> updateItem(CustomerItem itm);

  @delete
  Future<void> deleteItem(CustomerItem itm);

}