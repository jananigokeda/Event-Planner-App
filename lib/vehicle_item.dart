import 'package:floor/floor.dart';

@Entity(tableName: 'vehicle_item')
class VehicleItem {
  @PrimaryKey(autoGenerate: true)
  final int? vehicleId;

  final String vehicleName;
  final String vehicleType;

  const VehicleItem({this.vehicleId, required this.vehicleName, required this.vehicleType});
}
