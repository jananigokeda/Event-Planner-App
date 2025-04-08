import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'event_planner_item.dart';

/// A encrypted storage  class for securely saving and retrieving event form data.
/// Uses EncryptedSharedPreferences to store the last entered event.
class EventEncryptedStorage {
  final EncryptedSharedPreferences _storage = EncryptedSharedPreferences();

  // Keys for storing last entered event values
  static const String lastEventNameKey = "last_event_name";
  static const String lastEventDateKey = "last_event_date";
  static const String lastEventTimeKey = "last_event_time";
  static const String lastEventvenueKey = "last_event_venue";
  static const String lastEventDescriptionKey = "last_event_description";


  /// Saves the last entered [EventPlannerItem] to EncryptedSharedPreferences.
  Future<void> saveEvent(EventPlannerItem event) async {
    await Future.wait([
      _storage.setString(lastEventNameKey, event.name),
      _storage.setString(lastEventDateKey, event.date),
      _storage.setString(lastEventTimeKey, event.time),
      _storage.setString(lastEventvenueKey, event.venue),
      _storage.setString(lastEventDescriptionKey, event.description),
    ]);
  }

  /// Loads the last saved event data from EncryptedSharedPreferences.
  ///
  /// Returns a [Map<String, String>] containing the event fields, or empty strings if not found.
  Future<Map<String, String>> loadEvent() async {
    return {
      "name": await _storage.getString(lastEventNameKey) ?? '',
      "date": await _storage.getString(lastEventDateKey) ?? '',
      "time": await _storage.getString(lastEventTimeKey) ?? '',
      "venue": await _storage.getString(lastEventvenueKey) ?? '',
      "description": await _storage.getString(lastEventDescriptionKey) ?? '',
    };
  }

  /// Placeholder to save a list of events to persistent storage (e.g., file or database).
  Future<void> saveEventList(List<EventPlannerItem> events) async {
    // Future enhancement: implement serialization and local DB storage
  }

  /// Placeholder to retrieve all stored events.
  Future<List<EventPlannerItem>> getAllEvents() async {
    // Future enhancement: retrieve list from local DB
    return [];
  }
}
