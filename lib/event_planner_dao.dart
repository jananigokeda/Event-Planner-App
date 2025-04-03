import 'package:floor/floor.dart';
import 'event_planner_item.dart';

@dao
abstract class EventPlannerDao {
  @Query('SELECT * FROM event_planner_item')
  Future<List<EventPlannerItem>> getAllItems();

  @insert
  Future<void> insertItem(EventPlannerItem item);

  @update
  Future<void> updateItem(EventPlannerItem item);

  @delete
  Future<void> deleteItem(EventPlannerItem item);
}
