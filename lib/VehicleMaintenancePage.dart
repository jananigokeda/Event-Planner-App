
import 'package:cst2335_final/database.dart';
import 'dart:convert';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'database.dart';
import 'edit_vehicle_page.dart';
import 'vehicle_item.dart';
import 'vehicle_dao.dart';

class VehicleMaintenancePage extends StatefulWidget {
  const VehicleMaintenancePage({Key? key}) : super(key: key);

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
  late EncryptedSharedPreferences encryptedPrefs  = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();

    // Build the Floor database and get the DAO.
    $FloorAppDatabase.databaseBuilder('app_database.db').build().then((database) {
      _database = database;
      myDAO = database.vehicleDao;
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle Information has been successfully saved!!.')));
    } else {
      // Show validation error dialog
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle information required!! Please input vehicle info.')));
    }
  }

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

  // Picking the date
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0), // Rounded corners
                  borderSide: BorderSide(color: Colors.blue.shade300), // Border color
                ),
                filled: true,
                fillColor: Colors.blue.shade50, // Light background color
                contentPadding: EdgeInsets.all(16.0), // Inner padding
                floatingLabelStyle: TextStyle(color: Colors.blue.shade700),
              ),
            ),

            const SizedBox(height: 10), // Space between fields
            TextField( // Vehicle Type Input
              controller: _vehicleTypeController,
              decoration: InputDecoration(
                labelText: getText('vehicleType', _currentLanguage),
                hintText: "Vehicle Type",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0), // Rounded corners
                  borderSide: BorderSide(color: Colors.blue.shade300), // Border color
                ),
                filled: true,
                fillColor: Colors.blue.shade50, // Light background color
                contentPadding: EdgeInsets.all(16.0), // Inner padding
                floatingLabelStyle: TextStyle(color: Colors.blue.shade700),
              ),
            ),

            //serviceType
            const SizedBox(height: 10), // Space between fields
            TextField( // Service Type Input
              controller: _serviceTypeController,
              decoration: InputDecoration(
                labelText: getText('serviceType', _currentLanguage),
                hintText: "Service Type",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0), // Rounded corners
                  borderSide: BorderSide(color: Colors.blue.shade300), // Border color
                ),
                filled: true,
                fillColor: Colors.blue.shade50, // Light background color
                contentPadding: EdgeInsets.all(16.0), // Inner padding
                floatingLabelStyle: TextStyle(color: Colors.blue.shade700),
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
                    labelText: getText('serviceDate', _currentLanguage),
                    hintText: "YYYY-MM-DD",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide(color: Colors.blue.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    contentPadding: EdgeInsets.all(16.0),
                    floatingLabelStyle: TextStyle(color: Colors.blue.shade700),
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.blue.shade700),
                  ),
                ),
              ),
            ),

            //mileage
            const SizedBox(height: 10), // Space between fields
            TextField( // Mileage Input
              controller: _mileageController,
              decoration:  InputDecoration(
                labelText: getText('mileage', _currentLanguage),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0), // Rounded corners
                  borderSide: BorderSide(color: Colors.blue.shade300), // Border color
                ),
                filled: true,
                fillColor: Colors.blue.shade50, // Light background color
                contentPadding: EdgeInsets.all(16.0), // Inner padding
                floatingLabelStyle: TextStyle(color: Colors.blue.shade700),
              ),
            ),

            //Cost
            const SizedBox(height: 10), // Space between fields
            TextField( // Cost Input
              controller: _costController,
              decoration:  InputDecoration(
                labelText: getText('cost', _currentLanguage),
                hintText: "Cost",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0), // Rounded corners
                  borderSide: BorderSide(color: Colors.blue.shade300), // Border color
                ),

                filled: true,
                fillColor: Colors.blue.shade50, // Light background color
                contentPadding: EdgeInsets.all(16.0), // Inner padding
                floatingLabelStyle: TextStyle(color: Colors.blue.shade700),
              ),
            ),

            // SAVE button
            // Implementation of the SAVE button and COPY PREVIOUS BUTTON SECTION
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await _addItem(); // This method will add the vehicle info when save button is pressed
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
                    child: Text(getText('SAVE', _currentLanguage))

                ),
                const SizedBox(width: 20),
                ElevatedButton(

                  style: ElevatedButton.styleFrom(
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
                  onPressed: () {  },
                  child: Text(getText('COPY PREVIOUS', _currentLanguage)),
                ),
              ],
            )
          ],
        ),

        // This is the bottom part of the form which display the information from the database by calling the _showDetails
        // If the database is empty, it will dispaly, There are no items in the list
        const SizedBox(height: 25),
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

  //Helper method for consistent underlined fields
  Widget _buildUnderlinedField(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 1,
          color: Colors.lightBlue[300],
        ),
      ],
    );
  }

  // This detail page will show on the right side of the screen

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
    // adding rectangle container
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildUnderlinedField("VEHICLE ID: ${_selectedItem!.vehicleId}"),
          const SizedBox(height: 12),
          _buildUnderlinedField("VEHICLE NAME: ${_selectedItem!.vehicleName}"),
          const SizedBox(height: 12),
          _buildUnderlinedField("VEHICLE TYPE: ${_selectedItem!.vehicleType}"),
          const SizedBox(height: 12),
          _buildUnderlinedField("SERVICE TYPE: ${_selectedItem!.serviceType}"),
          const SizedBox(height: 12),
          _buildUnderlinedField("SERVICE DATE: ${_selectedItem!.serviceDate}"),
          const SizedBox(height: 12),
          _buildUnderlinedField("MILEAGE: ${_selectedItem!.mileage}"),
          const SizedBox(height: 12),
          _buildUnderlinedField("COST: ${_selectedItem!.cost}"),
          const SizedBox(height: 40),

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
                label: Text(
                  getText('Delete', _currentLanguage),  // Localized text
                  style: const TextStyle(color: Colors.white),
                ),
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
                label: Text(
                  getText('Edit', _currentLanguage),  // Localized text
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _closeDetails,
                icon: const Icon(Icons.close, color: Colors.white),
                label: Text(
                  getText('Close', _currentLanguage),  // Localized text
                  style: const TextStyle(color: Colors.white),
                ),
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

  //Heading section
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("V E H I C L E - M A I N T E N A N C E - P A G E  |  வாகன பராமரிப்பு பக்கம்"),
        backgroundColor: Colors.lightBlueAccent[200],
        centerTitle: true,
        actions: [
          SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.question_mark),
            onPressed: _showInstructions,
          ),
          SizedBox(width: 16),
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

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _reactiveLayout(context),
      ),
    );
  }






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
      'instructions_content':
      'வாகனத் தகவலைச் சேர்க்க தேவையான அனைத்து புலங்களையும் உள்ளிடவும்.\n கடைசி உள்ளீட்டுத் தரவை ஏற்ற "முந்தையதை நகலெடு" என்பதைத் தட்டவும்.\nவாகனத் தகவலைச் சேமிக்க சேமி பொத்தானைக் கிளிக் செய்யவும்.\nபக்கத்தில் விவரங்களைக் காண வாகனத் தகவலைக் கிளிக் செய்யவும்.\n',
      'vehicleName': 'வாகனத்தின் பெயர்',
      'vehicleType': 'வாகன வகை',
      'serviceType': 'சேவை வகை',
      'serviceDate': 'சேவை தேதி',
      'mileage': 'மைலேஜ்',
      'cost': 'விலை',
      'SAVE': 'சேமிக்க',
      'COPY PREVIOUS': 'முந்தைய_நகல்',
      'Edit': 'திருத்தவும்',
      'Delete': 'நீக்கவும்',
      'Close': 'மூடு'
    },
  };
  /// Returns the localized string for the given key.
  String getText(String key, String currentLanguage) {
    return localizedValues[currentLanguage]?[key] ?? key;
  }

}

