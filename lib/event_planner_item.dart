import 'package:floor/floor.dart';

@Entity(tableName: 'event_planner_item')
class EventPlannerItem {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;
  final String date;
  final String time;
  final String location;
  final String description;

  EventPlannerItem({
    this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
  });
}
