import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'database.dart';
import 'vehicle_item.dart';
import 'vehicle_dao.dart';

/// New class for editing the Editing vehicle information
class EditVehiclePage extends StatefulWidget {
  final VehicleItem item;
  final VehicleDao dao;
  final Function(VehicleItem) onUpdate; //declares a callback function that the EditVehiclePage widget will use to notify its parent widget when a vehicle item is updated.
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
/// Declaring variables
class _EditVehiclePageState extends State<EditVehiclePage> {
  late TextEditingController _vehicleNameController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _serviceTypeController;
  late TextEditingController _serviceDateController;
  late TextEditingController _mileageController;
  late TextEditingController _costController;

  ///This initState() method is initializing several TextEditingController instances in a Flutter widget
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

  /// Show Cupertino-style language selection popup
  void showDemoActionSheet(
      {required BuildContext context, required Widget child}) {
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => child).then((String? value) {
      if (value != null) changeLocale(context, value);
    });
  }

  /// Called when language icon is pressed
  void _onActionsheetPress(BuildContext context) {
    showDemoActionSheet(
      context: context,
      child: CupertinoActionSheet(
        title: Text(translate('language.selection.title')),
        message: Text(translate('language.selection.message')),
        actions: <Widget>[
          // English
          CupertinoActionSheetAction(
            child:
            Text(translate('language.name.en')),
            onPressed: () async {
              Navigator.pop(context);
              await changeLocale(context, 'en');
            },
          ),

          // Tamil
          CupertinoActionSheetAction(
            child: Text(translate('language.name.ta')),
            onPressed: () async {
              Navigator.pop(context);
              await changeLocale(context, 'ta');
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(translate('button.cancel')),
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  ///This dispose() method is cleaning up resources when the Flutter widget is removed from the widget tree. Here's what it does:
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

  ///_updateItem() creates an updated VehicleItem with the edited values
  /// Uses the DAO to update the database
  /// Calls the onUpdate callback
  /// Navigates back to previous screen
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

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle Information has been successfully updated!!.')));
  }

  /// Picking the date when trying to update the date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _serviceDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }
  /// Adding heading for the updater page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(translate('vehicle.Title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateItem,
          ),
        ],
      ),

      /// Implementation of the edit page form
      /// Vehicle Name
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
            TextField(
            controller: _vehicleNameController,
            decoration: InputDecoration(
              labelText: translate('vehicle.Vehicle Name'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0), // Rounded corners
                borderSide: BorderSide(color: Colors.blue.shade300), // Border color
              ),
            ),
          ),
          //Vehicle Type
              const SizedBox(height: 10),
              TextField(
                controller: _vehicleNameController,
                decoration: InputDecoration(
                  labelText: translate('vehicle.Vehicle Name'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0), // Rounded corners
                    borderSide: BorderSide(color: Colors.blue.shade300), // Border color
                  ),
                ),
              ),

              const SizedBox(height: 10), // Space between fields
              TextField( // Vehicle Type Input
                controller: _vehicleTypeController,
                decoration: InputDecoration(
                  labelText: translate('vehicle.Vehicle Type'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0), // Rounded corners
                    borderSide: BorderSide(color: Colors.blue.shade300), // Border color
                  ),
                ),
              ),

              //serviceType
              const SizedBox(height: 10), // Space between fields
              TextField( // Service Type Input
                controller: _serviceTypeController,
                decoration: InputDecoration(
                  labelText: translate('vehicle.Service Type'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0), // Rounded corners
                    borderSide: BorderSide(color: Colors.blue.shade300), // Border color
                  ),
                ),
              ),

              // Service Date
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _serviceDateController,
                    decoration: InputDecoration(
                      labelText: translate('vehicle.Service Date'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: BorderSide(color: Colors.blue.shade300),
                      ),
                    ),
                  ),
                ),
              ),

              //mileage
              const SizedBox(height: 10), // Space between fields
              TextField( // Mileage Input
                controller: _mileageController,
                decoration:  InputDecoration(
                  labelText: translate('vehicle.Mileage'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0), // Rounded corners
                    borderSide: BorderSide(color: Colors.blue.shade300), // Border color
                  ),
                ),
              ),

              //Cost
              const SizedBox(height: 10), // Space between fields
              TextField( // Cost Input
                controller: _costController,
                decoration:  InputDecoration(
                  labelText: translate('vehicle.Cost'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0), // Rounded corners
                    borderSide: BorderSide(color: Colors.blue.shade300), // Border color
                  ),
                ),

              ),
              // Save button which will call the _updateItem function when clicked
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () async {
                    await _updateItem(); // This method will add the vehicle info when save button is pressed
                  },
                  style: ElevatedButton.styleFrom(  // Styling the button
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.lightBlueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(translate('vehicle.SAVE'))

              ),
            ],
          ),
        ),
      ),
    );
  }
}