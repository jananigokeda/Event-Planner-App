import 'package:floor/floor.dart';

@entity
class CustomerItem {
  static int currentId = 1;

  @primaryKey
  final int id;
  final String firstName;
  final String lastName;
  final String address;
  final String birthday;

  CustomerItem(
      this.id, this.firstName, this.lastName, this.address, this.birthday) {
    if (id > currentId) {
      currentId = id + 1;
    }
  }
}
