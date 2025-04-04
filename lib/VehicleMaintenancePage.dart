
import 'package:cst2335_final/database.dart';

import 'dart:convert';

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import 'package:flutter/material.dart';
import 'database.dart';
import 'edit_vehicle_page.dart';
import 'vehicle_item.dart';
import 'vehicle_dao.dart';

final Map<String, Map<String, String>> localizedValues = {
  'en': {
    'instructions_content':
    'Enter all required fields to add a vehicle information.\nTap "Copy Previous" to load the last input data.\n Click save button save the vehicle information \n Click on a vehicle info to view details on the page.\nOn tablet/desktop, the right pane shows the detail view.\n',
    'vehicleName': 'Vehicle Name',
    'vehicleType': 'Vehicle Type',
    'serviceType': 'Service Type',
    'serviceDate': 'Service Date',
    'mileage': 'Mileage',
    'cost': 'Cost',
    'save': 'Save',
    'copy_previous': 'Copy Previous',
    'edit': 'Edit',
    'delete': 'Delete',
    'close': 'Close',
    'Delete Item': 'Delete Item',
    'yes': 'Yes',
    'no': 'No',
    'Are you sure you want to delete this item?': 'Are you sure you want to delete this item?'
        'There are no items in the list'
  },
  'ta': {
    'vehicleName': 'வாகனத்தின் பெயர்',
    'vehicleType': 'வாகன வகை',
    'serviceType': 'சேவை வகை',
    'serviceDate': 'சேவை தேதி',
    'mileage': 'மைலேஜ்',
    'cost': 'விலை',
    'save': 'சேமிக்க',
    'copy_previous': 'முந்தைய_நகல்',
    'edit': 'திருத்தவும்',
    'delete': 'நீக்கவும்',
    'close': 'மூடு'
  },
};


/// Returns the localized string for the given key.
String getText(String key, String currentLanguage) {
  return localizedValues[currentLanguage]?[key] ?? key;
}

class VehicleMaintenancePage extends StatefulWidget {

  const VehicleMaintenancePage({super.key, required AppDatabase database});

  //const VehicleMaintenancePage({Key? key}) : super(key: key);


  @override
  _VehicleMaintenancePageState createState() =>
      _VehicleMaintenancePageState();
}

class _VehicleMaintenancePageState extends State<VehicleMaintenancePage> {
  late VehicleDao myDAO;
  final List<VehicleItem> _items = [];
  final TextEditingController _vehicleNameController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _serviceDateController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  VehicleItem? _selectedItem;
  bool _isEditing = false; // Track if we're editing
  late AppDatabase _database;
  late final EncryptedSharedPreferences _storage;

  @override
  void initState() {
    super.initState();
    _storage = EncryptedSharedPreferences();
    _loadPreviousFormData(); // Load saved data automatically

    // Build the Floor database and get the DAO.
    $FloorAppDatabase.databaseBuilder('app_database.db').build().then((database) {
      _database = database;
      //myDAO = database.VehicleDao;
      _loadItems();
    });
  }


  Future<void> _loadItems() async {
    final items = await myDAO.getAllItems();
    setState(() {
      _items.clear();
      _items.addAll(items);
    });
  }

