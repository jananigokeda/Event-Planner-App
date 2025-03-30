import 'package:floor/floor.dart';

@Entity(tableName: 'vehicle_item')
class VehicleItem {
  @PrimaryKey(autoGenerate: true)
  final int? vehicleId;

  final String vehicleName;
  final String vehicleType;
  final String serviceType;
  final String serviceDate;
  final String mileage;
  final String cost;


  const VehicleItem({this.vehicleId, required this.vehicleName, required this.vehicleType, required this.serviceType
  , required this.serviceDate, required this.mileage, required this.cost});
}
