import 'package:floor/floor.dart';
import 'event_planner_item.dart';
/// Data Access Object (DAO) for the `event_planner_item` table.
/// This abstract class defines the CRUD (Create, Read, Update, Delete)
/// operations used to interact with the event planner database table.

@dao
/// Retrieves all event planner items from the database.
abstract class EventPlannerDao {
  @Query('SELECT * FROM event_planner_item')
  Future<List<EventPlannerItem>> getAllItems();
  /// Inserts a new event into the database.
  @insert
  Future<void> insertItem(EventPlannerItem item);
  /// Updates an existing event in the database.
  /// Takes an EventPlannerItem and updates the corresponding row
  /// based on the primary key id.
  @update
  Future<void> updateItem(EventPlannerItem item);
  /// Deletes an event from the database.
  /// Removes the row that matches the EventPlannerItem's id.
  @delete
  Future<void> deleteItem(EventPlannerItem item);
}
