import 'package:floor/floor.dart';
///  Event planner item.dart Represents a single event item to be stored in the event planner database.
/// This class defines the structure of the `event_planner_item` table
/// used by the Floor persistence library.

@Entity(tableName: 'event_planner_item')
class EventPlannerItem {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;
  final String date;
  final String time;
  final String venue;
  final String description;

  EventPlannerItem({
    this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.venue,
    required this.description
  });
}
