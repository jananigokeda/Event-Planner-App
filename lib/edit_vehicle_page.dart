import 'package:flutter/material.dart';
import 'database.dart';
import 'vehicle_item.dart';
import 'vehicle_dao.dart';

// New class for editting the Editing vehicle information
class EditVehiclePage extends StatefulWidget {
  final VehicleItem item;
  final VehicleDao dao;
  final Function(VehicleItem) onUpdate;
  //constructor
  const EditVehiclePage({
    Key? key,
    required this.item,
    required this.dao,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditVehiclePageState createState() => _EditVehiclePageState();
}

class _EditVehiclePageState extends State<EditVehiclePage> {
  late TextEditingController _vehicleNameController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _serviceTypeController;
  late TextEditingController _serviceDateController;
  late TextEditingController _mileageController;
  late TextEditingController _costController;

  //This initState() method is initializing several TextEditingController instances in a Flutter widget
  @override
  void initState() {
    super.initState();
    _vehicleNameController = TextEditingController(text: widget.item.vehicleName);
    _vehicleTypeController = TextEditingController(text: widget.item.vehicleType);
    _serviceTypeController = TextEditingController(text: widget.item.serviceType);
    _serviceDateController = TextEditingController(text: widget.item.serviceDate);
    _mileageController = TextEditingController(text: widget.item.mileage);
    _costController = TextEditingController(text: widget.item.cost);
  }

  //This dispose() method is cleaning up resources when the Flutter widget is removed from the widget tree. Here's what it does:
  @override
  void dispose() {
    _vehicleNameController.dispose();
    _vehicleTypeController.dispose();
    _serviceTypeController.dispose();
    _serviceDateController.dispose();
    _mileageController.dispose();
    _costController.dispose();
    super.dispose();
  }

  //_updateItem() creates an updated VehicleItem with the edited values
  // Uses the DAO to update the database
  // Calls the onUpdate callback
  // Navigates back to previous screen
  Future<void> _updateItem() async {
    final updatedItem = VehicleItem(
      vehicleId: widget.item.vehicleId,
      vehicleName: _vehicleNameController.text.trim(),
      vehicleType: _vehicleTypeController.text.trim(),
      serviceType: _serviceTypeController.text.trim(),
      serviceDate: _serviceDateController.text.trim(),
      mileage: _mileageController.text.trim(),
      cost: _costController.text.trim(),
    );
    await widget.dao.updateItem(updatedItem);
    widget.onUpdate(updatedItem);
    Navigator.pop(context); // Return to the previous page
  }

  // Adding heading for the page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EDIT VEHICLE INFORMATION - வாகனத் தகவலைத் திருத்து"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateItem,
          ),
        ],
      ),

      // Implementation of the Form for the update
      // Vehicle Name
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _vehicleNameController,
                decoration: const InputDecoration(
                  labelText: "Vehicle Name",
                  border: OutlineInputBorder(),
                ),
              ),
              //Vehicle Type
              const SizedBox(height: 10),
              TextField(
                controller: _vehicleTypeController,
                decoration: const InputDecoration(
                  labelText: "Vehicle Type",
                  border: OutlineInputBorder(),
                ),
              ),
              //Service Type
              const SizedBox(height: 10),
              TextField(
                controller: _serviceTypeController,
                decoration: const InputDecoration(
                  labelText: "Service Type",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _serviceDateController,
                decoration: const InputDecoration(
                  labelText: "Service Date",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _mileageController,
                decoration: const InputDecoration(
                  labelText: "Mileage",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: "Cost",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateItem,
                child: const Text("SAVE CHANGES"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}