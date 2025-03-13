import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

/// Repository for saving and loading the previously used customer information.
class CustomerRepository {
  final EncryptedSharedPreferences _storage = EncryptedSharedPreferences();

  static const String firstNameKey = "customer_first_name";
  static const String lastNameKey = "customer_last_name";
  static const String addressKey = "customer_address";
  static const String birthdayKey = "customer_birthday";

  /// Saves customer information (first name, last name, address, birthday)
  /// to EncryptedSharedPreferences.
  Future<void> saveData(String firstName, String lastName, String address, String birthday) async {
    await _storage.setString(firstNameKey, firstName);
    await _storage.setString(lastNameKey, lastName);
    await _storage.setString(addressKey, address);
    await _storage.setString(birthdayKey, birthday);
  }

  /// Loads customer information from EncryptedSharedPreferences.
  /// Returns a map with keys: "firstName", "lastName", "address", "birthday".
  Future<Map<String, String>> loadData() async {
    return {
      "firstName": await _storage.getString(firstNameKey) ?? "",
      "lastName": await _storage.getString(lastNameKey) ?? "",
      "address": await _storage.getString(addressKey) ?? "",
      "birthday": await _storage.getString(birthdayKey) ?? "",
    };
  }
}