  Future<void> _addItem() async {
    String vehicleName = _vehicleNameController.text.trim();
    String vehicleType = _vehicleTypeController.text.trim();
    String serviceType = _serviceTypeController.text.trim();
    String serviceDate = _serviceDateController.text.trim();
    String mileage = _mileageController.text.trim();
    String cost = _costController.text.trim();
    if (vehicleName.isNotEmpty && vehicleType.isNotEmpty) {
      final newItem = VehicleItem(vehicleName: vehicleName, vehicleType: vehicleType, serviceType: serviceType, serviceDate: serviceDate, mileage: mileage, cost: cost);
      await myDAO.insertItem(newItem);
      _vehicleNameController.clear();
      _vehicleTypeController.clear();
      _serviceTypeController.clear();
      _serviceDateController.clear();
      _mileageController.clear();
      _costController.clear();
      _loadItems(); // Refresh the list
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Success!"),
          content: const Text("Vehicle info saved successfully."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      // Show validation error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Vehicle information required!! Please input vehicle info"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }
/*
  Future<void> _updateItem(VehicleItem item) async {
    String vehicleName = _vehicleNameController.text.trim();
    String vehicleType = _vehicleTypeController.text.trim();
    String serviceType = _serviceTypeController.text.trim();
    String serviceDate = _serviceDateController.text.trim();
    String mileage = _mileageController.text.trim();
    String cost = _costController.text.trim();

    if (vehicleName.isNotEmpty && vehicleType.isNotEmpty) {
      final updatedItem = VehicleItem(
        vehicleId: item.vehicleId,
        vehicleName: vehicleName,
        vehicleType: vehicleType,
        serviceType: serviceType,
        serviceDate: serviceDate,
        mileage: mileage,
        cost: cost,
      );
      await myDAO.updateItem(updatedItem);
      await _saveCurrentFormData(); // Save updated form data

      _vehicleNameController.clear();
      _vehicleTypeController.clear();
      _serviceTypeController.clear();
      _serviceDateController.clear();
      _mileageController.clear();
      _costController.clear();
      _loadItems();
      _setEditing(false);
      _closeDetails();
    }
  }
*/

  // Deleting the item from the list
  Future<void> _removeItem(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Item"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                await myDAO.deleteItem(_items[index]);
                _loadItems();
                Navigator.of(context).pop();
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }


  // show vehicle detail from the database
  void _showDetails(VehicleItem item) {
    setState(() {
      _selectedItem = item;
      _vehicleNameController.text = item.vehicleName; // Populate text fields
      _vehicleTypeController.text = item.vehicleType;
      _serviceTypeController.text = item.serviceType; // Populate text fields
      _serviceDateController.text = item.serviceDate;
      _mileageController.text = item.mileage; // Populate text fields
      _costController.text = item.cost;
    });
  }
// Closing details
  void _closeDetails() {
    setState(() {
      _selectedItem = null;
      _vehicleNameController.clear();
      _vehicleTypeController.clear();
      _serviceTypeController.clear();
      _serviceDateController.clear();
      _mileageController.clear();
      _costController.clear();
      _setEditing(false); // Ensure not in editing mode
    });
  }

  void _setEditing(bool editing) {
    setState(() {
      _isEditing = editing;
    });
  }

  // Save current form data
  Future<void> _saveCurrentFormData() async {
    final formData = {
      'vehicleName': _vehicleNameController.text,
      'vehicleType': _vehicleTypeController.text,
      'serviceType': _serviceTypeController.text,
      'serviceDate': _serviceDateController.text,
      'mileage': _mileageController.text,
      'cost': _costController.text,
    };

    await _storage.setString('lastVehicleFormData', jsonEncode(formData));
  }

// Load previous form data
  Future<void> _loadPreviousFormData() async {
    try {
      final encryptedData = await _storage.getString('lastVehicleFormData');
      if (encryptedData != null) {
        final formData = jsonDecode(encryptedData) as Map<String, dynamic>;

        setState(() {
          _vehicleNameController.text = formData['vehicleName'] ?? '';
          _vehicleTypeController.text = formData['vehicleType'] ?? '';
          _serviceTypeController.text = formData['serviceType'] ?? '';
          _serviceDateController.text = formData['serviceDate'] ?? '';
          _mileageController.text = formData['mileage'] ?? '';
          _costController.text = formData['cost'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading previous data: $e');
    }
  }


  // FORM IMPLEMENTATION SECTION
  Widget _listPage() {
    return Column(
      children: [
        Column( // Stack inputs vertically
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _vehicleNameController,
              decoration: InputDecoration(
                labelText: getText('vehicleName', _currentLanguage),
                hintText: "Vehicle Name",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12.0),
              ),
            ),

            const SizedBox(height: 10), // Space between fields
            TextField( // Vehicle Type Input
              controller: _vehicleTypeController,
              decoration: InputDecoration(
                labelText: getText('vehicleType', _currentLanguage),
                hintText: "Vehicle Type",
                border: OutlineInputBorder(),
              ),
            ),


            const SizedBox(height: 10), // Space between fields
            TextField( // Service Type Input
              controller: _serviceTypeController,
              decoration: InputDecoration(
                labelText: getText('serviceType', _currentLanguage),
                hintText: "Service Type",
                border: OutlineInputBorder(),
              ),
            ),


            const SizedBox(height: 10), // Space between fields
            TextField( // Service Date Input
              controller: _serviceDateController,
              decoration:  InputDecoration(
                labelText: getText('serviceDate', _currentLanguage),
                hintText: "Service Date",
                border: OutlineInputBorder(),
              ),
            ),


            const SizedBox(height: 10), // Space between fields
            TextField( // Mileage Input
              controller: _mileageController,
              decoration:  InputDecoration(
                labelText: getText('mileage', _currentLanguage),
                hintText: "Mileage",
                border: OutlineInputBorder(),
              ),
            ),


            const SizedBox(height: 10), // Space between fields
            TextField( // Cost Input
              controller: _costController,
              decoration:  InputDecoration(
                labelText: getText('cost', _currentLanguage),
                hintText: "Cost",
                border: OutlineInputBorder(),
              ),
            ),

            // SAVE and COPY PREVIOUS BUTTON SECTION
            const SizedBox(height: 30),
            Align(  // Center the button
              alignment: Alignment.center,
              child: ElevatedButton(  // Save Button
                onPressed: () async {
                  await _addItem(); // Your existing save function
                  await _saveCurrentFormData(); // Also save to encrypted storage
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.lightBlueAccent,
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text( "SAVE"), // Change button text
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: _loadPreviousFormData, // Load from secure storage
              child: Text(getText('COPY PREVIOUS', _currentLanguage)),
            ),
          ],
        ),


        const SizedBox(height: 50),
        const Divider( // Add the Divider widget
            color: Colors.grey, // Color of the line
            thickness: 1.0), // Thickness of the line
        Expanded(
          child: _items.isEmpty
              ? const Center(child: Text("There are no items in the list."))
              : ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return Container( // Wrap each ListTile with Container
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Add margin for spacing between blocks
                decoration: BoxDecoration( // Add background, border, and rounded corners
                  color: Colors.white, // Background color for the block
                  // border: Border.all(color: Colors.grey, width: 1.0), // Border
                  //borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                child: GestureDetector(
                  onTap: () {
                    _showDetails(_items[index]);
                  },
                  child: ListTile(
                    title: Center(
                      child: Text(
                          "${index + 1}: ${_items[index].vehicleName} - vehicleType: ${_items[index].vehicleType} -serviceType: ${_items[index].serviceType} -serviceDate: ${_items[index].serviceDate } -mileage: ${_items[index].mileage } -cost: ${_items[index].cost }"
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),


      ],
    );
  }

  Widget _detailsPage() {
    if (_selectedItem == null) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: const Text("There is no item selected for detail."),
        ),
      );
    }


    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("Vehicle Id: ${_selectedItem!.vehicleId}",
              style: const TextStyle(fontSize: 18)),
          Text("Vehicle Name: ${_selectedItem!.vehicleName}",
              style: const TextStyle(fontSize: 18)),
          Text("Vehicle Type: ${_selectedItem!.vehicleType}",
              style: const TextStyle(fontSize: 18)),
          Text("Service Type: ${_selectedItem!.serviceType}",
              style: const TextStyle(fontSize: 18)),
          Text("Service Date: ${_selectedItem!.serviceDate}",
              style: const TextStyle(fontSize: 18)),
          Text("Mileage: ${_selectedItem!.mileage}",
              style: const TextStyle(fontSize: 18)),
          Text("Cost: ${_selectedItem!.cost}",
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 73),

          // Add the Row as another child of the Column
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _removeItem(_items.indexOf(_selectedItem!));
                  _closeDetails();
                },
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text(
                    "Delete", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditVehiclePage(
                            item: _selectedItem!,
                            dao: myDAO,
                            onUpdate: (updatedItem) {
                              setState(() {
                                _selectedItem = updatedItem;
                                _loadItems();
                              });
                            },
                          ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                    "Edit", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _closeDetails,
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text(
                    "Close", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              ),
            ],
          ),
        ],
      ), //
    );
  }

  Widget _reactiveLayout(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;

    if ((width > height) && (width > 720)) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: _listPage(),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: _detailsPage(),
            ),
          ),
        ],
      );
    } else {
      if (_selectedItem == null) {
        return _listPage();
      } else {
        return _detailsPage();
      }
    }
  }

  String _currentLanguage = 'en';
  /// Displays an AlertDialog with instructions.
  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(getText('instructions_title', _currentLanguage)),
        content: Text(getText('instructions_content', _currentLanguage)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("V E H I C L E - M A I N T E N A N C E - P A G E  |  வாகன பராமரிப்பு பக்கம்"),
        backgroundColor: Colors.lightBlueAccent[200],
        centerTitle: true,

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (value) {
              setState(() {
                _currentLanguage = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'ta', child: Text('தமிழ்')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _reactiveLayout(context),
      ),
    );
  }
}
