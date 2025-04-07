import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'event_planner_item.dart';

final EncryptedSharedPreferences _encryptedPrefs = EncryptedSharedPreferences();

/// Save the most recent event to EncryptedSharedPreferences.
Future<void> saveLastEvent(EventPlannerItem event) async {
  await _encryptedPrefs.setString('name', event.name);
  await _encryptedPrefs.setString('date', event.date);
  await _encryptedPrefs.setString('time', event.time);
  await _encryptedPrefs.setString('venue', event.venue);
  await _encryptedPrefs.setString('description', event.description);
}
/// Retrieve the most recent event fields from EncryptedSharedPreferences.
Future<Map<String, String>> getLastEventData() async {
  final keys = ['name', 'date', 'time', 'venue', 'description'];
  Map<String, String> eventData = {};

  for (final key in keys) {
    final value = await _encryptedPrefs.getString(key);
    if (value != null) {
      eventData[key] = value;
    }
  }

  return eventData;
}